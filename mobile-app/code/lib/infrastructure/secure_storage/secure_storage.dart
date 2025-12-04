import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart' hide KeyPair;

import '../providers/app_logger_provider.dart';
import '../providers/shared_preferences_provider.dart';

enum _Key { mediatorDid, debugMode, databasePassphrase, showMeetingPlaceQr }

/// A wrapper around [FlutterSecureStorage] that implements [KeyRepository].
///
/// Provides secure storage for wallet seeds, mediator DIDs,
/// database passphrases, and other application secrets.
/// Supports both Android (EncryptedSharedPreferences) and iOS (Keychain).
class SecureStorage implements KeyRepository, KeyStore {
  /// Creates a new [SecureStorage] instance.
  ///
  /// [secureStorage] - An optional custom [FlutterSecureStorage] instance.
  /// If not provided, a platform-configured default is used.
  SecureStorage([FlutterSecureStorage? secureStorage])
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.unlocked_this_device,
            ),
          );

  Future<String>? _passphraseFuture;

  final FlutterSecureStorage _secureStorage;

  static final _didPrefix = 'did_';
  static final _indexPrefix = 'index_';
  static final _keyPairIndex = 'keypair_';

  @override
  Future<StoredKey?> get(String key) async {
    final jsonString = await _secureStorage.read(key: key);
    if (jsonString == null) return null;

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return StoredKey.fromJson(json);
  }

  @override
  Future<void> set(String key, StoredKey value) async {
    await _secureStorage.write(key: key, value: jsonEncode(value));
  }

  @override
  Future<bool> contains(String key) => _secureStorage.containsKey(key: key);

  @override
  Future<void> remove(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Clears all stored values from secure storage.
  @override
  Future<void> clear() async {
    await _secureStorage.deleteAll();
  }

  /// Retrieves the keyId associated with the given [did].
  ///
  /// [did] - The did.
  @override
  Future<String?> getKeyIdByDid({required String did}) =>
      _secureStorage.read(key: '$_didPrefix$did');

  /// Saves the [did] associated with the given [keyId].
  ///
  /// [keyId] - The key to be associated to the did
  /// [did] - The did.
  @override
  Future<void> saveKeyIdForDid({required String keyId, required String did}) =>
      _secureStorage.write(key: '$_didPrefix$did', value: keyId);

  /// Gets the last used account index.
  ///
  /// Defaults to `1` if no index is stored.
  @override
  Future<int> getLastAccountIndex() async {
    final value = await _secureStorage.read(key: _indexPrefix);
    return int.tryParse(value ?? '') ?? 1;
  }

  /// Sets the last used account [index].
  ///
  /// [index] - The most recent account index to persist.
  @override
  Future<void> setLastAccountIndex(int index) {
    return _secureStorage.write(key: _indexPrefix, value: '$index');
  }

  /// Retrieves the preferred mediator DID, if set.
  Future<String?> getPreferredMediatorDid() async {
    final value = await _secureStorage.read(key: _Key.mediatorDid.name);
    return value;
  }

  /// Stores the preferred mediator DID.
  ///
  /// [value] - The mediator DID to persist.
  Future<void> setPreferredMediatorDid(String value) {
    return _secureStorage.write(key: _Key.mediatorDid.name, value: value);
  }

  Future<bool?> getDebugMode() async {
    final value = await _secureStorage.read(key: _Key.debugMode.name);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Saves the [debugMode] flag.
  ///
  /// [debugMode] - Whether the app should run in debug mode.
  Future<void> saveDebugMode(bool debugMode) {
    return _secureStorage.write(
      key: _Key.debugMode.name,
      value: debugMode.toString(),
    );
  }

  /// Retrieves the flag indicating whether to show the meeting place QR code.
  Future<bool?> getShouldShowMeetingPlaceQR() async {
    final value = await _secureStorage.read(key: _Key.showMeetingPlaceQr.name);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  /// Saves the flag indicating whether to show the meeting place QR code.
  ///
  /// [showQr] - Whether the meeting place QR code should be shown.
  Future<void> saveShouldShowMeetingPlaceQR(bool showQr) {
    return _secureStorage.write(
      key: _Key.showMeetingPlaceQr.name,
      value: showQr.toString(),
    );
  }

  /// Provides a database passphrase.
  ///
  /// - Returns an existing passphrase if found.
  /// - Otherwise generates and stores a new one.
  Future<String> provideDatabasePassphrase() async {
    _passphraseFuture ??= _loadOrCreatePassphrase();
    try {
      return await _passphraseFuture!;
    } finally {
      _passphraseFuture = null;
    }
  }

  /// Loads an existing passphrase or creates a new one if not found.
  Future<String> _loadOrCreatePassphrase() async {
    var passphrase = await _secureStorage.read(
      key: _Key.databasePassphrase.name,
    );
    if (passphrase?.isNotEmpty == true) return passphrase!;

    passphrase = _generateRandomPassphrase();
    await _secureStorage.write(
      key: _Key.databasePassphrase.name,
      value: passphrase,
    );
    return passphrase;
  }

  /// Generates a secure random byte array of the given [length].
  ///
  /// [length] - The number of bytes to generate.
  Uint8List _generateRandomBytes(int length) {
    final rng = math.Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  /// Generates a random base64-encoded passphrase.
  ///
  /// [length] - The number of random bytes used (default: 32).
  String _generateRandomPassphrase([int length = 32]) {
    final bytes = _generateRandomBytes(length);
    return base64Url.encode(bytes);
  }

  @override
  Future<KeyPair?> getKeyPair(String did) async {
    final value = await _secureStorage.read(key: '$_keyPairIndex$did');
    if (value == null) return null;
    return KeyPair.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  @override
  Future<void> saveKeyPair({
    required Uint8List privateKeyBytes,
    required Uint8List publicKeyBytes,
    required String did,
  }) {
    return _secureStorage.write(
      key: '$_keyPairIndex$did',
      value: jsonEncode({
        'privateKeyBytes': privateKeyBytes,
        'publicKeyBytes': publicKeyBytes,
      }),
    );
  }
}

/// A provider that initializes and supplies [SecureStorage].
///
/// - Clears storage on a fresh install
/// (based on [SharedPreferencesKeys.alreadyInstalled]).
/// - Ensures consistent secure storage across the app lifecycle.
final secureStorageProvider = FutureProvider<SecureStorage>((ref) async {
  final storage = SecureStorage();
  const logKey = 'secureStorageProvider';

  final prefs = await ref.read(sharedPreferencesProvider.future);
  if (prefs.getBool(SharedPreferencesKeys.alreadyInstalled.name) != true) {
    final logger = ref.read(appLoggerProvider);
    logger.info('Fresh install: clearing Keychain', name: logKey);

    await storage.clear();
    await prefs.setBool(SharedPreferencesKeys.alreadyInstalled.name, true);
  }

  return storage;
}, name: 'secureStorageProvider');
