import 'dart:async';
import 'dart:convert';

import 'package:affinidi_tdk_didcomm_mediator_client/affinidi_tdk_didcomm_mediator_client.dart';
import 'package:affinidi_tdk_vdsp/affinidi_tdk_vdsp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'package:ssi/ssi.dart';
import 'package:uuid/uuid.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mpx_sdk_provider.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import '../../../messages/vdsp_trigger_request.dart';
import '../did_manager_service/did_manager_service.dart';
import '../login_service/issuer_connection_service.dart';
import '../settings_service/settings_service.dart';
import '../vault_service/vault_service.dart';

enum VdspScanResultStatus { success, failure, cancelled }

class VdspScanResult {
  const VdspScanResult({required this.status, required this.message});
  final VdspScanResultStatus status;
  final String message;

  bool get isSuccess => status == VdspScanResultStatus.success;
  bool get isFailure => status == VdspScanResultStatus.failure;
  bool get isCancelled => status == VdspScanResultStatus.cancelled;
}

final vdspServiceProvider = Provider<VdspService>((ref) {
  return VdspService(ref);
});

class VdspService {
  VdspService(Ref ref) : _ref = ref, _logger = ref.read(appLoggerProvider);

  static const Uuid _uuid = Uuid();

  final Ref _ref;
  final AppLogger _logger;
  static const _logKey = 'VDSP';

  Future<void> confirmScan({
    required String scanId,
    String? recipientDid,
    String? oobUrl,
    required VpspTriggerRequestBody triggerRequestBody,
    required Future<void> Function(String msg) onProgress,
    required Future<bool> Function(
      VdspQueryDataBody requestBody,
      List<ParsedVerifiableCredential<dynamic>> verifiableCredentials,
    )
    onShareConfirmation,
    required Future<void> Function(VdspScanResult result) onComplete,
  }) async {
    _logger.info('Confirming scan for id=$scanId', name: _logKey);

    if ((recipientDid == null || recipientDid.isEmpty) &&
        (oobUrl == null || oobUrl.isEmpty)) {
      throw AppException(
        'Verifier details missing from scan result.',
        code: AppExceptionType.other.name,
      );
    }
    unawaited(onProgress('Loading credentials to share...'));

    final sdk = await _ref.read(mpxSdkProvider.future);

    unawaited(onProgress('Establishing connection with verifier...'));
    final channel = await _ensureChannel(
      sdk: sdk,
      recipientDid: recipientDid,
      oobUrl: oobUrl,
    );

    final holderDid = channel.permanentChannelDid;
    final verifierDid = channel.otherPartyPermanentChannelDid;
    _logger.info('Holder Channel DID: $holderDid', name: _logKey);
    _logger.info('Verifier DID: $verifierDid', name: _logKey);

    if (holderDid == null || verifierDid == null) {
      throw AppException(
        'Unable to establish a connection with verifier.',
        code: AppExceptionType.other.name,
      );
    }

    await subscribeForVdspRequests(
      holderChannelDid: holderDid,
      onProgress: onProgress,
      onShareConfirmation: onShareConfirmation,
      onComplete: onComplete,
    );

    unawaited(onProgress('Sending trigger request to verifier...'));
    await _sendTriggerRequest(
      sdk: sdk,
      channel: channel,
      requestBody: triggerRequestBody,
    );
  }

  Future<Channel> _ensureChannel({
    required MeetingPlaceCoreSDK sdk,
    String? recipientDid,
    String? oobUrl,
  }) async {
    Channel? channel;
    if (recipientDid != null && recipientDid.isNotEmpty) {
      _logger.info(
        'Checking existing channel for verifier $recipientDid',
        name: _logKey,
      );
      channel = await sdk.getChannelByOtherPartyPermanentDid(recipientDid);
    }

    if (channel != null) {
      _logger.info(
        'Existing verifier channel found: ${channel.id}',
        name: _logKey,
      );
      return channel;
    }

    if (oobUrl == null || oobUrl.isEmpty) {
      throw AppException(
        'No OOB invitation available to create connection.',
        code: AppExceptionType.other.name,
      );
    }

    _logger.info(
      'No verifier channel found. Accepting OOB invitation.',
      name: _logKey,
    );

    final connectionService = _ref.read(issuerConnectionServiceProvider);
    debugLog('Accepting OOB URL: $oobUrl', name: _logKey, logger: _logger);
    channel = await connectionService.acceptOobFlow(
      sdk,
      oobUrl,
      logKey: _logKey,
    );

    return channel;
  }

  Future<DidDocument> getMediatorDidDocument() async {
    final provider = _ref.read(environmentProvider);
    final settingsState = _ref.read(settingsServiceProvider);
    final mediatorDid = provider.mediatorDid.isNotEmpty
        ? provider.mediatorDid
        : settingsState.selectedMediatorDid;
    final mediatorDidDocument = await UniversalDIDResolver.defaultResolver
        .resolveDid(mediatorDid);
    return mediatorDidDocument;
  }

  Future<void> subscribeForVdspRequests({
    required String holderChannelDid,
    required Future<void> Function(String msg) onProgress,
    required Future<bool> Function(
      VdspQueryDataBody requestBody,
      List<ParsedVerifiableCredential<dynamic>> verifiableCredentials,
    )
    onShareConfirmation,
    required Future<void> Function(VdspScanResult result) onComplete,
    bool onlyOnce = true,
  }) async {
    try {
      _logger.info('Starting VDSP listener', name: _logKey);

      final didManagerService = _ref.read(didManagerServiceProvider);
      final channelDidManager = await didManagerService.getDidManagerForDid(
        holderChannelDid,
      );

      final vaultService = _ref.read(vaultServiceProvider.notifier);
      final holderProfileDidManager = await vaultService.getDidManager();

      final mediatorDidDocument = await getMediatorDidDocument();

      final holderClient = await VdspHolder.init(
        mediatorDidDocument: mediatorDidDocument,
        didManager: channelDidManager,
        clientOptions: const AffinidiClientOptions(),
        authorizationProvider: await AffinidiAuthorizationProvider.init(
          mediatorDidDocument: mediatorDidDocument,
          didManager: channelDidManager,
        ),
        featureDisclosures: [...FeatureDiscoveryHelper.vdspHolderDisclosures],
      );

      holderClient.listenForIncomingMessages(
        onFeatureQuery: (message) async {
          unawaited(onProgress('Got VDSP feature query request...'));
          _logger.info('VDSP feature query received', name: _logKey);
        },
        onDataRequest: (message) async {
          unawaited(onProgress('Got VDSP data request...'));
          _logger.info('VDSP data request received', name: _logKey);

          final requestBody = VdspQueryDataBody.fromJson(message.body!);

          unawaited(
            onProgress(
              'VDSP data request message: ${jsonEncode(message.body!)}',
            ),
          );

          final credentials = await _loadVaultCredentials();
          // show error info that no credentials are available to share
          if (credentials.isEmpty) {
            unawaited(
              onComplete(
                const VdspScanResult(
                  status: VdspScanResultStatus.failure,
                  message: 'No credentials available to share.',
                ),
              ),
            );
            return;
          }

          unawaited(onProgress('Filtering credentials to share...'));
          final queryResult = await holderClient.filterVerifiableCredentials(
            requestMessage: message,
            verifiableCredentials: credentials,
          );

          if (queryResult.dcqlResult?.fulfilled == false) {
            unawaited(
              onComplete(
                const VdspScanResult(
                  status: VdspScanResultStatus.failure,
                  message:
                      'Unable to complete the request. Arya Business Card is missing.',
                ),
              ),
            );
            await holderClient.mediatorClient.packAndSendMessage(
              ProblemReportMessage(
                id: const Uuid().v4(),
                to: [message.from!],
                parentThreadId: message.threadId ?? message.id,
                body: ProblemReportBody(
                  code: ProblemCode(
                    sorter: SorterType.warning,
                    scope: Scope(scope: ScopeType.message),
                    descriptors: ['vdsp', 'data-not-found'],
                  ),
                ),
              ),
            );

            if (onlyOnce) {
              await ConnectionPool.instance.stopConnections();
            }
            return;
          }

          unawaited(onProgress('Preparing to share credentials...'));
          _logger.debug(
            'Preparing to share ${credentials.length} credential(s)',
            name: _logKey,
          );

          //Sharing confirmation callback
          final shouldShare = await onShareConfirmation(
            requestBody,
            queryResult.verifiableCredentials,
          );
          if (!shouldShare) {
            unawaited(
              onComplete(
                const VdspScanResult(
                  status: VdspScanResultStatus.cancelled,
                  message: 'User cancelled data sharing.',
                ),
              ),
            );
            if (onlyOnce) {
              await ConnectionPool.instance.stopConnections();
            }
            return;
          }

          final signer = await holderProfileDidManager.getSigner(
            holderProfileDidManager.assertionMethod.first,
          );

          await holderClient.shareData(
            requestMessage: message,
            verifiableCredentials: queryResult.verifiableCredentials,
            verifiablePresentationSigner: signer,
            verifiablePresentationProofSuite:
                DataIntegrityProofSuite.secp256k1Signature2019,
          );
          unawaited(
            onProgress('Data shared successfully, waiting for response...'),
          );
          _logger.info('VDSP data shared successfully', name: _logKey);
        },
        onDataProcessingResult: (message) async {
          _logger.info('VDSP data processing result received', name: _logKey);

          final resultBody = VdspDataProcessingResultBody.fromJson(
            message.body!,
          );
          debugLog(
            'result came here: ${jsonEncode(message.body!)}',
            name: _logKey,
            logger: _logger,
          );

          unawaited(
            onComplete(
              VdspScanResult(
                status:
                    (resultBody.result['status'] as String? ?? '') == 'success'
                    ? VdspScanResultStatus.success
                    : VdspScanResultStatus.failure,
                message: resultBody.result['message'] as String? ?? 'Unknown',
              ),
            ),
          );
          if (onlyOnce) {
            await ConnectionPool.instance.stopConnections();
          }
        },
        onProblemReport: (message) async {
          _logger.warning(
            'VDSP problem report received: '
            '${jsonEncode(message.toJson())}',
            name: _logKey,
          );
          unawaited(
            onComplete(
              const VdspScanResult(
                status: VdspScanResultStatus.failure,
                message: 'VDSP: Problem report received',
              ),
            ),
          );
          if (onlyOnce) {
            await ConnectionPool.instance.stopConnections();
          }
        },
      );

      await ConnectionPool.instance.startConnections();
    } catch (error, stackTrace) {
      unawaited(
        onComplete(
          VdspScanResult(
            status: VdspScanResultStatus.failure,
            message: 'Error Occured: ${error.toString()}',
          ),
        ),
      );
      _logger.error(
        'Failed to subscribe for VDSP requests',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      if (onlyOnce) {
        await ConnectionPool.instance.stopConnections();
      }
    }
  }

  Future<void> _sendTriggerRequest({
    required MeetingPlaceCoreSDK sdk,
    required Channel channel,
    required VpspTriggerRequestBody requestBody,
  }) async {
    final message = VpspTriggerRequestMessage(
      id: _uuid.v4(),
      from: channel.permanentChannelDid,
      to: [channel.otherPartyPermanentChannelDid ?? ''],
      body: requestBody.toJson(),
    );

    _logger.info('Sending VDSP trigger request', name: _logKey);
    await sdk.sendMessage(
      message,
      senderDid: channel.permanentChannelDid ?? '',
      recipientDid: channel.otherPartyPermanentChannelDid ?? '',
    );
  }

  Future<List<ParsedVerifiableCredential<dynamic>>>
  _loadVaultCredentials() async {
    final vaultState = _ref.watch(vaultServiceProvider);
    final credentials = vaultState.claimedCredentials ?? [];

    if (credentials.isEmpty) {
      _logger.warning(
        'No credentials available in vault to share',
        name: _logKey,
      );
    }
    return credentials
        .map(
          (c) => c.verifiableCredential as ParsedVerifiableCredential<dynamic>,
        )
        .toList();
  }
}
