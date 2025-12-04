import 'package:meeting_place_core/meeting_place_core.dart';

import 'app_log_entry.dart';
import 'console_logger_target.dart';
import 'debug_log_collector_target.dart';
import 'logger_target.dart';

class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();

  static final AppLogger instance = _instance;

  final DebugLogCollectorTarget _debugCollector = DebugLogCollectorTarget();

  late final List<LoggerTarget> _loggers = <LoggerTarget>[
    ConsoleLoggerTarget(),
    _debugCollector,
  ];

  List<AppLogEntry> get logs => _debugCollector.logs;

  Stream<AppLogEntry> get logStream => _debugCollector.logStream;

  void info(String message, {String name = ''}) {
    for (final logger in _loggers) {
      logger.logInfo(name, message);
    }
  }

  Object? _getOriginalException(Object? error) {
    if (error == null) return null;

    if (error is MeetingPlaceCoreSDKException) return error.innerException;
    return null;
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = '',
  }) {
    final fullMessage = [
      message,
      error,
      _getOriginalException(error),
      stackTrace,
    ].nonNulls.join('\n');
    for (final logger in _loggers) {
      logger.logError(name, fullMessage);
    }
  }

  void warning(String message, {String name = ''}) {
    for (final logger in _loggers) {
      logger.logWarning(name, message);
    }
  }

  void debug(String message, {String name = ''}) {
    for (final logger in _loggers) {
      logger.logDebug(name, message);
    }
  }

  void clearLogs() {
    for (final logger in _loggers) {
      logger.clearLogs();
    }
  }
}
