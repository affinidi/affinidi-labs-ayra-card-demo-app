import 'dart:async';

import 'package:affinidi_tdk_vdsp/affinidi_tdk_vdsp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ssi/ssi.dart';

import '../../../../application/services/login_service/issuer_connection_service.dart';
import '../../../../application/services/vdsp_service/vdsp_service.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/utils/debug_logger.dart';
import '../../../../messages/vdsp_trigger_request.dart';
import 'scan_result.dart';

class ScanConfirmScreen extends ConsumerStatefulWidget {
  const ScanConfirmScreen({
    required this.details,
    required this.onShareConfirmation,
    required this.onComplete,
    super.key,
  });

  final ScanResult details;
  final Future<bool> Function(
    VdspQueryDataBody requestBody,
    List<ParsedVerifiableCredential<dynamic>> verifiableCredentials,
  )
  onShareConfirmation;
  final Future<void> Function(VdspScanResult result) onComplete;

  @override
  ConsumerState<ScanConfirmScreen> createState() => _ScanConfirmScreenState();
}

class _ScanConfirmScreenState extends ConsumerState<ScanConfirmScreen> {
  static const _logKey = 'ScanConfirmScreen';
  static final AppLogger _logger = AppLogger.instance;
  bool _isProcessing = false;
  bool _isCheckingTrust = true;
  bool _isTrusted = false;
  String? _statusMessage;
  bool _isActiveProcessing = false; // Track if actively processing vs waiting

  @override
  void initState() {
    super.initState();
    _logger.info(
      'ScanConfirmScreen mounted with DID=${widget.details.permanentDid}',
      name: 'ScanConfirmScreen',
    );
    _checkTrustAndAutoConfirm();
  }

  void _updateProgress(String message, {bool isActive = true}) {
    debugLog(message, name: _logKey, logger: _logger);
    if (mounted) {
      setState(() {
        _statusMessage = message;
        _isActiveProcessing = isActive;
      });
    }
  }

  Future<void> _updateProgressAsync(String message) async {
    _updateProgress(message, isActive: true);
  }

  Future<void> _checkTrustAndAutoConfirm() async {
    _updateProgress('Checking trust status...');
    if (widget.details.permanentDid.isEmpty) {
      _logger.info(
        'No permanent DID found, skipping trust check',
        name: 'ScanConfirmScreen',
      );
      setState(() => _isCheckingTrust = false);
      return;
    }

    try {
      final issuerService = ref.read(issuerConnectionServiceProvider);
      debugLog(
        'widget.details.permanentDid: ${widget.details.permanentDid}',
        name: _logKey,
        logger: _logger,
      );
      final isTrusted = await issuerService.isTrustedDid(
        did: widget.details.permanentDid,
        logKey: 'ScanConfirmScreen',
      );

      debugLog(
        'Trust check result for DID=${widget.details.permanentDid}: $isTrusted',
        name: _logKey,
        logger: _logger,
      );

      if (!mounted) return;

      setState(() {
        _isTrusted = isTrusted;
      });

      if (isTrusted) {
        _updateProgress(
          'This requester is part of the sweetlane-group trusted ecosystem. Auto-confirming...',
        );
        _logger.info(
          'DID is trusted, auto-confirming scan after 1 second delay',
          name: 'ScanConfirmScreen',
        );
        // Add 300 milliseconds delay before auto-confirm
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        await _onConfirmPressed(context);
      } else {
        _updateProgress(
          'This requester is not part of the sweetlane-group trusted ecosystem.',
          isActive: false,
        );
        _logger.info(
          'DID is not trusted, showing confirmation screen',
          name: 'ScanConfirmScreen',
        );
        setState(() => _isCheckingTrust = false);
      }
    } catch (error, stackTrace) {
      debugLog(
        'Error during trust check: $error',
        name: _logKey,
        logger: _logger,
        error: error,
        stackTrace: stackTrace,
      );
      _updateProgress(
        'Error checking verifier trust status, proceeding with manual confirmation',
        isActive: false,
      );
      _logger.error(
        'Error checking verifier trust status, proceeding with manual confirmation',
        error: error,
        stackTrace: stackTrace,
        name: 'ScanConfirmScreen',
      );
      if (mounted) {
        setState(() => _isCheckingTrust = false);
      }
    }
  }

  bool get _hasDetails =>
      widget.details.name.isNotEmpty || widget.details.description.isNotEmpty;

  // Auto-confirm share for trusted DIDs
  Future<bool> _autoConfirmShare(
    VdspQueryDataBody requestBody,
    List<ParsedVerifiableCredential<dynamic>> verifiableCredentials,
  ) async {
    _updateProgress('Auto-confirming credential share...');
    _logger.info(
      'Auto-confirming share for trusted DID',
      name: 'ScanConfirmScreen',
    );
    // Add 300 milliseconds delay before auto-confirm share
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<void> _onConfirmPressed(BuildContext context) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _logger.info(
      'Confirming scan for id=${widget.details.id}',
      name: 'ScanConfirmScreen',
    );

    try {
      final details = widget.details;
      final vdspService = ref.read(vdspServiceProvider);

      _updateProgress('Started processing scan confirmation...');
      await vdspService.confirmScan(
        scanId: details.id,
        recipientDid: details.permanentDid,
        oobUrl: details.oobUrl,
        triggerRequestBody: VpspTriggerRequestBody(
          type: 'VDSP Trigger Request',
          purpose: details.description.isEmpty
              ? 'Requesting access'
              : details.description,
        ),
        onProgress: _updateProgressAsync,
        onShareConfirmation: _isTrusted
            ? _autoConfirmShare
            : widget.onShareConfirmation,
        onComplete: widget.onComplete,
      );

      if (!mounted) return;

      _updateProgress('Waiting for verifier to send sharing request...');
    } on AppException catch (error) {
      _logger.error(
        'Verifier connection failed with app exception',
        error: error,
        name: 'ScanConfirmScreen',
      );
      _updateProgress(error.message, isActive: false);
    } on TimeoutException catch (error) {
      _logger.error(
        'Verifier connection timed out',
        error: error,
        name: 'ScanConfirmScreen',
      );
      _updateProgress(
        'Verifier connection timed out. Please try again.',
        isActive: false,
      );
    } catch (error, stackTrace) {
      debugLog(
        'Scan QR Code error: $error',
        name: _logKey,
        logger: _logger,
        error: error,
        stackTrace: stackTrace,
      );
      _logger.error(
        'Unexpected verifier connection failure',
        error: error,
        stackTrace: stackTrace,
        name: 'ScanConfirmScreen',
      );
      final message = error is AppException ? error.message : error.toString();
      _updateProgress(
        'Something went wrong. Please try again. $message',
        isActive: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.details;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Show loading indicator while checking trust
    if (_isCheckingTrust) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _statusMessage ?? 'Verifying trust status...',
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      details.name,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hasDetails)
                      Card(
                        color: colorScheme.surfaceContainerHigh,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (details.description.isNotEmpty) ...[
                                Text(
                                  'Description',
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  details.description,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      Card(
                        elevation: 0,
                        color: colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'No scan details available.',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Status Message
                    if (_statusMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.15),
                              colorScheme.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            if (_isActiveProcessing)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colorScheme.primary,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isActiveProcessing
                                        ? 'Processing'
                                        : 'Status',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _statusMessage!,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _onConfirmPressed(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Proceed'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
