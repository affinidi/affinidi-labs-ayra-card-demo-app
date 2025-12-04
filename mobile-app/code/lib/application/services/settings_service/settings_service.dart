import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/repositories/mediators_repository.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/mpx_sdk_provider.dart';
import '../../../infrastructure/providers/shared_preferences_provider.dart';
import '../../../infrastructure/repositories/mediators_repository/mediators_repository_drift/mediators_repository_drift.dart';
import '../../../infrastructure/secure_storage/secure_storage.dart';
import 'settings_service_state.dart';

part 'settings_service.g.dart';

/// Service responsible for application settings and mediator configuration.
///
/// This service provides functionality to:
/// - Restore and persist the preferred mediator DID
/// - Load available default and custom mediators
/// - Manage debug mode toggling and its persistence
/// - Track onboarding completion flag
///
/// It reads environment defaults and secure storage, exposes the combined list
/// of mediators, and updates persistent storage when settings change.
@Riverpod(keepAlive: true)
class SettingsService extends _$SettingsService {
  static const _logKey = 'STGSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  MediatorsRepository? _repository;

  @override
  SettingsServiceState build() {
    final defaultMediatorDid = ref.read(environmentProvider).defaultMediatorDid;
    Future(() async {
      await _restorePreferredMediatorIdIfNeeded();
      await _loadAvailableMediators();
      await _restoreDebugMode();
      await _restoreShouldShowMeetingPlaceQr();
      await _getFinishOnboarding();
    });

    return SettingsServiceState(selectedMediatorDid: defaultMediatorDid);
  }

  /// Restore the preferred mediator DID from secure storage if present.
  ///
  /// Reads the secure storage provider and, if a preferred mediator DID is
  /// found, updates provider state.
  Future<void> _restorePreferredMediatorIdIfNeeded() async {
    final provider = await ref.read(secureStorageProvider.future);
    final preferredMediatorDid = await provider.getPreferredMediatorDid();
    if (preferredMediatorDid == null) return;
    state = state.copyWith(selectedMediatorDid: preferredMediatorDid);
  }

  /// Select a mediator configuration and persist it in-memory.
  ///
  /// Updates the selected mediator DID in state and logs the operation.
  ///
  /// [mediatorDid] - The DID of the mediator to select.
  Future<void> selectMediatorConfig(String mediatorDid) async {
    _logger.info('Started updating mediator', name: _logKey);
    final provider = await ref.read(secureStorageProvider.future);
    await provider.setPreferredMediatorDid(mediatorDid);
    state = state.copyWith(selectedMediatorDid: mediatorDid);
    _logger.info('Completed updating mediator', name: _logKey);
  }

  /// Load available mediators: default list followed by custom stored
  ///  mediators.
  ///
  /// Fetches default mediators from the mediator repository and then loads any
  /// user-saved custom mediators from secure storage.
  Future<void> _loadAvailableMediators() async {
    _repository ??= await _ensureRepositoryInitialized();

    final defaultMediators = await _repository?.listDefaultMediators() ?? [];
    final customMediators = await _repository?.listCustomMediators() ?? [];

    final merged = {
      for (final mediator in defaultMediators)
        mediator.mediatorDid: mediator.mediatorName,
      for (final mediator in customMediators)
        mediator.mediatorDid: mediator.mediatorName,
    };

    state = state.copyWith(mediators: merged);
  }

  /// Adds a new **custom mediator** via the repository.
  ///
  /// - If a mediator with the same [did] already exists in memory, an
  ///   [AppExceptionType.mediatorAlreadyExists] is thrown (fail-fast).
  /// - The mediator will be automatically assigned a unique label
  ///   of the form `"Unnamed n"` if none exists yet.
  /// - The naming ensures no collision with existing mediator names.
  Future<void> addCustomMediator(String did) async {
    _repository ??= await _ensureRepositoryInitialized();
    final customMediators = await _repository?.listCustomMediators() ?? [];

    // Auto-generate a unique "Unnamed X" label
    final existingNames = customMediators
        .map((mediator) => mediator.mediatorName)
        .toSet();
    var counter = 1;
    String name;
    do {
      name = 'Unnamed $counter';
      counter++;
    } while (existingNames.contains(name));

    await _repository?.addCustomMediator(name: name, did: did);
    await _loadAvailableMediators();
  }

  /// Add a custom mediator and persist it to secure storage.
  ///
  /// Updates the in-memory custom mediators map, writes it to secure storage,
  /// and updates provider state.
  ///
  /// [did] - Mediator DID to store.
  Future<void> renameCustomMediator({
    required String did,
    required String newName,
  }) async {
    _repository ??= await _ensureRepositoryInitialized();
    await _repository!.renameCustomMediator(did: did, newName: newName);

    await _loadAvailableMediators();
  }

  /// Remove a custom mediator and persist the change.
  ///
  /// Removes [did] from the custom mediators map, updates state and secure
  ///  storage.
  ///
  /// [did] - Mediator DID to remove.
  Future<void> removeCustomMediator(String did) async {
    _repository ??= await _ensureRepositoryInitialized();
    await _repository?.removeMediator(did);
    await _loadAvailableMediators();
  }

  /// Toggle the debug mode for the application and persist the setting.
  ///
  /// Enables or disables the debug log collector, updates state and writes the
  /// debug flag to secure storage.
  ///
  /// Returns:
  /// - `Future<void>` completes when the debug mode state and storage are
  ///  updated.
  Future<void> toggleDebugMode() async {
    final provider = await ref.read(secureStorageProvider.future);
    final newDebugMode = !state.isDebugMode;

    state = state.copyWith(isDebugMode: newDebugMode);
    await provider.saveDebugMode(newDebugMode);

    _logger.info(
      'Debug mode ${newDebugMode ? 'enabled' : 'disabled'}',
      name: _logKey,
    );
  }

  Future<void> toggleShouldShowMeetingPlaceQR() async {
    final newValue = !state.shouldShowMeetingPlaceQR;
    state = state.copyWith(shouldShowMeetingPlaceQR: newValue);

    final provider = await ref.read(secureStorageProvider.future);
    await provider.saveShouldShowMeetingPlaceQR(newValue);

    _logger.info(
      'Show connection offer QR code ${newValue ? 'enabled' : 'disabled'}',
      name: _logKey,
    );
  }

  /// Persist the onboarding completion flag in shared preferences.
  ///
  /// [value] - `true` when onboarding has completed, `false` otherwise.
  ///
  /// Returns:
  /// - `Future<void>` completes when the preference is saved and state updated.
  Future<void> setAlreadyOnboarded(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(SharedPreferencesKeys.alreadyOnboarded.name, value);
    state = state.copyWith(alreadyOnboarded: value);
  }

  Future<String?> getMediatorIdByUrl(String url) async {
    try {
      final sdk = await ref.read(mpxSdkProvider.future);
      final value = await sdk.getMediatorDidFromUrl(url);
      return value;
    } catch (e) {
      _logger.error(
        'Error getting mediator ID from URL',
        error: e,
        name: _logKey,
      );
      return null;
    }
  }

  /// Check whether a given mediator DID is a **custom mediator**.
  ///
  /// Returns `true` if the mediator exists in the custom list,
  /// `false` if it is part of the defaults (or not found at all).
  Future<bool> isCustomMediator(String did) async {
    _repository ??= await _ensureRepositoryInitialized();
    final customMediators = await _repository!.listCustomMediators();
    if (customMediators.any((m) => m.mediatorDid == did)) {
      return true;
    }
    return false;
  }

  /// Load the onboarding completion flag from shared preferences.
  ///
  /// Reads the onboarding flag and updates state. If not present, defaults to
  ///  `false`.
  Future<void> _getFinishOnboarding() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final value = prefs.getBool(SharedPreferencesKeys.alreadyOnboarded.name);

    state = state.copyWith(alreadyOnboarded: value ?? false);
  }

  /// Restore the "show meeting place QR" setting from secure storage.
  ///
  /// If a saved value exists, updates state accordingly.
  Future<void> _restoreShouldShowMeetingPlaceQr() async {
    final provider = await ref.read(secureStorageProvider.future);
    final showMeetingPlaceQr = await provider.getShouldShowMeetingPlaceQR();
    if (showMeetingPlaceQr == null) return;

    state = state.copyWith(shouldShowMeetingPlaceQR: showMeetingPlaceQr);
  }

  /// Restore debug mode value from secure storage and apply it.
  ///
  /// If a saved debug mode value exists, updates state and registers the
  /// debug log collector if enabled.
  Future<void> _restoreDebugMode() async {
    final provider = await ref.read(secureStorageProvider.future);
    final debugMode = await provider.getDebugMode();
    if (debugMode == null) return;

    state = state.copyWith(isDebugMode: debugMode);
  }

  Future<MediatorsRepository> _ensureRepositoryInitialized() async =>
      await ref.read(mediatorsRepositoryDriftProvider.future);
}
