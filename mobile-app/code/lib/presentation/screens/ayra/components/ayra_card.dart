import 'dart:convert';
import 'dart:io' as dartio;
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ssi/ssi.dart';

import '../../../../infrastructure/utils/credential_helper.dart';
import '../../../../infrastructure/utils/debug_logger.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../widgets/ayra/ayra_flip_card.dart';
import '../credential_json_screen.dart';

class AyraCard extends StatelessWidget {
  const AyraCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.email,
    this.company,
    this.avatarAsset,
    this.isVerified = false, // User completed IDV
    this.isClaimed = false, // User claimed the Ayra Card
    this.onVerify,
    this.onClaim,
    this.onPrimaryAction,
    this.primaryActionLabel = 'Get Verified',
    this.width = double.infinity,
    this.credential,
    this.linkedinUrl, // LinkedIn profile from claim form
    this.customPhotoPath, // Custom photo from claim form
    this.vcType,
  });

  AyraCard.fromCredential({
    super.key,
    required VerifiableCredential this.credential,
    this.isVerified = false,
    this.isClaimed = false,
    this.onVerify,
    this.onClaim,
    this.onPrimaryAction,
    this.primaryActionLabel = 'Get Verified',
    this.width = double.infinity,
    this.linkedinUrl, // LinkedIn profile from claim form
    this.customPhotoPath, // Custom photo from claim form
  }) : name = _getDataFor(credential, 'display_name') ?? 'Unknown',
       subtitle = _getDataFor(credential, 'designation') ?? '',
       email = _getDataFor(credential, 'email'),
       company = _getDataFor(credential, 'website'),
       avatarAsset = _getDataFor(credential, 'avatar'),
       vcType = CredentialHelper.getCredentialTypeName(
         credential.type,
         issuerId: credential.issuer.id.toString(),
       );

  final String name;
  final String subtitle;
  final String? email;
  final String? company;
  final String? avatarAsset;
  final String? vcType;
  final bool isVerified; // User completed IDV
  final bool isClaimed; // User claimed the Ayra Card
  final Future<void> Function()? onVerify;
  final Future<void> Function()? onClaim;
  final VoidCallback? onPrimaryAction;
  final String primaryActionLabel;
  final double width;
  final VerifiableCredential? credential;
  final String? linkedinUrl; // LinkedIn profile from claim form
  final String? customPhotoPath; // Custom photo path from claim form

  static String? _getDataFor(VerifiableCredential cred, String type) {
    final credentialSubject = cred.credentialSubject[0].toJson();
    final val = credentialSubject[type] as String?;
    if (val != null && val.isNotEmpty) {
      return val;
    }
    //checks in payloads
    final payloads = credentialSubject['payloads'] as List<dynamic>?;

    final payload = payloads?.firstWhereOrNull((p) => p['id'] == type);

    final payloadType = payload?['type'] as String?;
    final payloadData = payload?['data'] as String?;
    if (payloadType != null && payloadType.startsWith('image/')) {
      if (payloadData != null && payloadData.isNotEmpty) {
        return 'data:$payloadType,$payloadData';
      }
    }

    return payloadData;
  }

  /// Extract credential-specific details for the expanded view
  static List<Map<String, dynamic>> extractCredentialDetails(
    ParsedVerifiableCredential credential,
  ) {
    final details = <Map<String, dynamic>>[];

    try {
      // AyraBusinessCard-specific details only
      final credentialSubject = credential.credentialSubject[0].toJson();
      final payloads = credentialSubject['payloads'] as List<dynamic>?;

      if (payloads != null && payloads.isNotEmpty) {
        // Phone
        final payloadPhone = payloads.firstWhereOrNull(
          (p) => p['id'] == 'phone',
        );
        if (payloadPhone != null) {
          details.add({
            'icon': Icons.phone,
            'label':
                payloadPhone['description'] as String? ??
                payloadPhone['id'] as String,
            'value': payloadPhone['data'] as String? ?? '',
          });
        }

        final payloadLinkedIn = payloads.firstWhereOrNull(
          (p) => p['id'] == 'social',
        );
        if (payloadLinkedIn != null) {
          details.add({
            'icon': Icons.link,
            'label':
                payloadLinkedIn['description'] as String? ??
                payloadLinkedIn['id'] as String,
            'value': payloadLinkedIn['data'] as String? ?? '',
          });
        }

        final meetingPayload = payloads.firstWhereOrNull(
          (p) => p['id'] == 'book_meeting',
        );
        if (meetingPayload != null) {
          details.add({
            'icon': Icons.calendar_month_outlined,
            'label':
                meetingPayload['description'] as String? ??
                meetingPayload['id'] as String,
            'value': meetingPayload['data'] as String? ?? '',
          });
        }

        final signalPayload = payloads.firstWhereOrNull(
          (p) => p['id'] == 'signal',
        );
        if (signalPayload != null) {
          details.add({
            'icon': Icons.chat_rounded,
            'label':
                signalPayload['description'] as String? ??
                signalPayload['id'] as String,
            'value': signalPayload['data'] as String? ?? '',
          });
        }

        // vLEI
        final payloadVLEI = payloads.firstWhereOrNull((p) => p['id'] == 'vLEI');
        if (payloadVLEI != null) {
          details.add({
            'icon': Icons.verified_user,
            'label':
                payloadVLEI['description'] as String? ??
                payloadVLEI['id'] as String,
            'value': payloadVLEI['data'] as String? ?? '',
          });
        }
      }

      details.add({
        'icon': Icons.eco,
        'label': 'Ecosystem ID',
        'value': credentialSubject['ecosystem_id'] as String? ?? '',
      });

      details.add({
        'icon': Icons.account_tree,
        'label': 'Governance Framework ID',
        'value': credentialSubject['egf_id'] as String? ?? '',
      });
    } catch (e) {
      debugLog('Error extracting Ayra card details', error: e);
    }

    return details;
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = 16.0;
    final theme = Theme.of(context);
    final avatarSize = CredentialHelper.avatarSize;

    // Only allow flip if verified AND claimed AND has credential
    final canFlip = isClaimed && credential != null;

    // For non-flippable states (Disabled/Pending), just show front
    if (!canFlip) {
      return _buildFrontSide(borderRadius, theme, avatarSize, context);
    }

    // Generate unique card ID for this Ayra card
    final cardId = 'ayra_card_${name}_${email ?? ''}';

    // For Claimed state, wrap in flip card
    return AyraFlipCard(
      cardId: cardId,
      canFlip: canFlip,
      frontSide: _buildFrontSide(borderRadius, theme, avatarSize, context),
      backSide: _buildBackSide(borderRadius, theme, context),
      onFlip: () => debugLog('Ayra Card flipped'),
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    double avatarSize, {
    bool isFront = true,
  }) {
    // This method can be used to build common content if needed
    return Column(
      mainAxisSize: MainAxisSize.min, // Important: don't expand infinitely
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header Row: Ayra logo + title
        Row(
          children: [
            Image.asset(
              'assets/images/ayra-logo.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              vcType!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Avatar (centered)
        Center(
          child: SizedBox(
            width: avatarSize,
            height: avatarSize,
            child: isFront
                ? _buildAvatar(avatarSize)
                : _buildQRCode(avatarSize),
          ),
        ),
        const SizedBox(height: 16),

        // Name (centered)
        Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),

        // Email (centered with icon)
        if (email != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Icon(
              //   Icons.email_outlined,
              //   size: 16,
              //   color: Colors.white70,
              // ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // Role (centered with icon)
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Icon(
              //   Icons.work_outline_rounded,
              //   size: 16,
              //   color: Colors.white70,
              // ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // Company (centered with icon)
        if (company != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Icon(
              //   Icons.business_outlined,
              //   size: 16,
              //   color: Colors.white70,
              // ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  company!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        // LinkedIn Profile (centered with icon)
        if (linkedinUrl != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Icon(
              //   Icons.link_rounded,
              //   size: 16,
              //   color: Colors.white,
              // ),
              const SizedBox(width: 6),
              Text(
                linkedinUrl!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFrontSide(
    double borderRadius,
    ThemeData theme,
    double avatarSize,
    BuildContext context,
  ) {
    // State 2: Pending - user verified but hasn't claimed card yet
    if (!isClaimed) {
      return _buildPendingState(borderRadius, theme);
    }

    // State 3: Claimed - user verified and claimed, show full card
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4B32E6), Color(0xFF8712EA), Color(0xFFC50068)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
          child: _buildCardContent(context, theme, avatarSize, isFront: true),
        ),

        // QR Code icon (top-right)
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

  // NEW: Pending state - user is verified but hasn't claimed the card yet
  Widget _buildPendingState(double borderRadius, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: CustomPaint(
        painter: DottedBorderPainter(
          color: Colors.orange.shade600.withValues(alpha: 0.7),
          strokeWidth: 2,
          gap: 5,
          borderRadius: borderRadius,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade700.withValues(alpha: 0.3),
                Colors.orange.shade900.withValues(alpha: 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: const GradientRotation(pi / 2.5),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ayra-logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              // Text(
              //   'Ayra Card Ready',
              //   style: theme.textTheme.headlineSmall?.copyWith(
              //     color: Colors.orange.shade200,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 8),
              Text(
                'Claim your Ayra Card to unlock benefits',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.orange.shade300,
                ),
              ),
              const SizedBox(height: 16),
              // TODO: Add Claim button here
              ElevatedButton(
                onPressed: onClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Claim Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackSide(
    double borderRadius,
    ThemeData theme,
    BuildContext context,
  ) {
    if (credential == null) {
      return Container();
    }

    final qrSize = CredentialHelper.qrCodeSize;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3A3A3A), Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
          child: _buildCardContent(context, theme, qrSize, isFront: false),
        ),
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
        Positioned(
          bottom: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (credential != null) {
                    CredentialViewRoute(
                      $extra: credential as ParsedVerifiableCredential,
                    ).push<void>(context);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F39F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Details',
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
              GestureDetector(
                onTap: () {
                  const BusinessCardRoute().push<void>(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(double size) {
    // Priority: customPhotoPath > avatarAsset > fallback initial
    if (customPhotoPath != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(dartio.File(customPhotoPath!)),
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

    // Handle different avatar data types
    ImageProvider imageProvider;

    if (avatar.startsWith('data:image/')) {
      // Handle base64 encoded images (data:image/png;base64,...)
      try {
        final base64String = avatar.split(
          ',',
        )[1]; // Remove the data:image/...;base64, part
        final bytes = base64Decode(base64String);
        imageProvider = MemoryImage(bytes);
      } catch (e) {
        // Fallback to initial if base64 decoding fails
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
    } else if (avatar.startsWith('http')) {
      // Network image
      imageProvider = NetworkImage(avatar);
    } else {
      // Asset image
      imageProvider = AssetImage(avatar);
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: imageProvider,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildQRCode(double qrSize) {
    if (credential == null) {
      return SizedBox(
        width: qrSize,
        height: qrSize,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.qr_code, size: 60, color: Colors.grey),
          ),
        ),
      );
    }

    // Generate QR data from credential
    final qrData = credential.toString();

    return SizedBox(
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
    );
  }
}

/// Custom painter to draw a dotted/dashed border around a rounded rectangle
class DottedBorderPainter extends CustomPainter {
  DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
    required this.borderRadius,
  });
  final Color color;
  final double strokeWidth;
  final double gap;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final path = Path()..addRRect(rrect);

    // Draw dashed path
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    final dashSpace = gap;
    var distance = 0.0;

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(distance + dashWidth);

        if (start != null && end != null) {
          canvas.drawLine(start.position, end.position, paint);
        }

        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(DottedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        gap != oldDelegate.gap ||
        borderRadius != oldDelegate.borderRadius;
  }
}
