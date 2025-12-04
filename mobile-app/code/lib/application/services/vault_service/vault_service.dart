import 'dart:async';

import 'package:affinidi_tdk_vault/affinidi_tdk_vault.dart';
import 'package:affinidi_tdk_vault_flutter_utils/vault_flutter_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart';

import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/vault_tdk_provider.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import 'vault_service_state.dart';

part 'vault_service.g.dart';

@Riverpod(keepAlive: true)
class VaultService extends _$VaultService {
  static const _logKey = 'VAULTSVC';
  static const _vaultId = 'ayra';
  static const _defaultProfileName = 'Sweetlane Bank';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  Future<void>? _initializationFuture;

  @override
  VaultServiceState build() {
    Future(() async {
      try {
        await _ensureVaultInitialized();
      } catch (e) {
        _logger.error('error ${e.toString()}', name: _logKey);
      }
    });

    return VaultServiceState();
  }

  Future<Profile> _createProfile(
    Vault vault, {
    required String profileName,
    String? description,
  }) async {
    _logger.info('Fetching all profiles', name: _logKey);
    var profiles = await vault.listProfiles();
    var myProfile = profiles
        .where((profile) => profile.name == profileName)
        .firstOrNull;

    for (var i = 0; i < profiles.length; i++) {
      _logger.info('Profile : ${profiles[i].did}', name: _logKey);
    }
    _logger.info('Found ${profiles.length} profiles', name: _logKey);
    //if profile does not exist, creating a new one
    if (myProfile == null) {
      await vault.defaultProfileRepository.createProfile(
        name: profileName,
        description: description,
      );
      _logger.info('Created $profileName profile', name: _logKey);
      profiles = await vault.listProfiles();
      myProfile = profiles
          .where((profile) => profile.name == profileName)
          .first;
    }
    return myProfile;
  }

  Future<Profile> getProfile({String profileName = _defaultProfileName}) async {
    await _ensureVaultInitialized();

    if (profileName == _defaultProfileName && state.defaultProfile != null) {
      return state.defaultProfile!;
    }

    final profile = await _createProfile(
      state.vault!,
      profileName: profileName,
    );

    if (profileName == _defaultProfileName) {
      state = state.copyWith(defaultProfile: profile);
    }

    return profile;
  }

  Future<void> saveCredential({required String credential}) async {
    debugLog(
      'VaultService: saveCredential called',
      name: _logKey,
      logger: _logger,
    );
    await _ensureVaultInitialized();
    final profile = state.defaultProfile!;
    final parsedCredential = UniversalParser.parse(credential);

    // Check if credential of same type already exists
    final credentialTypes = parsedCredential.type;
    final existingCredentials = state.claimedCredentials ?? [];
    for (var existingCred in existingCredentials) {
      // Check if any type matches (excluding 'VerifiableCredential' base type)
      final existingTypes = existingCred.verifiableCredential.type;
      final hasMatchingType = credentialTypes.any(
        (type) =>
            type != 'VerifiableCredential' && existingTypes.contains(type),
      );

      if (hasMatchingType) {
        debugLog(
          'VaultService: Found existing credential of same type (${existingCred.id}), deleting...',
          name: _logKey,
          logger: _logger,
        );
        await profile.defaultCredentialStorage?.deleteCredential(
          digitalCredentialId: existingCred.id,
        );
        debugLog(
          'VaultService: Existing credential deleted',
          name: _logKey,
          logger: _logger,
        );
        break; // Only delete the first match
      }
    }

    await profile.defaultCredentialStorage!.saveCredential(
      verifiableCredential: parsedCredential,
    );
    debugLog(
      'VaultService: Credential saved to storage, now reloading...',
      name: _logKey,
      logger: _logger,
    );

    // Reload credentials after saving to update cache
    await getCredentials(force: true);
    debugLog(
      'VaultService: After reload, state has ${state.claimedCredentials?.length} credentials',
      name: _logKey,
      logger: _logger,
    );
  }

  Future<void> deleteCredential(String digitalCredentialId) async {
    await _ensureVaultInitialized();
    final profile = state.defaultProfile!;
    final credentials = await profile.defaultCredentialStorage
        ?.listCredentials();
    for (var credential in credentials!.items) {
      if (credential.id == digitalCredentialId) {
        _logger.info('Deleting Credential $digitalCredentialId', name: _logKey);
        await profile.defaultCredentialStorage?.deleteCredential(
          digitalCredentialId: digitalCredentialId,
        );
        break; // Exit loop after finding and deleting
      }
    }

    // Reload credentials after deletion to update cache
    await getCredentials(force: true);
  }

  Future<void> deleteVault() async {
    await _ensureVaultInitialized();
    var profiles = await state.vault!.listProfiles();
    for (var profile in profiles) {
      final credentials = await profile.defaultCredentialStorage
          ?.listCredentials();
      for (var credential in credentials!.items) {
        _logger.info(
          'Deleting Credential ${credential.id} from ${profile.name}',
          name: _logKey,
        );
        await profile.defaultCredentialStorage?.deleteCredential(
          digitalCredentialId: credential.id,
        );
      }
    }
    state = state.copyWith(claimedCredentials: []);
  }

  Future<void> getCredentials({bool force = false}) async {
    debugLog(
      'VaultService: getCredentials called (force=$force)',
      name: _logKey,
      logger: _logger,
    );

    await _ensureVaultInitialized();
    final profile = state.defaultProfile!;
    _logger.info('profile ${profile.name}', name: _logKey);
    final result = await profile.defaultCredentialStorage?.listCredentials();
    debugLog(
      'VaultService: Fetched ${result?.items.length} credentials from vault storage',
      name: _logKey,
      logger: _logger,
    );

    state = state.copyWith(claimedCredentials: result?.items);

    debugLog(
      'VaultService: State updated with ${state.claimedCredentials?.length} credentials',
      name: _logKey,
      logger: _logger,
    );
  }

  Future<ParsedVerifiableCredential?> getCredentialByType(String type) async {
    await getCredentials();
    final digitalCredentials = state.claimedCredentials ?? const [];

    final filtered = digitalCredentials
        .where((credential) {
          final typeList = credential.verifiableCredential.type;
          return typeList.contains(type);
        })
        .map((c) => c.verifiableCredential as ParsedVerifiableCredential)
        .toList();

    return filtered.isNotEmpty ? filtered.first : null;
  }

  Future<Set<String>> getAllCredentialTypes() async {
    await getCredentials();
    final digitalCredentials = state.claimedCredentials ?? const [];

    final types = digitalCredentials
        .map(
          (cred) =>
              cred.verifiableCredential.type.contains('VerifiableCredential')
              ? cred.verifiableCredential.type.first
              : cred.verifiableCredential.type.last,
        )
        .toSet();

    return types;
  }

  Future<DidManager> getDidManager() async {
    await _ensureVaultInitialized();

    final keyStore = FlutterSecureVaultStore(_vaultId);
    var seed = await keyStore.getSeed();
    if (seed == null) {
      _logger.error(
        'No seed found in secure storage after initialization attempt',
        name: _logKey,
      );

      //Trying again to initialize vault
      await initializeVault();
      seed = await keyStore.getSeed();
      if (seed == null) {
        throw AppException(
          'No seed found in secure storage',
          code: AppExceptionType.other.name,
        );
      }
    }
    final wallet = Bip32Wallet.fromSeed(seed);

    final profile = state.defaultProfile!;
    final keyId = "m/44'/60'/${profile.accountIndex}'/0'/0'";
    final didManager = DidKeyManager(wallet: wallet, store: InMemoryDidStore());

    await didManager.addVerificationMethod(keyId);
    return didManager;
  }

  Future<void> _ensureVaultInitialized() async {
    if (state.vault != null && state.defaultProfile != null) {
      return;
    }

    if (_initializationFuture != null) {
      return _initializationFuture!;
    }

    _initializationFuture = initializeVault();
    try {
      await _initializationFuture;
    } finally {
      _initializationFuture = null;
    }
  }

  Future<void> initializeVault() async {
    try {
      // ignore: omit_local_variable_types
      final Vault vault =
          state.vault ?? await ref.read(vaultTdkProvider(_vaultId).future);

      await vault.ensureInitialized();

      _logger.info('Creating or fetching default profile', name: _logKey);

      final profile = await _createProfile(
        vault,
        profileName: _defaultProfileName,
        description: 'This is a Default profile',
      );

      state = state.copyWith(vault: vault, defaultProfile: profile);
    } catch (error, stackTrace) {
      _logger.error(
        'Vault initialization failed',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }
}
