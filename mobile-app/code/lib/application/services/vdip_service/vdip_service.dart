import 'dart:async';
import 'dart:convert';

import 'package:affinidi_tdk_didcomm_mediator_client/affinidi_tdk_didcomm_mediator_client.dart';
import 'package:affinidi_tdk_vdip/affinidi_tdk_vdip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssi/ssi.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mpx_sdk_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/utils/credential_helper.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import '../login_service/issuer_connection_service.dart';
import '../settings_service/settings_service.dart';
import '../vault_service/vault_service.dart';

enum VdipResultStatus { success, failure, cancelled }

class VdipResult {
  const VdipResult({
    required this.status,
    required this.message,
    this.credentialString,
    this.credentialResult,
  });
  final VdipResultStatus status;
  final String message;
  final String? credentialString;
  final IssuerConnectionResult? credentialResult;

  bool get isSuccess => status == VdipResultStatus.success;
  bool get isFailure => status == VdipResultStatus.failure;
  bool get isCancelled => status == VdipResultStatus.cancelled;
}

final vdipServiceProvider = Provider<VdipService>(VdipService.new);

class VdipService {
  VdipService(this._ref);

  static const _logKey = 'VDIP';
  final Ref _ref;

  AppLogger get _logger => _ref.read(appLoggerProvider);

  Future<void> requestCredential({
    required RequestCredentialsOptions credentialsRequest,
    required Future<void> Function(String msg) onProgress,
    required Future<void> Function(VdipResult result) onComplete,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final completer = Completer<void>();
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final email = prefs.getString(SharedPreferencesKeys.email.name);
    if (email == null || email.isEmpty) {
      throw AppException(
        'Email is not found in SharedPreferences.',
        code: AppExceptionType.other.name,
      );
    }
    unawaited(onProgress('Ensuring connection with issuer...'));
    final issuerConnectionService = _ref.read(issuerConnectionServiceProvider);
    final issuerConnection = await issuerConnectionService.ensureChannel(
      email: email,
      logKey: _logKey,
    );

    final channel = issuerConnection.channel;

    final holderChannelDid = channel.permanentChannelDid;
    final issuerChannelDid = channel.otherPartyPermanentChannelDid;
    debugLog(
      'Holder channel did: $holderChannelDid',
      name: _logKey,
      logger: _logger,
    );
    debugLog(
      'Issuer channel did: $issuerChannelDid',
      name: _logKey,
      logger: _logger,
    );

    if (holderChannelDid == null || issuerChannelDid == null) {
      throw AppException(
        'Unable to establish a connection with issuer.',
        code: AppExceptionType.other.name,
      );
    }
    unawaited(onProgress('Established connection with issuer'));
    //Holder Channel DID Manager
    final sdk = await _ref.read(mpxSdkProvider.future);
    final channelDidManager = await sdk.getDidManager(holderChannelDid);
    unawaited(onProgress('Initializing Credential request...'));
    final mediatorDidDocument = await getMediatorDidDocument();
    final vdipHolderClient = await VdipHolder.init(
      mediatorDidDocument: mediatorDidDocument,
      didManager: channelDidManager,
      authorizationProvider: await AffinidiAuthorizationProvider.init(
        mediatorDidDocument: mediatorDidDocument,
        didManager: channelDidManager,
      ),
      clientOptions: const AffinidiClientOptions(),
    );
    unawaited(onProgress('Subscribing for Credential response from issuer...'));
    await _subscribeForVdipRequests(
      holderClient: vdipHolderClient,
      onProgress: onProgress,
      onComplete: onComplete,
      completer: completer,
      issuerConnection: issuerConnection,
    );

    unawaited(onProgress('Sending Credential request to issuer...'));
    //Holder Profile DID Manager
    final vaultService = _ref.read(vaultServiceProvider.notifier);
    final holderProfileDidManager = await vaultService.getDidManager();

    final holderSigner = await holderProfileDidManager.getSigner(
      holderProfileDidManager.assertionMethod.first,
    );
    final holderProfileDoc = await holderProfileDidManager.getDidDocument();
    final holderProfileDID = holderProfileDoc.id;
    debugLog(
      'Holder profile DID: $holderProfileDID',
      name: _logKey,
      logger: _logger,
    );

    await vdipHolderClient.requestCredentialForHolder(
      holderProfileDID,
      issuerDid: issuerChannelDid,
      assertionSigner: holderSigner,
      options: credentialsRequest,
    );
    unawaited(
      onProgress(
        'Waiting for ${credentialsRequest.proposalId} credential from issuer',
      ),
    );

    // Wait for the credential process to complete or timeout
    await completer.future.timeout(
      timeout,
      onTimeout: () async {
        await ConnectionPool.instance.stopConnections();
        unawaited(
          onComplete(
            const VdipResult(
              status: VdipResultStatus.failure,
              message: 'Timeout, no response from issuer',
            ),
          ),
        );
      },
    );
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

  Future<void> _subscribeForVdipRequests({
    required VdipHolder holderClient,
    required Future<void> Function(String msg) onProgress,
    required Future<void> Function(VdipResult result) onComplete,
    required Completer<void> completer,
    required IssuerConnectionResult issuerConnection,
  }) async {
    try {
      _logger.info('Starting VDIP listener', name: _logKey);

      holderClient.listenForIncomingMessages(
        onDiscloseMessage: (message) async {
          _logger.info('Holder received Disclose Message', name: _logKey);
        },
        onCredentialsIssuanceResponse: (message) async {
          unawaited(onProgress('Issuer has sent credential Response'));
          _logger.info(
            'Holder received Credential Issuance Response Message',
            name: _logKey,
          );

          final issuedCredentialBody = VdipIssuedCredentialBody.fromJson(
            message.body!,
          );

          unawaited(onProgress('Storing issued credential...'));
          await _storeCredential(issuedCredentialBody.credential);
          unawaited(
            onComplete(
              VdipResult(
                status: VdipResultStatus.success,
                message: 'Got Credentials successfully',
                credentialString: issuedCredentialBody.credential,
                credentialResult: issuerConnection,
              ),
            ),
          );
          _logger.info('VDIP Process completed successfully', name: _logKey);
          await ConnectionPool.instance.stopConnections();
          completer.complete();
        },
        onProblemReport: (message) async {
          _logger.warning(
            'VDIP problem report received: '
            '${jsonEncode(message.toJson())}',
            name: _logKey,
          );
          unawaited(
            onComplete(
              VdipResult(
                status: VdipResultStatus.failure,
                message:
                    'Problem report received: ${jsonEncode(message.toJson())}',
              ),
            ),
          );
          await ConnectionPool.instance.stopConnections();
          completer.complete();
        },
      );

      await ConnectionPool.instance.startConnections();
    } catch (error, stackTrace) {
      unawaited(
        onComplete(
          VdipResult(
            status: VdipResultStatus.failure,
            message: 'Error Occured: ${error.toString()}',
          ),
        ),
      );
      _logger.error(
        'Error Occured VDIP requests',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      await ConnectionPool.instance.stopConnections();
      completer.complete();
    }
  }

  Future<void> _storeCredential(String credentialJson) async {
    await _ref
        .read(vaultServiceProvider.notifier)
        .saveCredential(credential: credentialJson);
  }

  Future<void> createTestCredential() async {
    final credentials = await createSelfSignedCredential();
    for (final credential in credentials) {
      await _ref
          .read(vaultServiceProvider.notifier)
          .saveCredential(credential: jsonEncode(credential.toJson()));
    }
  }

  Future<List<ParsedVerifiableCredential>> createSelfSignedCredential() async {
    final sdk = await _ref.read(mpxSdkProvider.future);
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final vaultService = _ref.read(vaultServiceProvider.notifier);
    final vaultState = _ref.read(vaultServiceProvider);
    final holderProfileDid = vaultState.defaultProfile!.did;
    final holderManager = await sdk.generateDid();
    final holderSigner = await holderManager.getSigner(
      holderManager.assertionMethod.first,
    );

    final employmentCredential = await vaultService.getCredentialByType(
      CredentialHelper.employment,
    );
    if (employmentCredential == null) {
      throw Exception('Employment Credential not found in vault');
    }
    final credentialSubject = employmentCredential.credentialSubject[0]
        .toJson();

    // Load basic identity from preferences and employment credential
    final email = prefs.getString(SharedPreferencesKeys.email.name) ?? '';
    final displayName =
        prefs.getString(SharedPreferencesKeys.displayName.name) ?? '';
    final role = credentialSubject['role'] as String? ?? '';

    final sampleData = CredentialHelper.getSamplePayload(email);

    final holderVerifiableCredentials = await Future.wait(
      [
        VcDataModelV2(
          context: [
            dmV2ContextUrl,
            'https://schema.affinidi.io/AyraBusinessCardV1R2.jsonld',
          ],
          credentialSchema: [
            CredentialSchema(
              id: Uri.parse(
                'https://schema.affinidi.io/AyraBusinessCardV1R2.json',
              ),
              type: 'JsonSchemaValidator2018',
            ),
          ],
          id: Uri.parse('claimId:test-credential'),
          issuer: Issuer.uri(holderSigner.did),
          type: {'VerifiableCredential', 'AyraBusinessCard'},
          validFrom: DateTime.now().toUtc(),
          credentialSubject: [
            CredentialSubject.fromJson({
              'id': holderProfileDid,
              'display_name': displayName,
              'email': email,
              'ecosystem_id': 'did:web:issuers.sa.affinidi.io:sweetlane-group',
              'issued_under_assertion_id': 'issue:ayracard:businesscard',
              'issuer_id': 'did:web:issuers.sa.affinidi.io:sweetlane-bank',
              'egf_id': 'did:web:issuers.sa.affinidi.io:ayra-forum',
              'ayra_assurance_level': 0,
              'ayra_card_type': 'AyraBusinessCard',
              'payloads': [
                {
                  'id': 'phone',
                  'description': 'Phone number of the employee',
                  'type': 'text',
                  'data': sampleData['phone'],
                },
                {
                  'id': 'designation',
                  'description': 'designation of the employee',
                  'type': 'text',
                  'data': role,
                },
                {
                  'id': 'social',
                  'description': 'LinkedIn profile of the employee',
                  'type': 'url',
                  'data':
                      'https://www.linkedin.com/in/${sampleData['linkedIn']}',
                },
                {
                  'id': 'designation_level',
                  'description': 'designation level of the employee',
                  'type': 'number',
                  'data': sampleData['level'],
                },
              ],
            }),
          ],
        ),
      ].map((unsignedCredential) async {
        final suite = LdVcDm2Suite();
        final issuedCredential = await suite.issue(
          unsignedData: unsignedCredential,
          proofGenerator: Secp256k1Signature2019Generator(signer: holderSigner),
        );

        return issuedCredential;
      }),
    );

    return holderVerifiableCredentials;
  }
}
