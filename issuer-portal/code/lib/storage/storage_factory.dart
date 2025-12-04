import 'dart:io';
import 'package:ssi/ssi.dart';

import '../env.dart';
import 'storage_interface.dart';
import 'file_storage.dart';
import 'redis_storage.dart'; // You’ll create this
import 'file_key_store.dart';
import 'redis_key_store.dart';

class StorageFactory {
  static Future<IStorage> createDataStorage() async {
    return createStorage("./data/db.json");
  }

  static Future<IStorage> createStorage(String fileName) async {
    final storage = Env.get('STORAGE_BACKEND', '');
    final redisHost = Env.get('REDIS_HOST', 'localhost');
    final redisPort = Env.get('REDIS_PORT', '6379');
    final redisSecure = Env.get('REDIS_SECURE', "false");

    if (storage == 'redis') {
      final port = int.tryParse(redisPort) ?? 6379;
      final secure = bool.tryParse(redisSecure) ?? false;
      final storage = RedisStorage(
        host: redisHost,
        port: port,
        secure: secure,
        prefix: "iss",
      );
      await storage.init();
      // print(
      //   '[StorageFactory] Using RedisStorage at $redisHost:$port in ${secure ? 'secure' : 'non-secure'} mode',
      // );
      return storage;
    } else {
      final file = File(fileName);
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        // print('Created directory: ${dir.path}');
      }
      // print('[StorageFactory] Using FileStorage at $fileName');
      return FileStorage(fileName);
    }
  }

  static Future<KeyStore> createKeyStore(String fileName) async {
    final filePath = './data/$fileName';
    final storage = Env.get('STORAGE_BACKEND', '');
    final redisHost = Env.get('REDIS_HOST', 'localhost');
    final redisPort = Env.get('REDIS_PORT', '6379');
    final redisSecure = Env.get('REDIS_SECURE', 'false');

    if (storage == 'redis') {
      final port = int.tryParse(redisPort) ?? 6379;
      final secure = bool.tryParse(redisSecure) ?? false;
      final keyStore = RedisKeyStore(
        host: redisHost,
        port: port,
        secure: secure,
        prefix: filePath,
      );
      await keyStore.init();
      // print(
      //   '[StorageFactory] Using RedisKeyStore at $redisHost:$port in ${secure ? 'secure' : 'non-secure'} mode',
      // );
      return keyStore;
    } else {
      final file = File(filePath);
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        // print('Created directory: ${dir.path}');
      }
      // print('[StorageFactory] Using FileKeyStore at $filePath');
      return FileKeyStore(filePath: filePath);
    }
  }
}
