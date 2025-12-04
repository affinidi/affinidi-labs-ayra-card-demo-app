import 'dart:convert';
import 'dart:io';
import 'storage_interface.dart';

class FileStorage implements IStorage {
  final String fileName;
  Map<String, dynamic> _records = {};

  FileStorage(this.fileName);

  Future<void> _load() async {
    final file = File(fileName);
    if (await file.exists()) {
      final content = await file.readAsString();
      _records = jsonDecode(content) as Map<String, dynamic>;
    }
  }

  Future<void> _save() async {
    final file = File(fileName);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(_records),
    );
  }

  @override
  Future<T?> get<T>(String key) async {
    await _load();
    final value = _records[key];
    if (value is T) {
      return value;
    }
    return null;
  }

  @override
  Future<List<T>> getCollection<T>(String collectionId) async {
    await _load();
    final values = _records.entries
        .where((r) => r.key.startsWith(collectionId))
        .map((e) => e.value)
        .whereType<T>()
        .toList();
    return values;
  }

  @override
  Future<void> put<T>(String key, T val) async {
    await _load();
    _records[key] = val;
    await _save();
  }

  @override
  Future<void> remove(String key) async {
    await _load();
    _records.remove(key);
    await _save();
  }
}
