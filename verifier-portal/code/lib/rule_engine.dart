import 'package:ssi/ssi.dart';
import 'clients.dart';
import 'models/verifier_client.dart';
import 'mpx_client.dart';
import 'trust_registry_helper.dart';

class RuleEngine {
  static Future<CheckResult> doChecks(
    VerifierClient client,
    VerifiablePresentation verifiablePresentation, {
    required Function onProgress,
  }) async {
    try {
      print('Starting Rule Engine checks for client: ${client.id}');
      final ayraCard = verifiablePresentation.verifiableCredential
          .where((vc) => vc.type.contains('AyraBusinessCard'))
          .firstOrNull;

      if (ayraCard == null) {
        final msg = 'No Ayra Business Card found in the presentation.';
        onProgress({'messageType': 'failure', 'message': 'RuleEngine: $msg'});
        return CheckResult(valid: false, message: msg);
      }

      final credentialSubject = ayraCard.credentialSubject[0];
      final payloads = credentialSubject['payloads'] as List?;
      if (payloads == null || payloads.isEmpty) {
        final msg = 'No payloads found in the Ayra Business Card';
        onProgress({'messageType': 'failure', 'message': 'RuleEngine: $msg'});
        return CheckResult(valid: false, message: msg);
      }
      CheckResult checkResult;
      if (client.id == ClientsList.kioskClient.id) {
        checkResult = await doEmploymentChecks(payloads);
      } else if (client.id == ClientsList.roundtableClient.id) {
        checkResult = await doEmploymentChecks(payloads);
        if (checkResult.valid) {
          onProgress({
            'messageType': checkResult.valid ? 'success' : 'failure',
            'message': checkResult.message,
          });
          checkResult = await doDesignationLevelChecks(payloads);
        }
      } else if (client.id == ClientsList.checkinDeskClient.id) {
        checkResult = await doEmploymentChecks(payloads);
        if (checkResult.valid) {
          onProgress({
            'messageType': checkResult.valid ? 'success' : 'failure',
            'message': checkResult.message,
          });
          checkResult = await doIDVChecks(payloads);
        }
      } else {
        checkResult = CheckResult(
          valid: true,
          message: 'No rules defined for ${client.name}.',
        );
      }

      onProgress({
        'messageType': checkResult.valid ? 'success' : 'failure',
        'message': checkResult.message,
      });
      return checkResult;
    } catch (e, stackTrace) {
      print('RuleEngine Error: $e');
      print(stackTrace);
      onProgress({
        'messageType': 'failure',
        'message': 'RuleEngine: Error occurred: $e}',
      });
      return CheckResult(valid: false, message: 'RuleEngine Error: $e');
    }
  }

  static Future<CheckResult> doDesignationLevelChecks(
    List<dynamic> payloads,
  ) async {
    final payloadDesignationLevel = payloads
        .where((p) => p['id'] == 'designation_level')
        .firstOrNull;
    if (payloadDesignationLevel == null) {
      return CheckResult(
        valid: false,
        message: 'Designation Level not found in Ayra Business Card payloads.',
      );
    }
    if ((payloadDesignationLevel['data'] as int) < 50) {
      return CheckResult(
        valid: false,
        message:
            'Only designation level 50 and above allowed to the secure area.',
      );
    }
    return CheckResult(valid: true, message: 'Designation level check passed.');
  }

  static Future<CheckResult> doEmploymentChecks(List<dynamic> payloads) async {
    final payloadEmploymentVC = payloads
        .where((p) => p['id'] == 'employment_credential')
        .firstOrNull;
    final employmentVC = payloadEmploymentVC?['data'] as String?;
    if (employmentVC == null) {
      return CheckResult(
        valid: false,
        message:
            'Employment Credential not found in Ayra Business Card payloads.',
      );
    }

    final verificationResult = await MpxClient.verifyCredential(employmentVC);
    if (verificationResult.isValid != true) {
      return CheckResult(
        valid: false,
        message: 'Employment Credential verification failed.',
      );
    }
    return CheckResult(
      valid: true,
      message:
          'Expected Employment Credential payload found for compliance check and integrity is verified.',
    );
  }

  static Future<CheckResult> doIDVChecks(List<dynamic> payloads) async {
    final payloadIdvCredential = payloads
        .where((p) => p['id'] == 'identity_credential')
        .firstOrNull;
    final identityVC = payloadIdvCredential?['data'] as String?;
    if (identityVC == null) {
      return CheckResult(
        valid: false,
        message:
            'Identity Credential not found in Ayra Business Card payloads.',
      );
    }

    final verificationResult = await MpxClient.verifyCredential(identityVC);
    if (verificationResult.isValid != true) {
      return CheckResult(
        valid: false,
        message: 'Identity Credential verification failed.',
      );
    }
    return CheckResult(
      valid: true,
      message:
          'Expected Identity Credential payload found for compliance check and integrity is verified.',
    );
  }
}
