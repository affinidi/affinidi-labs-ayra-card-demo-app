import 'dart:convert';
import 'dart:io';
import 'package:ssi/ssi.dart';

class FileKeyStore implements KeyStore {
  final String filePath;
  final Map<String, StoredKey> _keyPairStore = {};

  FileKeyStore({required this.filePath});

  Future<void> _load() async {
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      final Map<String, dynamic> jsonMap = jsonDecode(content);
      _keyPairStore.clear();
      jsonMap.forEach((key, value) {
        _keyPairStore[key] = StoredKey.fromJson(value);
      });
    }
  }

  Future<void> _save() async {
    final file = File(filePath);
    final jsonMap = _keyPairStore.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await file.writeAsString(JsonEncoder.withIndent('  ').convert(jsonMap));
  }

  @override
  Future<void> set(String key, StoredKey value) async {
    await _load();
    _keyPairStore[key] = value;
    await _save();
  }

  @override
  Future<StoredKey?> get(String key) async {
    await _load();
    return _keyPairStore[key];
  }

  @override
  Future<void> remove(String key) async {
    await _load();
    _keyPairStore.remove(key);
    await _save();
  }

  @override
  Future<bool> contains(String key) async {
    await _load();
    return _keyPairStore.containsKey(key);
  }

  @override
  Future<void> clear() async {
    _keyPairStore.clear();
    final file = File(filePath);
    if (await file.exists()) {
      await file.writeAsString('{}');
    }
  }
}
