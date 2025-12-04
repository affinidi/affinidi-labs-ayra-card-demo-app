import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ssi/ssi.dart';

import '../../../../application/services/vault_service/vault_service.dart';
import '../../../../infrastructure/utils/credential_helper.dart';
import '../../../../infrastructure/utils/debug_logger.dart';
import '../../../widgets/ayra/ayra_flip_card.dart';
import '../credential_json_screen.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.email,
    this.company,
    this.avatarAsset,
    this.customPhotoPath,
    this.initiallyVerified = false,
    this.onVerify,
    this.onPrimaryAction,
    this.primaryActionLabel = 'Verify',
    this.width = double.infinity,
    this.credential, // optional credential for flip-to-JSON feature
  });

  ProfileCard.fromCredential({
    super.key,
    required VerifiableCredential this.credential,
    this.email,
    this.initiallyVerified = false,
    this.onVerify,
    this.onPrimaryAction,
    this.primaryActionLabel = 'Verify',
    this.width = double.infinity,
    this.customPhotoPath,
  }) : name = _getName(credential) ?? 'Unknown',
       subtitle = _getRole(credential) ?? '',
       company = _getCompany(credential) ?? '',
       avatarAsset = null;

  final String name;
  final String subtitle;
  final String? email;
  final String? company;
  final String? avatarAsset; // supports SVG and raster assets
  final String? customPhotoPath; // Custom photo from profile
  final bool initiallyVerified;
  final Future<void> Function()? onVerify;
  final VoidCallback? onPrimaryAction;
  final String primaryActionLabel;
  final double width;
  final VerifiableCredential? credential; // for JSON display on flip

  static String? _getName(VerifiableCredential cred) {
    final credentialSubject = cred.credentialSubject[0].toJson();
    final recipientInfo =
        credentialSubject['recipient'] as Map<String, dynamic>? ?? {};

    return '${recipientInfo['givenName'] as String? ?? ''} ${recipientInfo['familyName'] as String? ?? ''}'
        .trim();
  }

  static String? _getRole(VerifiableCredential cred) {
    final credentialSubject = cred.credentialSubject[0].toJson();

    return credentialSubject['role'] as String?;
  }

  static String? _getCompany(VerifiableCredential cred) {
    final credentialSubject = cred.credentialSubject[0].toJson();

    return credentialSubject['legalEmployer']['name'] as String?;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderRadius = 16.0;
    final theme = Theme.of(context);
    final avatarSize = CredentialHelper.avatarSize;

    // Only allow flip if we have credential data
    final canFlip = credential != null;

    // If no credential, just show front side
    if (!canFlip) {
      return _buildFrontSide(borderRadius, theme, avatarSize, context, ref);
    }

    // Generate unique card ID for this profile card
    final cardId = 'profile_card_${name}_${email ?? ''}';

    // Wrap in flip card
    return AyraFlipCard(
      cardId: cardId,
      canFlip: canFlip,
      frontSide: _buildFrontSide(borderRadius, theme, avatarSize, context, ref),
      backSide: _buildBackSide(borderRadius, theme, context, ref),
      onFlip: () => debugLog('Profile Card flipped'),
    );
  }

  Widget _buildFrontSide(
    double borderRadius,
    ThemeData theme,
    double avatarSize,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3A3A3A), // Dark titanium
                Color(0xFF2C2C2C), // Darker titanium
                Color(0xFF1E1E1E), // Darkest titanium
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(pi / 4),
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
          child: Row(
            children: [
              // Avatar without verification badge
              SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: _buildAvatar(avatarSize),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (company != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        company!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ],
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
        // Verified badge in bottom-right corner
        Positioned(bottom: 12, right: 12, child: _buildVerified(ref)),
      ],
    );
  }

  Widget _buildBackSide(
    double borderRadius,
    ThemeData theme,
    BuildContext context,
    WidgetRef ref,
  ) {
    if (credential == null) {
      return Container(); // shouldn't happen
    }

    final qrSize = CredentialHelper.qrCodeSize;

    final qrData = credential.toString();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3A3A3A), // Dark titanium
                Color(0xFF2C2C2C), // Darker titanium
                Color(0xFF1E1E1E), // Darkest titanium
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: GradientRotation(pi / 4),
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
          child: Row(
            children: [
              // QR Code (replaces avatar)
              SizedBox(
                width: qrSize,
                height: qrSize,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                    size: qrSize - 24,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                    if (company != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        company!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        // List/flip-back hint icon in top-right corner
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
        // Bottom-right controls: View JSON button + Verified badge
        Positioned(
          bottom: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small View JSON button
              GestureDetector(
                onTap: () {
                  if (credential != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => CredentialJsonScreen(
                          credential: credential as ParsedVerifiableCredential,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.code_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'View JSON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildVerified(ref),
            ],
          ),
        ),
      ],
    );
  }

  // verification flow is handled by parent via `onVerify` if needed

  Widget _buildAvatar(double size) {
    // Priority: customPhotoPath > avatarAsset > fallback initial
    if (customPhotoPath != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(customPhotoPath!)),
        backgroundColor: Colors.transparent,
      );
    }

    final avatar = avatarAsset;
    if (avatar == null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Use a normal image (asset or network) instead of SVG
    // ignore: omit_local_variable_types
    final ImageProvider imageProvider = avatar.startsWith('http')
        ? NetworkImage(avatar)
        : AssetImage(avatar);

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: imageProvider,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildVerified(WidgetRef ref) {
    // Read verification status from provider
    final vaultState = ref.watch(vaultServiceProvider);
    final digitalCredentials = vaultState.claimedCredentials ?? [];
    final idvCard = digitalCredentials.where((credential) {
      return credential.verifiableCredential.type.contains(
        CredentialHelper.verifiedIdentityDocument,
      );
    }).firstOrNull;
    final isVerified = idvCard != null;

    final verifiedIcon = isVerified
        ? Icons.check_circle_rounded
        : Icons.lock_outline_rounded;
    final statusText = isVerified ? 'Verified' : 'Pending';
    final statusColor = isVerified
        ? Colors.green.shade500
        : Colors.orange.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(verifiedIcon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
