import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ssi/ssi.dart';

class TrustRegistryCheckResult {
  final CheckResult egf;
  final CheckResult ecosystem;

  TrustRegistryCheckResult({required this.egf, required this.ecosystem});

  bool get isValid => ecosystem.valid && egf.valid;
}

class CheckResult {
  final bool valid;
  final String message;

  CheckResult({required this.valid, required this.message});
}

class TrustRegistryHelper {
  static Future<TrustRegistryCheckResult> doChecks(
    VerifiablePresentation verifiablePresentation, {
    required Function onProgress,
  }) async {
    try {
      const allowedTypes = ['AyraBusinessCard'];
      var result = TrustRegistryCheckResult(
        egf: CheckResult(valid: true, message: 'No credentials to check'),
        ecosystem: CheckResult(valid: true, message: 'No credentials to check'),
      );

      final vcs = verifiablePresentation.verifiableCredential;
      if (vcs.isEmpty) {
        final msg = 'No verifiable credentials found in the presentation';
        print(msg);
        return TrustRegistryCheckResult(
          egf: CheckResult(valid: true, message: msg),
          ecosystem: CheckResult(valid: true, message: msg),
        );
      }

      for (var vc in vcs) {
        final assertionTypes = vc.type.toList();
        final vcType = assertionTypes[1]; // Get VC Type;

        if (!allowedTypes.contains(vcType)) {
          print('TRQP: Skipping checks as VC type $vcType is not allowed.');
          continue;
        }

        final issuerId = vc.issuer.id.toString();
        final authorityId = vc.credentialSubject[0]['ecosystem_id'];
        final issuedUnderAssertionId =
            vc.credentialSubject[0]['issued_under_assertion_id'];

        // onProgress({
        //   'messageType': 'info',
        //   'message':
        //       'Processing Issuer trust governance checks to confirm authorization and ecosystem recognition…',
        // });

        var ecosystemCheckResult = CheckResult(
          valid: false,
          message: 'VC does not have ecosystem in credentialSubject',
        );
        if (authorityId == null) {
          onProgress({
            'messageType': 'info',
            'message':
                'TRQP: Skipping checks as VC does not have ecosystem in credentialSubject.',
          });
        } else {
          // Check with Trust Registry of the authority
          // e.g. assertionId = 'issue:ayracard:businesscard'
          String resource = vcType.toLowerCase();
          if (issuedUnderAssertionId != null) {
            final parts = issuedUnderAssertionId.split(':');
            if (parts.length > 1) {
              resource = parts.sublist(1).join(':');
            }
          }

          ecosystemCheckResult = await checkEcosystemTrustRegistry(
            entityId: issuerId,
            authorityId: authorityId,
            action: 'issue',
            resource: resource,
            onProgress: onProgress,
          );
        }

        // Check with Ayra Trust Registry
        var egfCheckResult = CheckResult(
          valid: false,
          message: 'VC does not have ecosystem governance in credentialSubject',
        );
        final egfId = vc.credentialSubject[0]['egf_id'];
        if (egfId == null) {
          onProgress({
            'messageType': 'info',
            'message':
                'TRQP: Skipping checks as VC does not have ecosystem governance in credentialSubject.',
          });
        } else {
          egfCheckResult = await checkAyraTrustRegistry(
            entityId: authorityId ?? '',
            authorityId: egfId ?? '',
            action: 'recognize',
            resource: "listed-registry",
            onProgress: onProgress,
          );
        }

        result = TrustRegistryCheckResult(
          ecosystem: ecosystemCheckResult,
          egf: egfCheckResult,
        );
        if (result.isValid) {
          continue;
        }
        break;
      }

      return result;
    } catch (e, stackTrace) {
      print('Error calling APIs: $e');
      print('Stack trace: $stackTrace');
      onProgress({
        'messageType': 'failure',
        'message': 'TRQP: Error occurred while checking Trust Registry: $e}',
      });
      return TrustRegistryCheckResult(
        ecosystem: CheckResult(
          valid: false,
          message: 'Error occurred while checking Trust Registry',
        ),
        egf: CheckResult(
          valid: false,
          message: 'Error occurred while checking Trust Registry',
        ),
      );
    }
  }

  static Future<CheckResult> checkEcosystemTrustRegistry({
    required String entityId,
    required String authorityId,
    required String action,
    required String resource,
    required Function onProgress,
  }) async {
    // Get Trust Registry URLs
    final trUrl = await getTrustRegistryUrl(authorityId);
    if (trUrl == null) {
      final message =
          'TRQP: Endpoint not found in DID Document of authority $authorityId.';
      onProgress({'messageType': 'info', 'message': message});
      return CheckResult(valid: false, message: message);
    }

    // TRQP Query for authorization
    // onProgress({
    //   'messageType': 'info',
    //   'message': 'TRQP: Is entity authorized to $assertionId under authority?',
    // });

    final response2 = await callApi(
      '$trUrl/authorization',
      body: {
        "entity_id": entityId,
        "authority_id": authorityId,
        "action": action,
        "resource": resource,
      },
    );
    final verified = response2?['authorized'] as bool? ?? false;
    final message =
        'Issuer ${entityId.split(':').last} is ${verified ? '' : 'not '}authorized for $action:$resource in the ${authorityId.split(':').last}.';
    onProgress({
      'messageType': verified ? 'success' : 'failure',
      'message': message,
    });

    return CheckResult(
      valid: verified,
      message: verified
          ? 'Issuer is authorized to $action $resource.'
          : 'Issuer is not authorized to $action $resource.',
    );
  }

  static Future<CheckResult> checkAyraTrustRegistry({
    required String entityId,
    required String authorityId,
    required String action,
    required String resource,
    required Function onProgress,
  }) async {
    // Get Trust Registry URLs
    final trUrl = await getTrustRegistryUrl(authorityId);
    if (trUrl == null) {
      final message =
          'TRQP: Endpoint not found in DID Document of authority $authorityId.';
      onProgress({'messageType': 'info', 'message': message});
      return CheckResult(valid: false, message: message);
    }

    // TRQP Query for recognition
    // onProgress({
    //   'messageType': 'info',
    //   'message': 'TRQP: Is entity recognized by authority?',
    // });

    final response = await callApi(
      '$trUrl/recognition',
      body: {
        "entity_id": entityId,
        "authority_id": authorityId,
        "action": action,
        "resource": resource,
      },
    );
    final recognized = response?['recognized'] as bool? ?? false;
    final message =
        'Ecosystem ${entityId.split(':').last} is ${recognized ? '' : 'not '}recognized by Ayra.';
    onProgress({
      'messageType': recognized ? 'success' : 'failure',
      'message': message,
    });

    return CheckResult(
      valid: recognized,
      message: recognized
          ? 'Ecosystem is recognized by Ayra.'
          : 'Ecosystem is not recognized by Ayra.',
    );
  }

  static Future<String?> getTrustRegistryUrl(String didWeb) async {
    final resolver = UniversalDIDResolver();
    final didWebDocument = await resolver.resolveDid(didWeb);
    final trEndpoint = didWebDocument.service
        .where((end) => end.type == 'TRQP')
        .firstOrNull;
    if (trEndpoint == null) {
      return null;
    }

    final trUrl = (trEndpoint.serviceEndpoint as StringEndpoint).url;
    return trUrl;
  }

  static Future<Map<String, dynamic>?> callApi(
    String url, {
    String method = 'POST',
    Map<String, dynamic>? body,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    http.Response response;
    print(
      'API call started: $url with method $method and body ${jsonEncode(body)}',
    );
    if (method.toUpperCase() == 'GET') {
      response = await http.get(Uri.parse(url), headers: headers);
    } else {
      response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
    }

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('API call completed: ${jsonEncode(data)}');
      return data;
    } else {
      print('API call failed with status: ${response.statusCode}');
      return null;
    }
  }
}
