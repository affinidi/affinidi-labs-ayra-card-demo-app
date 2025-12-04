import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../storage/storage_factory.dart';
import '../storage/redis_storage.dart';

Response jsonResponse(Map<String, dynamic> data, {int status = 200}) {
  return Response(
    status,
    body: jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );
}

/// List all Redis keys with data (UI-friendly)
Future<Response> listKeysHandler(Request request) async {
  try {
    final storage = await StorageFactory.createDataStorage();

    if (storage is! RedisStorage) {
      return jsonResponse({
        'error':
            'Redis storage not configured. Current backend does not support key listing.',
      }, status: 400);
    }

    // Get query parameters
    final params = request.url.queryParameters;
    final pattern = params['pattern']; // Optional pattern filter
    final includeData =
        params['includeData'] != 'false'; // Include data by default
    final keysOnly = params['keysOnly'] == 'true'; // Just keys, no data

    if (keysOnly) {
      // Just return key names
      final keys = await storage.listAllKeys(pattern: pattern);
      return jsonResponse({
        'success': true,
        'keys': keys,
        'count': keys.length,
        'pattern': pattern ?? '*',
      });
    }

    if (includeData) {
      // Return keys with their data
      final keysWithData = await storage.getAllKeysWithData(pattern: pattern);
      return jsonResponse({
        'success': true,
        'data': keysWithData,
        'count': keysWithData.length,
        'pattern': pattern ?? '*',
      });
    }

    // Return keys with metadata
    final keys = await storage.listAllKeys(pattern: pattern);
    final keysWithInfo = <Map<String, dynamic>>[];

    for (final key in keys.take(100)) {
      // Limit to 100 for performance
      final info = await storage.getKeyInfo(key);
      keysWithInfo.add(info);
    }

    return jsonResponse({
      'success': true,
      'keys': keysWithInfo,
      'count': keys.length,
      'showing': keysWithInfo.length,
      'pattern': pattern ?? '*',
    });
  } catch (e) {
    return jsonResponse({'error': 'Failed to list keys: $e'}, status: 500);
  }
}

/// Delete Redis keys (UI-friendly)
Future<Response> clearKeysHandler(Request request) async {
  try {
    final storage = await StorageFactory.createDataStorage();

    if (storage is! RedisStorage) {
      return jsonResponse({
        'error':
            'Redis storage not configured. Current backend does not support key deletion.',
      }, status: 400);
    }

    final body = await request.readAsString();
    Map<String, dynamic> data = {};

    if (body.isNotEmpty) {
      try {
        data = jsonDecode(body);
      } catch (_) {
        return jsonResponse({
          'error': 'Invalid JSON in request body',
        }, status: 400);
      }
    }

    // Check for dangerous operations
    if (data.containsKey('flushAll') && data['flushAll'] == true) {
      // DANGER: Clear entire database
      await storage.flushAll();
      return jsonResponse({
        'success': true,
        'message': 'All keys deleted from database',
        'clearedKeys': 'ALL',
        'warning': 'Database was completely flushed!',
      });
    }

    // Check if deleting specific key(s)
    if (data.containsKey('key') || data.containsKey('keys')) {
      final keys = data['key'] ?? data['keys'];
      final deletedCount = await storage.deleteKeys(keys);

      return jsonResponse({
        'success': true,
        'message': 'Keys deleted successfully',
        'deletedKeys': deletedCount,
        'keys': keys is String ? [keys] : keys,
      });
    }

    // Delete all keys matching pattern
    final pattern = data['pattern'] as String?;
    if (pattern != null) {
      final keysToDelete = await storage.listAllKeys(pattern: pattern);
      final deletedCount = await storage.deleteKeys(keysToDelete);

      return jsonResponse({
        'success': true,
        'message': 'Keys deleted by pattern',
        'deletedKeys': keysToDelete,
        'deletedCount': deletedCount,
        'pattern': pattern,
      });
    }

    return jsonResponse({
      'error':
          'No keys specified. Provide "key", "keys", "pattern", or "flushAll"',
    }, status: 400);
  } catch (e) {
    return jsonResponse({'error': 'Failed to delete keys: $e'}, status: 500);
  }
}

/// Get Redis server information
Future<Response> redisInfoHandler(Request request) async {
  try {
    final storage = await StorageFactory.createDataStorage();

    if (storage is! RedisStorage) {
      return jsonResponse({
        'error': 'Redis storage not configured.',
      }, status: 400);
    }

    final info = await storage.getInfo();
    final allKeys = await storage.listAllKeys();

    return jsonResponse({
      'success': true,
      'redisInfo': info,
      'totalKeyCount': allKeys.length,
      'connection': {
        'host': storage.host,
        'port': storage.port,
        'secure': storage.secure,
      },
      'applicationPrefix': storage.prefix,
    });
  } catch (e) {
    return jsonResponse({'error': 'Failed to get Redis info: $e'}, status: 500);
  }
}

/// Get specific key data
Future<Response> getKeyHandler(Request request, String key) async {
  try {
    final storage = await StorageFactory.createDataStorage();

    if (storage is! RedisStorage) {
      return jsonResponse({
        'error': 'Redis storage not configured.',
      }, status: 400);
    }

    final keyInfo = await storage.getKeyInfo(key);
    if (!keyInfo['exists']) {
      return jsonResponse({'error': 'Key not found'}, status: 404);
    }

    // Get the actual data
    final rawValue = await storage.getRawValue(key);
    dynamic value = rawValue;

    // Try to parse as JSON
    if (rawValue != null) {
      try {
        value = jsonDecode(rawValue);
      } catch (_) {
        // Keep as string if not valid JSON
      }
    }

    return jsonResponse({
      'success': true,
      'key': key,
      'value': value,
      'rawValue': rawValue,
      'info': keyInfo,
    });
  } catch (e) {
    return jsonResponse({'error': 'Failed to get key: $e'}, status: 500);
  }
}
