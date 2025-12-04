import 'package:meeting_place_core/meeting_place_core.dart';
import '../env.dart';

/// Custom logger for MeetingPlaceCore SDK that can be controlled via environment variables
class CustomMpxLogger implements MeetingPlaceCoreSDKLogger {
  final String className;
  final bool _debugMode;

  CustomMpxLogger({required this.className}) : _debugMode = _getDebugMode();

  static bool _getDebugMode() {
    final debugEnv = Env.get('MPX_DEBUG_MODE', 'false').toLowerCase();
    return debugEnv == 'true' || debugEnv == '1' || debugEnv == 'yes';
  }

  @override
  void debug(String message, {String? name}) {
    if (_debugMode) {
      final methodName = name != null ? '.$name' : '';
      print('[DEBUG] $className$methodName: $message');
    }
  }

  @override
  void info(String message, {String? name}) {
    if (_debugMode) {
      final methodName = name != null ? '.$name' : '';
      print('[INFO] $className$methodName: $message');
    }
  }

  @override
  void warning(String message, {String? name}) {
    final methodName = name != null ? '.$name' : '';
    print('[WARNING] $className$methodName: $message');
  }

  @override
  void error(
    String message, {
    Object? error,
    String name = '',
    StackTrace? stackTrace,
  }) {
    final methodName = name.isNotEmpty ? '.$name' : '';
    final errorInfo = error != null ? ' - Error: $error' : '';
    final stackInfo = stackTrace != null ? '\nStackTrace: $stackTrace' : '';
    print('[ERROR] $className$methodName: $message$errorInfo$stackInfo');
  }
}
