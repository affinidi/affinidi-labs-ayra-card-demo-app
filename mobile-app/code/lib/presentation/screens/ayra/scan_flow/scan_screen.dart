import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../application/services/vdsp_service/vdsp_service.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/services/camera_service/camera_service.dart';
import '../../../../infrastructure/utils/debug_logger.dart';
import '../../../dialogs/qr_code_picker/qr_code_picker.dart';
import 'ayra_scanner_bottom_sheets.dart';
import 'scan_confirm_screen.dart';
import 'scan_result.dart';

class AyraScannerScreen extends ConsumerStatefulWidget {
  const AyraScannerScreen({super.key});

  @override
  ConsumerState<AyraScannerScreen> createState() => _AyraScannerScreenState();
}

class _AyraScannerScreenState extends ConsumerState<AyraScannerScreen>
    with SingleTickerProviderStateMixin {
  static final AppLogger _logger = AppLogger.instance;
  static const _logKey = 'SCANSCR';
  final TextEditingController _qrCodeController = TextEditingController();

  void _handleDetectedCode(String qrData) async {
    if (!mounted) {
      return;
    }
    _logger.info('QR code detected', name: _logKey);
    try {
      final decoded = jsonDecode(qrData);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('QR Data is not a JSON object');
      }
      final result = ScanResult.fromJson(decoded);
      _logger.info('Parsed scan QR data for id=${result.id}', name: _logKey);

      //Show details sheet
      await _showQRCodeDetailsSheet(result);
    } on FormatException catch (error) {
      _logger.warning('Invalid QR data: ${error.message}', name: _logKey);
      _showParseError(error.message);
    } catch (_) {
      _logger.error('Unexpected error parsing QR data', name: _logKey);
      _showParseError('Unable to read QR code. Please try again.');
    }
  }

  Future<void> _showQRCodeDetailsSheet(ScanResult details) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      builder: (context) => ScanConfirmScreen(
        details: details,
        onShareConfirmation: (requestBody, credentials) async {
          debugLog('share confirmation callback invoked with credentials');
          // Show share confirmation bottom sheet
          final result = await _showShareConfirmationBottomSheet(
            requestBody.operation ?? 'Share Request',
            credentials,
          );
          // If user cancelled
          if (result != true) {
            return false;
          }

          return true;
        },
        onComplete: (VdspScanResult result) async {
          debugLog(
            'onComplete callback invoked with status: ${result.status}, message: ${result.message}',
          );

          Navigator.of(context).pop(); // Close scan confirm screen

          if (result.isSuccess || result.isFailure) {
            await _showResultBottomSheet(result);
          }
        },
      ),
    );
  }

  Future<bool?> _showShareConfirmationBottomSheet(
    String operation,
    List<dynamic> credentials,
  ) async {
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => ShareConfirmationBottomSheet(
        operation: operation,
        credentials: credentials.cast(),
        onConfirm: () {
          Navigator.of(context).pop(true); // Return true
        },
        onCancel: () {
          Navigator.of(context).pop(false); // Close share confirmation
          Navigator.of(context).pop(); // Close scan confirm screen
        },
      ),
    );
  }

  Future<void> _showResultBottomSheet(VdspScanResult result) async {
    final isDismissible = result.isFailure;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: isDismissible,
      builder: (context) => ResultBottomSheet(
        result: result,
        onDone: () {
          Navigator.of(context).pop(); // Close result sheet
          // Navigate back to previous screen for both success and failure
          Navigator.of(context).pop(); // Close scan screen
        },
      ),
    );
  }

  void _showParseError(String message) {
    if (!mounted) {
      return;
    }
    _logger.warning('Showing parse error to user: $message', name: _logKey);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleManualQRInput() {
    final qrCode = _qrCodeController.text.trim();
    if (qrCode.isEmpty) {
      _showParseError('Please enter a QR Data');
      return;
    }
    _logger.info('Using manually entered QR data', name: _logKey);
    _handleDetectedCode(qrCode);
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text != null) {
      setState(() {
        _qrCodeController.text = clipboardData!.text!;
      });
    } else {
      _showParseError('Clipboard is empty');
    }
  }

  @override
  void dispose() {
    _qrCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCameraAvailable = ref.watch(
      cameraServiceProvider.select((state) => state.isAvailable ?? false),
    );

    if (!isCameraAvailable) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan QR Code')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.qr_code_2, size: 96),
              const SizedBox(height: 24),
              const Text(
                'Camera not detected on this device. You can continue with a '
                'mock scan response instead.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _qrCodeController,
                decoration: InputDecoration(
                  labelText: 'Enter QR Code Data',
                  hintText: 'Paste QR code JSON here',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: _pasteFromClipboard,
                    tooltip: 'Paste from clipboard',
                  ),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                enableInteractiveSelection: true,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleManualQRInput,
                child: const Text('Submit QR Code'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: QrCodePicker(popOnDetect: false, onDetectCode: _handleDetectedCode),
    );
  }
}
