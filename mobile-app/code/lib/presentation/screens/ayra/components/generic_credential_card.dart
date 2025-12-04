import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ssi/ssi.dart';

import '../../../../infrastructure/utils/credential_helper.dart';
import '../../../../infrastructure/utils/debug_logger.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../widgets/ayra/ayra_flip_card.dart';

class GenericCredentialCard extends StatelessWidget {
  const GenericCredentialCard({
    super.key,
    required this.credential,
    this.canFlip = true,
  });

  final VerifiableCredential credential;
  final bool canFlip;

  @override
  Widget build(BuildContext context) {
    const borderRadius = 16.0;
    final theme = Theme.of(context);

    // Generate unique card ID from credential
    final cardId = 'credential_${credential.id?.toString()}';

    // Use the canFlip parameter to control flip behavior
    return AyraFlipCard(
      cardId: cardId,
      canFlip: canFlip,
      frontSide: _buildFrontSide(borderRadius, theme, context),
      backSide: _buildBackSide(borderRadius, theme, context),
      onFlip: () => debugLog('Credential Card flipped'),
    );
  }

  /// Extract credential-specific details for the expanded view
  static List<Map<String, dynamic>> extractCredentialDetails(
    ParsedVerifiableCredential credential,
  ) {
    final details = <Map<String, dynamic>>[];

    try {
      // Add credential-specific details based on type
      final credentialSubject = credential.credentialSubject[0].toJson();

      if (credential.type.contains(CredentialHelper.verifiedIdentityDocument)) {
        final verificationData =
            credentialSubject['verification'] as Map<String, dynamic>? ?? {};

        final person =
            verificationData['person'] as Map<String, dynamic>? ?? {};
        details.add({
          'icon': Icons.person,
          'label': 'Full Name',
          'value':
              '${person['firstName'] as String} ${person['lastName'] as String}',
        });
        details.add({
          'icon': Icons.cake,
          'label': 'Date of Birth',
          'value': person['dateOfBirth'] as String? ?? '',
        });
        final document =
            verificationData['document'] as Map<String, dynamic>? ?? {};
        details.add({
          'icon': Icons.type_specimen,
          'label': 'Document Type',
          'value': document['docType'] as String? ?? '',
        });
        details.add({
          'icon': Icons.credit_card,
          'label': 'Document Number',
          'value': document['passportNumber'] as String? ?? '',
        });
        details.add({
          'icon': Icons.date_range,
          'label': 'Issuance Date',
          'value': document['issuanceDate'] as String? ?? '',
        });
        details.add({
          'icon': Icons.date_range,
          'label': 'Expiry Date',
          'value': document['expiryDate'] as String? ?? '',
        });
      } else if (credential.type.contains(CredentialHelper.employment)) {
        details.add({
          'icon': Icons.work,
          'label': 'Employment Type',
          'value': credentialSubject['employmentType'] as String? ?? '',
        });
        details.add({
          'icon': Icons.date_range,
          'label': 'Start Date',
          'value': credentialSubject['startDate'] as String? ?? '',
        });
        details.add({
          'icon': Icons.place,
          'label': 'Place of Employment',
          'value': credentialSubject['place'] as String? ?? '',
        });
      }
    } catch (e) {
      debugLog('Error extracting generic credential details', error: e);
    }

    return details;
  }

  Widget _buildFrontSide(
    double borderRadius,
    ThemeData theme,
    BuildContext context,
  ) {
    final credentialSubject = credential.credentialSubject[0].toJson();

    String title;
    var attributes = <String, String>{};
    var icon = CredentialHelper.credentialIcon(credential.type.toList());
    String? imageAsset;

    if (credential.type.contains(CredentialHelper.verifiedIdentityDocument)) {
      title = 'Verified Identity Credential';
      final verificationData =
          credentialSubject['verification'] as Map<String, dynamic>? ?? {};
      attributes = {
        'Name':
            '${verificationData['person']['firstName'] as String} ${verificationData['person']['lastName'] as String}',
        'DOB': verificationData['person']['dateOfBirth'] as String,
        'Document No':
            verificationData['document']?['passportNumber'] as String,
      };
      icon = Icons.admin_panel_settings_outlined;
    } else if (credential.type.contains(CredentialHelper.ayraBusinessCard)) {
      final payloads = credentialSubject['payloads'] as List<dynamic>? ?? [];
      title = 'Ayra Business Card';
      imageAsset = 'assets/images/ayra-logo.png';

      final designationPayload = payloads
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (p) => p['id'] == 'designation',
            orElse: () => <String, dynamic>{},
          );

      attributes = {
        'Name': credentialSubject['display_name'] as String? ?? 'N/A',
        'Email': credentialSubject['email'] as String? ?? 'N/A',
        'Designation': designationPayload['data'] as String? ?? 'N/A',
      };
    } else if (credential.type.contains(CredentialHelper.employment)) {
      final recipientInfo =
          credentialSubject['recipient'] as Map<String, dynamic>? ?? {};

      title = 'Employment Credential';
      attributes = {
        'Name':
            '${recipientInfo['givenName'] as String? ?? ''} ${recipientInfo['familyName'] as String? ?? ''}'
                .trim(),
        //'Email': credentialSubject['email'] as String? ?? '',
        'Organization': credentialSubject['legalEmployer']['name'] as String,
        'Job Title': credentialSubject['role'] as String,
        'Start Date': credentialSubject['startDate'] as String,
      };
    } else {
      title = credential.type.last;
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: CredentialHelper.getGradientForCredentialType(
                credential.type,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: imageAsset != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                imageAsset,
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Issuer
                Text(
                  'ISSUED BY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  credential.issuer.id.toString(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Attributes
                ...attributes.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.key,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // QR code hint icon in top-right corner
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.qr_code_2, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBackSide(
    double borderRadius,
    ThemeData theme,
    BuildContext context,
  ) {
    final qrSize = CredentialHelper.qrCodeSize;

    // Generate QR data from credential
    final qrData = credential.toString();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: CredentialHelper.getGradientForCredentialType(
                credential.type,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Credential type label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    CredentialHelper.getCredentialTypeName(
                      credential.type,
                      issuerId: credential.issuer.id.toString(),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // QR Code centered
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: qrSize,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // View JSON button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => CredentialJsonRoute(
                          $extra:
                              credential as ParsedVerifiableCredential<dynamic>,
                        ).push<void>(context),
                        icon: const Icon(Icons.code_rounded, size: 12),
                        label: const Text(
                          'View JSON',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // View Details button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          CredentialViewRoute(
                            $extra:
                                credential
                                    as ParsedVerifiableCredential<dynamic>,
                          ).push<void>(context);
                        },
                        icon: const Icon(Icons.info_outline_rounded, size: 12),
                        label: const Text(
                          'Details',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F39F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Close icon in top-right corner
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
