import 'package:dotenv/dotenv.dart';

class Env {
  static final DotEnv _env = DotEnv(includePlatformEnvironment: true);

  static void load() {
    _env.load();
  }

  static String get(String name, [String? fallback]) {
    return _env[name] ?? fallback ?? '';
  }

  static bool isDefined(String name) => _env.isDefined(name);
}
