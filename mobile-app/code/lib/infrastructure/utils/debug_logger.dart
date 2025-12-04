import 'package:flutter/foundation.dart';
import '../loggers/app_logger/app_logger.dart';

/// Logs a debug message to both the console (via debugPrint) and the AppLogger.
///
/// This utility function ensures logs appear in both the terminal output
/// and the in-app debug panel.
///
/// Example:
/// ```dart
/// debugLog('User logged in', name: 'AUTH', logger: _logger);
/// ```
void debugLog(
  String message, {
  String name = '',
  AppLogger? logger,
  Object? error,
  StackTrace? stackTrace,
}) {
  // Print to terminal (like debugPrint)
  debugPrint(message);
  if (stackTrace != null) {
    debugPrintStack(stackTrace: stackTrace);
  }

  // Also log to AppLogger if provided
  if (logger != null) {
    if (error != null) {
      logger.error(message, error: error, stackTrace: stackTrace, name: name);
    } else {
      logger.info(message, name: name);
    }
  }
}
