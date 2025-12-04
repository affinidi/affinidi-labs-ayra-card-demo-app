import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class QrCodeView extends StatelessWidget {
  const QrCodeView({super.key, required this.data, this.size});

  final String data;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size ?? context.qrScannerTheme.iconSize * 3,
      gapless: true,
      dataModuleStyle: QrDataModuleStyle(
        color: context.colorScheme.primary,
        dataModuleShape: QrDataModuleShape.circle,
      ),
      eyeStyle: QrEyeStyle(
        color: context.colorScheme.primary,
        eyeShape: QrEyeShape.circle,
      ),
    );
  }
}
