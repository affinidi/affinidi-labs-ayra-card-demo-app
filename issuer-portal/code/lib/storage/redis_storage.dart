import 'dart:convert';
import 'package:redis/redis.dart';
import 'storage_interface.dart';

class RedisStorage implements IStorage {
  final String host;
  final int port;
  final bool secure;
  final String prefix;
  late final Command _command;

  RedisStorage({
    this.host = 'localhost',
    this.port = 6379,
    this.secure = false,
    required this.prefix, // unique namespace (e.g. "app1" or "agentA")
  });

  Future<void> init() async {
    final conn = RedisConnection();
    _command = secure
        ? await conn.connectSecure(host, port)
        : await conn.connect(host, port);
  }

  String _namespaced(String key) => '${prefix}_$key';

  @override
  Future<T?> get<T>(String key) async {
    final namespacedKey = _namespaced(key);
    final value = await _command.send_object(['GET', namespacedKey]);
    if (value == null) return null;
    final decoded = jsonDecode(value);
    return decoded is T ? decoded : null;
  }

  @override
  Future<void> put<T>(String key, T val) async {
    final namespacedKey = _namespaced(key);
    await _command.send_object(['SET', namespacedKey, jsonEncode(val)]);
  }

  @override
  Future<List<T>> getCollection<T>(String collectionId) async {
    final pattern = '${prefix}_$collectionId*';
    final keys = await _command.send_object(['KEYS', pattern]);
    final results = <T>[];
    for (final fullKey in keys) {
      // Extract original key if you ever need it
      final key = fullKey.toString().substring(prefix.length + 1);
      final val = await get<T>(key);
      if (val != null) results.add(val);
    }
    return results;
  }

  @override
  Future<void> remove(String key) async {
    final namespacedKey = _namespaced(key);
    await _command.send_object(['DEL', namespacedKey]);
  }

  /// List all keys in Redis (ignoring prefix restrictions for UI purposes)
  Future<List<String>> listAllKeys({String? pattern}) async {
    final searchPattern = pattern ?? '*';
    final keys = await _command.send_object(['KEYS', searchPattern]);
    return List<String>.from(keys);
  }

  /// Get all keys with their data
  Future<Map<String, dynamic>> getAllKeysWithData({String? pattern}) async {
    final keys = await listAllKeys(pattern: pattern);
    final result = <String, dynamic>{};

    for (final key in keys) {
      try {
        final value = await _command.send_object(['GET', key]);
        if (value != null) {
          // Try to parse as JSON, fallback to raw string
          try {
            result[key] = jsonDecode(value);
          } catch (_) {
            result[key] = value;
          }
        } else {
          result[key] = null;
        }
      } catch (e) {
        result[key] = 'Error: $e';
      }
    }

    return result;
  }

  /// Get key type and additional info
  Future<Map<String, dynamic>> getKeyInfo(String key) async {
    final type = await _command.send_object(['TYPE', key]);
    final ttl = await _command.send_object(['TTL', key]);
    final exists = await _command.send_object(['EXISTS', key]);

    Map<String, dynamic> info = {
      'key': key,
      'type': type,
      'ttl': ttl,
      'exists': exists == 1,
    };

    // Get size/length based on type
    switch (type) {
      case 'string':
        final length = await _command.send_object(['STRLEN', key]);
        info['length'] = length;
        break;
      case 'list':
        final length = await _command.send_object(['LLEN', key]);
        info['length'] = length;
        break;
      case 'set':
        final length = await _command.send_object(['SCARD', key]);
        info['length'] = length;
        break;
      case 'hash':
        final length = await _command.send_object(['HLEN', key]);
        info['length'] = length;
        break;
      case 'zset':
        final length = await _command.send_object(['ZCARD', key]);
        info['length'] = length;
        break;
    }

    return info;
  }

  /// Delete specific key(s) - can be single key or list of keys
  Future<int> deleteKeys(dynamic keys) async {
    List<String> keyList;
    if (keys is String) {
      keyList = [keys];
    } else if (keys is List) {
      keyList = keys.cast<String>();
    } else {
      throw ArgumentError('Keys must be String or List<String>');
    }

    if (keyList.isEmpty) return 0;

    final result = await _command.send_object(['DEL', ...keyList]);
    return result is int ? result : keyList.length;
  }

  /// Clear ALL keys in the database (DANGEROUS!)
  Future<void> flushAll() async {
    await _command.send_object(['FLUSHDB']);
  }

  /// List all keys matching a pattern (default: all keys with this prefix)
  Future<List<String>> listKeys({String? pattern}) async {
    final searchPattern = pattern ?? '${prefix}_*';
    final keys = await _command.send_object(['KEYS', searchPattern]);
    return List<String>.from(keys);
  }

  /// Clear all keys matching a pattern
  Future<int> clearKeys({String? pattern}) async {
    final keys = await listKeys(pattern: pattern);
    if (keys.isEmpty) return 0;

    final result = await _command.send_object(['DEL', ...keys]);
    return result is int ? result : keys.length;
  }

  /// Get raw value from Redis
  Future<String?> getRawValue(String key) async {
    return await _command.send_object(['GET', key]);
  }

  /// Get Redis info
  Future<Map<String, String>> getInfo() async {
    final info = await _command.send_object(['INFO', 'keyspace']);
    final lines = info.toString().split('\n');
    final result = <String, String>{};

    for (final line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          result[parts[0].trim()] = parts[1].trim();
        }
      }
    }

    return result;
  }
}
