import 'dart:developer';

import 'app_log_entry.dart';
import 'logger_target.dart';

class ConsoleLoggerTarget implements LoggerTarget {
  final List<AppLogEntry> _logs = [];
  @override
  List<AppLogEntry> get logs => List.unmodifiable(_logs);

  @override
  void logInfo(String loggerName, String message) {
    log('[INFO] $message', name: loggerName);
  }

  @override
  void logError(String loggerName, String message) {
    log('[ERROR] $message', name: loggerName);
  }

  @override
  void logWarning(String loggerName, String message) {
    log('[WARNING] $message', name: loggerName);
  }

  @override
  void logDebug(String loggerName, String message) {
    log('[DEBUG] $message', name: loggerName);
  }

  @override
  void clearLogs() {
    // Console doesn't need to clear anything
  }
}
