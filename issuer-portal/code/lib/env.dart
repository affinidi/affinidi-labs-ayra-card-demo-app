import 'package:dotenv/dotenv.dart';

class Env {
  static final DotEnv _env = DotEnv(includePlatformEnvironment: true);

  static void load() {
    try {
      _env.load();
    } catch (e) {
      // .env file not found - this is expected in Docker containers
      // Environment variables will be provided via docker-compose or system environment
      print(
        '[ENV] .env file not found, using system environment variables only',
      );
    }
  }

  static String get(String name, [String? fallback]) {
    return _env[name] ?? fallback ?? '';
  }

  static bool isDefined(String name) => _env.isDefined(name);
}
