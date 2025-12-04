import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ssi/ssi.dart';

import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/channel_repository_drift_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/utils/debug_logger.dart';
import '../../../presentation/screens/ayra/ayra_onboarding.dart';
import '../authentication_service/authentication_service.dart';
import '../login_service/login_service.dart';
import '../vault_service/vault_service.dart';

part 'ayra_service.g.dart';

class AyraAuthState {
  const AyraAuthState({
    this.name,
    this.isVerified = false,
    this.isClaimed = false,
    this.claimData,
  });
  final String? name; // null means not logged in
  final bool isVerified; // true means IDV completed
  final bool isClaimed; // true means Ayra Card claimed
  final Map<String, dynamic>? claimData;

  AyraAuthState copyWith({
    String? name,
    bool? isVerified,
    bool? isClaimed,
    Map<String, dynamic>? claimData,
  }) {
    return AyraAuthState(
      name: name ?? this.name,
      isVerified: isVerified ?? this.isVerified,
      isClaimed: isClaimed ?? this.isClaimed,
      claimData: claimData ?? this.claimData,
    );
  }
}

@riverpod
class AyraAuth extends _$AyraAuth {
  static const _logKey = 'AyraAuth';
  late final _logger = ref.read(appLoggerProvider);

  @override
  AyraAuthState build() {
    return const AyraAuthState();
  }

  void login(String name) {
    state = state.copyWith(name: name);
  }

  Future<void> logout() async {
    // Clear all data/cache and reset to fresh state
    await _clearAllData();
  }

  Future<void> _clearAllData() async {
    try {
      debugLog(
        'Starting comprehensive data clearing process...',
        name: _logKey,
        logger: _logger,
      );

      // Clear vault credentials first (before databases, as it might need database access)
      await _clearVaultData();
      debugLog('Cleared vault data', name: _logKey, logger: _logger);

      // Clear all databases (must be done before clearing secure storage which has passphrases)
      await _clearAllDatabases();
      debugLog('Cleared all databases', name: _logKey, logger: _logger);

      // Clear shared preferences (email, displayName, provider, etc.)
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.remove(SharedPreferencesKeys.displayName.name);
      await prefs.remove(SharedPreferencesKeys.email.name);
      await prefs.remove(SharedPreferencesKeys.provider.name);
      await prefs.remove(SharedPreferencesKeys.issuerDidCache.name);
      debugLog('Cleared shared preferences', name: _logKey, logger: _logger);

      // Clear secure vault store LAST (contains database passphrases)
      // await _clearSecureVaultStore();
      // debugLog('Cleared secure vault store');

      //Clear login state
      final loginService = ref.read(loginServiceProvider.notifier);
      loginService.reset();

      //Reset AyraAuth state
      state = const AyraAuthState();

      //Clear authentication state
      final authState = ref.read(authenticationServiceProvider.notifier);
      authState.reset();

      //Clear onboarding state
      final onboardingState = ref.read(ayraOnboardingProvider.notifier);
      onboardingState.reset();

      debugLog(
        'Comprehensive data clearing completed successfully',
        name: _logKey,
        logger: _logger,
      );
    } catch (e) {
      // Log error but don't prevent logout
      debugLog(
        'Error clearing data during logout: $e',
        name: _logKey,
        logger: _logger,
        error: e,
      );
    }
  }

  Future<void> _clearAllDatabases() async {
    try {
      final channels = await ref.watch(allChannelsProvider.future);

      final repository = await ref.read(channelRepositoryDriftProvider.future);

      // Delete all channels
      for (final channel in channels) {
        await repository.deleteChannel(channel);
      }
    } catch (error) {
      debugLog(
        'Error clearing channels database: $error',
        name: _logKey,
        logger: _logger,
        error: error,
      );
    }
  }

  Future<void> _clearVaultData() async {
    try {
      await ref.read(vaultServiceProvider.notifier).deleteVault();

      debugLog('Deleted vault data', name: _logKey, logger: _logger);
    } catch (error) {
      debugLog(
        'Error clearing vault data: $error',
        name: _logKey,
        logger: _logger,
        error: error,
      );
      // Don't throw - we want to continue with logout even if this fails
    }
  }

  /*
  Future<void> _clearSecureVaultStore() async {
    try {
      // Clear the FlutterSecureVaultStore which contains the vault seed/keys
      final secureStorage = await ref.read(secureStorageProvider.future);
      await secureStorage.clear();

      debugLog('Cleared secure vault store');
    } catch (error) {
      debugLog('Error clearing secure vault store: $error');
      // Don't throw - we want to continue with logout even if this fails
    }
  }
  */

  void setVerified(bool verified) {
    state = state.copyWith(isVerified: verified);
  }

  void setClaimed(bool claimed, {Map<String, dynamic>? claimData}) {
    state = state.copyWith(isClaimed: claimed, claimData: claimData);
  }

  /// Load user name from shared preferences
  Future<String?> getUserName() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final savedName = prefs.getString(SharedPreferencesKeys.displayName.name);
    return savedName;
  }

  Future<String?> getEmail() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final email = prefs.getString(SharedPreferencesKeys.email.name);
    return email;
  }

  Future<void> loadNameFromEmploymentCredential(String credentialString) async {
    final username = await getUserName();
    if (username != null) {
      state = state.copyWith(name: username);
      return;
    }
    final credential = UniversalParser.parse(credentialString);
    if (credential.credentialSubject.isNotEmpty) {
      final credentialSubject = credential.credentialSubject[0].toJson();

      final recipientInfo =
          credentialSubject['recipient'] as Map<String, dynamic>? ?? {};

      final name =
          '${recipientInfo['givenName'] as String? ?? ''} ${recipientInfo['familyName'] as String? ?? ''}'
              .trim();

      if (name.isNotEmpty) {
        await setUserName(name);
      }
    }
  }

  /// Login with a name and persist it
  Future<void> setUserName(String name) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(SharedPreferencesKeys.displayName.name, name);
    state = state.copyWith(name: name);
  }
}
