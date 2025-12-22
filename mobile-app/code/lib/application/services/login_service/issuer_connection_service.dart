import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:ssi/ssi.dart';

import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mpx_sdk_provider.dart';
import '../../../infrastructure/repositories/organizations_repository/organizations.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import 'issuer_did_cache.dart';

class IssuerConnectionResult {
  IssuerConnectionResult({required this.channel, required this.issuerDid});

  final Channel channel;
  final String issuerDid;
}

class IssuerConnectionService {
  IssuerConnectionService(this._ref);

  static const _defaultLogKey = 'ISSUER_CONN';

  final Ref _ref;

  AppLogger get _logger => _ref.read(appLoggerProvider);

  Future<IssuerConnectionResult> ensureChannel({
    required String email,
    String logKey = _defaultLogKey,
  }) async {
    //Get organization DID for the provider
    final issuerDidWeb = await _getProviderDid();

    final sdk = await _ref.read(mpxSdkProvider.future);

    // Check issuer channel did in cache for the provider
    var issuerChannelDid = await readCachedIssuerDid(ref: _ref);
    debugLog(
      'Issuer: issuerChannelDid from cache: $issuerChannelDid',
      name: logKey,
      logger: _logger,
    );

    Channel? channel;

    //Check any exists channel for the issuer
    if (issuerChannelDid != null) {
      debugLog(
        'Found cached issuer DID: $issuerChannelDid',
        name: logKey,
        logger: _logger,
      );
      channel = await sdk.getChannelByOtherPartyPermanentDid(issuerChannelDid);
      debugLog(
        'Issuer: Channel from cache: ${channel?.id}',
        name: logKey,
        logger: _logger,
      );
      if (channel != null) {
        debugLog(
          'Reusing cached channel ${channel.id} for issuer $issuerChannelDid',
          name: logKey,
          logger: _logger,
        );
      } else {
        debugLog(
          'No channel found for cached issuer DID $issuerChannelDid',
          name: logKey,
          logger: _logger,
        );
      }
    }

    // No channel found for issuer channel did or first time connection
    if (channel == null) {
      debugLog(
        'Issuer: No channel found, requesting invitation by /login call',
        name: logKey,
        logger: _logger,
      );
      // Making auth authentication call to get the OOB invitation
      final invitation = await _requestIssuerInvitation(
        didWeb: issuerDidWeb,
        email: email,
        logKey: logKey,
      );
      //setting issuer channel DID from invitation
      issuerChannelDid = invitation.issuerDid;

      // Check any channel exists for the issuer channel DID
      channel = await sdk.getChannelByOtherPartyPermanentDid(issuerChannelDid);
      debugLog(
        'Issuer: Checking channel for issuer ${channel?.id}',
        name: logKey,
        logger: _logger,
      );

      if (channel == null) {
        debugLog(
          'Issuer: No channel found. Accepting OOB invitation ${channel?.id}',
          name: logKey,
          logger: _logger,
        );
        channel = await acceptOobFlow(sdk, invitation.oobUrl);
      } else {
        debugLog(
          'Existing channel found: ${channel.id}',
          name: logKey,
          logger: _logger,
        );
      }
    }

    issuerChannelDid ??= channel.otherPartyPermanentChannelDid;

    debugLog(
      'Issuer: final issuer channel did: $issuerChannelDid',
      name: logKey,
      logger: _logger,
    );

    if (issuerChannelDid == null) {
      throw Exception(
        'Unable to establish a channel with the issuer DID $issuerDidWeb',
      );
    }

    return IssuerConnectionResult(
      channel: channel,
      issuerDid: issuerChannelDid,
    );
  }

  Future<Channel> acceptOobFlow(
    MeetingPlaceCoreSDK sdk,
    String oobUrl, {
    String logKey = _defaultLogKey,
  }) async {
    debugLog(
      'No channel found. Accepting OOB invitation.',
      name: logKey,
      logger: _logger,
    );
    final completer = Completer<Channel?>();
    final oobUri = Uri.parse(oobUrl);

    final acceptance = await sdk.acceptOobFlow(
      oobUri,
      contactCard: ContactCard(
        did: 'did:example:john',
        type: 'individual',
        contactInfo: {
          'n': {'given': 'John', 'surname': 'Doe'},
        },
      ),
    );

    acceptance.streamSubscription.listen((data) {
      final channel = data.channel;
      debugLog(
        'Holder DID: ${channel.permanentChannelDid}',
        name: logKey,
        logger: _logger,
      );
      debugLog(
        'Other Party DID: ${channel.otherPartyPermanentChannelDid}',
        name: logKey,
        logger: _logger,
      );
      _logger.info('acceptOobFlow onDone with id: ${channel.id}', name: logKey);
      _logger.info(
        'Other Party DID: ${channel.otherPartyPermanentChannelDid}',
        name: logKey,
      );
      completer.complete(channel);
    });
    acceptance.streamSubscription.timeout(
      const Duration(seconds: 60),
      () => completer.complete(null),
    );

    final channel = await completer.future;
    if (channel == null) {
      throw AppException(
        'Invalid OOB URL or timeout while accepting invitation',
        code: AppExceptionType.other.name,
      );
    }
    debugLog(
      'Closing the acceptOobFlow mediator',
      name: logKey,
      logger: _logger,
    );
    await acceptance.streamSubscription.dispose();
    return channel;
  }

  Future<_IssuerInvitation> _requestIssuerInvitation({
    required String didWeb,
    required String email,
    required String logKey,
  }) async {
    debugLog('Resolving $didWeb', name: logKey);

    final resolver = UniversalDIDResolver();
    final didWebDocument = await resolver.resolveDid(didWeb);

    final authEndpoint = didWebDocument.service
        .where((end) => end.type == 'UserAuthenticationService')
        .firstOrNull;

    if (authEndpoint == null) {
      throw Exception('Issuer did:web document does not have service endpoint');
    }

    final authUrl = (authEndpoint.serviceEndpoint as StringEndpoint).url;
    debugLog('Requesting OOB URL from $authUrl', name: logKey, logger: _logger);

    final response = await http.post(
      Uri.parse(authUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 403) {
      throw Exception('Provide email is not authorized by the organization');
    } else if (response.statusCode != 200) {
      throw Exception(
        'Got error ${response.statusCode} when invoking the auth service endpoint $authUrl',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final issuerOobUrl = data['oobUrl'] as String?;
    final issuerDid = data['did'] as String?;

    if (issuerOobUrl == null || issuerDid == null) {
      throw Exception('Did not get oob url/did from $authUrl');
    }

    debugLog('OOB URL and DID received', name: logKey, logger: _logger);
    debugLog('OOB URL: $issuerOobUrl', name: logKey, logger: _logger);
    debugLog('ISSUER DID: $issuerDid', name: logKey, logger: _logger);

    return _IssuerInvitation(oobUrl: issuerOobUrl, issuerDid: issuerDid);
  }

  Future<bool> isTrustedDid({
    required String did,
    required String logKey,
  }) async {
    final parentDid = Organizations.parent['did'];
    final trustRegistryUrl = await getTrustRegistryEntry(
      did: parentDid!,
      logKey: logKey,
    );

    // Development: Replace localhost with appropriate address for mobile testing
    final adjustedUrl = trustRegistryUrl.replaceAll(
      'localhost:',
      '10.0.2.2:', // Use 10.0.2.2 for Android emulator
      // For iOS Simulator: use 'localhost:3000'
      // For physical device: use your computer's IP like '192.168.1.100:3000'
    );

    debugLog(
      'Trust registry URL (adjusted): $adjustedUrl',
      name: logKey,
      logger: _logger,
    );

    final response = await http.post(
      Uri.parse('$adjustedUrl/recognition'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'entity_id': did,
        'authority_id': parentDid,
        'action': 'recognize',
        'resource': 'listed-verifier',
      }),
    );

    debugLog(
      'Trust registry response body: ${response.body}',
      name: logKey,
      logger: _logger,
    );

    if (response.statusCode != 200) {
      debugLog(
        'Got error ${response.statusCode} when invoking the trust registry $trustRegistryUrl (i.e. not recognized)',
        name: logKey,
        logger: _logger,
      );
      return false;
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final isTrusted = data['recognized'] as bool? ?? false;
    debugLog(
      'DID $did trusted status: $isTrusted',
      name: logKey,
      logger: _logger,
    );
    return isTrusted;
  }

  Future<String> getTrustRegistryEntry({
    required String did,
    required String logKey,
  }) async {
    debugLog('Resolving did:web: $did', name: logKey, logger: _logger);

    final resolver = UniversalDIDResolver();
    final didWebDocument = await resolver.resolveDid(did);

    final trustRegistryEndpoint = didWebDocument.service
        .where((end) => end.type == 'TRQP')
        .firstOrNull;

    if (trustRegistryEndpoint == null) {
      throw Exception(
        'did:web document does not have TrustRegistryService endpoint',
      );
    }

    final trustRegistryUrl =
        (trustRegistryEndpoint.serviceEndpoint as StringEndpoint).url;
    debugLog(
      'Trust Registry URL: $trustRegistryUrl',
      name: logKey,
      logger: _logger,
    );

    return trustRegistryUrl;
  }

  Future<String> _getProviderDid() async {
    final providerName = await readCachedProvider(ref: _ref);
    if (providerName == null) {
      throw AppException(
        'No $providerName found in cache',
        code: AppExceptionType.other.name,
      );
    }
    final provider = Organizations.orgs
        .where((m) => m.name == providerName)
        .firstOrNull;
    if (provider == null) {
      throw AppException(
        'No configuration found for $provider',
        code: AppExceptionType.other.name,
      );
    }

    return provider.did;
  }
}

final issuerConnectionServiceProvider = Provider<IssuerConnectionService>(
  IssuerConnectionService.new,
);

class _IssuerInvitation {
  _IssuerInvitation({required this.oobUrl, required this.issuerDid});

  final String oobUrl;
  final String issuerDid;
}
