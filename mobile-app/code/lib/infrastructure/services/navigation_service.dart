import 'package:affinidi_tdk_vdsp/affinidi_tdk_vdsp.dart';
import 'package:flutter/material.dart';
import 'package:ssi/ssi.dart';

import '../../application/services/vdsp_service/vdsp_service.dart';
import '../../navigation/router_config_provider.dart';
import '../../presentation/screens/ayra/scan_flow/ayra_scanner_bottom_sheets.dart';
import '../utils/debug_logger.dart';

/// Global navigation service that allows showing screens/dialogs from anywhere
/// in the app, including from service layers that don't have BuildContext.
///
/// This service uses the existing rootNavigatorKey from router_config_provider
/// to access the Navigator without requiring a BuildContext to be passed around.
class NavigationService {
  /// Get the current BuildContext from the navigator
  static BuildContext? get currentContext => rootNavigatorKey.currentContext;

  /// Show consent bottom sheet for VDSP credential sharing
  ///
  /// Returns true if user confirms, false if user cancels or sheet is dismissed
  static Future<bool> showConsentBottomSheet(
    VdspQueryDataBody requestBody,
    List<ParsedVerifiableCredential<dynamic>> credentials,
  ) async {
    final context = currentContext;
    if (context == null) {
      debugLog(
        '[NavigationService] Cannot show consent sheet: no context available',
      );
      return false;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => ShareConfirmationBottomSheet(
        operation: 'Share Credentials',
        credentials: credentials,
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      ),
    );

    return result ?? false;
  }

  /// Show result bottom sheet after VDSP operation completes
  static Future<void> showResultBottomSheet(VdspScanResult result) async {
    final context = currentContext;
    if (context == null) {
      debugLog(
        '[NavigationService] Cannot show result sheet: no context available',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: result.isFailure,
      builder: (context) => ResultBottomSheet(
        result: result,
        onDone: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
