import 'dart:convert';
import 'package:redis/redis.dart';
import 'package:ssi/ssi.dart';

class RedisKeyStore implements KeyStore {
  final String host;
  final int port;
  final bool secure;
  final String prefix; // unique namespace per client/app
  late final Command _command;

  RedisKeyStore({
    this.host = 'localhost',
    this.port = 6379,
    this.secure = false,
    required this.prefix,
  });

  Future<void> init() async {
    final conn = RedisConnection();
    _command = secure
        ? await conn.connectSecure(host, port)
        : await conn.connect(host, port);
  }

  /// Internal helper to apply prefix transparently
  String _namespaced(String key) => '${prefix}_$key';

  @override
  Future<void> set(String key, StoredKey value) async {
    await _command.send_object([
      'SET',
      _namespaced(key),
      jsonEncode(value.toJson()),
    ]);
  }

  @override
  Future<StoredKey?> get(String key) async {
    final value = await _command.send_object(['GET', _namespaced(key)]);
    if (value == null) return null;
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return StoredKey.fromJson(decoded);
    }
    return null;
  }

  @override
  Future<void> remove(String key) async {
    await _command.send_object(['DEL', _namespaced(key)]);
  }

  @override
  Future<bool> contains(String key) async {
    final exists = await _command.send_object(['EXISTS', _namespaced(key)]);
    return exists == 1;
  }

  @override
  Future<void> clear() async {
    // Only clear keys belonging to this prefix
    final keys = await _command.send_object(['KEYS', '${prefix}_*']);
    if (keys.isNotEmpty) {
      await _command.send_object(['DEL', ...keys]);
    }
  }
}
