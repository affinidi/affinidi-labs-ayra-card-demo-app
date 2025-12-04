// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_repository_drift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryDriftHash() =>
    r'4dc794fcb9efb44718b6199659fa6da34c1fdaa9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// A provider that supplies the [EdgeDriftProfileRepository] instance.
///
/// - Depends on [profileRepositoryDrift] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
///
/// Copied from [profileRepositoryDrift].
@ProviderFor(profileRepositoryDrift)
const profileRepositoryDriftProvider = ProfileRepositoryDriftFamily();

/// A provider that supplies the [EdgeDriftProfileRepository] instance.
///
/// - Depends on [profileRepositoryDrift] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
///
/// Copied from [profileRepositoryDrift].
class ProfileRepositoryDriftFamily
    extends Family<AsyncValue<EdgeProfileRepository>> {
  /// A provider that supplies the [EdgeDriftProfileRepository] instance.
  ///
  /// - Depends on [profileRepositoryDrift] for database initialization.
  /// - Keeps the repository alive across the app lifecycle.
  ///
  /// Copied from [profileRepositoryDrift].
  const ProfileRepositoryDriftFamily();

  /// A provider that supplies the [EdgeDriftProfileRepository] instance.
  ///
  /// - Depends on [profileRepositoryDrift] for database initialization.
  /// - Keeps the repository alive across the app lifecycle.
  ///
  /// Copied from [profileRepositoryDrift].
  ProfileRepositoryDriftProvider call(
    String repositoryId,
    VaultStore keyStore,
  ) {
    return ProfileRepositoryDriftProvider(repositoryId, keyStore);
  }

  @override
  ProfileRepositoryDriftProvider getProviderOverride(
    covariant ProfileRepositoryDriftProvider provider,
  ) {
    return call(provider.repositoryId, provider.keyStore);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileRepositoryDriftProvider';
}

/// A provider that supplies the [EdgeDriftProfileRepository] instance.
///
/// - Depends on [profileRepositoryDrift] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
///
/// Copied from [profileRepositoryDrift].
class ProfileRepositoryDriftProvider
    extends FutureProvider<EdgeProfileRepository> {
  /// A provider that supplies the [EdgeDriftProfileRepository] instance.
  ///
  /// - Depends on [profileRepositoryDrift] for database initialization.
  /// - Keeps the repository alive across the app lifecycle.
  ///
  /// Copied from [profileRepositoryDrift].
  ProfileRepositoryDriftProvider(String repositoryId, VaultStore keyStore)
    : this._internal(
        (ref) => profileRepositoryDrift(
          ref as ProfileRepositoryDriftRef,
          repositoryId,
          keyStore,
        ),
        from: profileRepositoryDriftProvider,
        name: r'profileRepositoryDriftProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileRepositoryDriftHash,
        dependencies: ProfileRepositoryDriftFamily._dependencies,
        allTransitiveDependencies:
            ProfileRepositoryDriftFamily._allTransitiveDependencies,
        repositoryId: repositoryId,
        keyStore: keyStore,
      );

  ProfileRepositoryDriftProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.repositoryId,
    required this.keyStore,
  }) : super.internal();

  final String repositoryId;
  final VaultStore keyStore;

  @override
  Override overrideWith(
    FutureOr<EdgeProfileRepository> Function(ProfileRepositoryDriftRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileRepositoryDriftProvider._internal(
        (ref) => create(ref as ProfileRepositoryDriftRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        repositoryId: repositoryId,
        keyStore: keyStore,
      ),
    );
  }

  @override
  FutureProviderElement<EdgeProfileRepository> createElement() {
    return _ProfileRepositoryDriftProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileRepositoryDriftProvider &&
        other.repositoryId == repositoryId &&
        other.keyStore == keyStore;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, repositoryId.hashCode);
    hash = _SystemHash.combine(hash, keyStore.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileRepositoryDriftRef on FutureProviderRef<EdgeProfileRepository> {
  /// The parameter `repositoryId` of this provider.
  String get repositoryId;

  /// The parameter `keyStore` of this provider.
  VaultStore get keyStore;
}

class _ProfileRepositoryDriftProviderElement
    extends FutureProviderElement<EdgeProfileRepository>
    with ProfileRepositoryDriftRef {
  _ProfileRepositoryDriftProviderElement(super.provider);

  @override
  String get repositoryId =>
      (origin as ProfileRepositoryDriftProvider).repositoryId;
  @override
  VaultStore get keyStore =>
      (origin as ProfileRepositoryDriftProvider).keyStore;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
