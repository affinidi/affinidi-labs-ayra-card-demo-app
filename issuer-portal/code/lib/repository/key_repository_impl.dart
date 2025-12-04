import 'dart:convert';
import 'dart:typed_data';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../storage/storage_interface.dart';

class KeyRepositoryImpl implements KeyRepository {
  static final String _didPrefix = 'did_';
  static final String _indexPrefix = 'index_';
  static final String _keyPairIndex = 'keypair_';

  final IStorage _storage;

  KeyRepositoryImpl({required IStorage storage}) : _storage = storage;

  @override
  Future<int> getLastAccountIndex() async {
    return (await _storage.get<int?>(_indexPrefix)) ?? 0;
  }

  @override
  Future<String?> getKeyIdByDid({required String did}) async {
    return _storage.get<String?>('$_didPrefix$did');
  }

  @override
  Future<void> saveKeyIdForDid({
    required String keyId,
    required String did,
  }) async {
    await _storage.put('$_didPrefix$did', keyId);
  }

  @override
  Future<void> setLastAccountIndex(int index) {
    return _storage.put(_indexPrefix, index);
  }

  @override
  Future<KeyPair?> getKeyPair(String did) async {
    final value = await _storage.get<String?>('$_keyPairIndex$did');
    if (value == null) return null;
    return KeyPair.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> saveKeyPair({
    required Uint8List privateKeyBytes,
    required Uint8List publicKeyBytes,
    required String did,
  }) {
    return _storage.put(
      '$_keyPairIndex$did',
      jsonEncode({
        'privateKeyBytes': privateKeyBytes,
        'publicKeyBytes': publicKeyBytes,
      }),
    );
  }
}
