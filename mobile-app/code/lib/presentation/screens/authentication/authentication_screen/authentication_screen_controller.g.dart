// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_screen_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authenticationScreenControllerHash() =>
    r'3ba6ad6cd5cc84e394152ad251c894fdf0cbd2ab';

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

abstract class _$AuthenticationScreenController
    extends BuildlessAutoDisposeNotifier<AuthenticationScreenState> {
  late final String unlockReason;

  AuthenticationScreenState build(String unlockReason);
}

/// See also [AuthenticationScreenController].
@ProviderFor(AuthenticationScreenController)
const authenticationScreenControllerProvider =
    AuthenticationScreenControllerFamily();

/// See also [AuthenticationScreenController].
class AuthenticationScreenControllerFamily
    extends Family<AuthenticationScreenState> {
  /// See also [AuthenticationScreenController].
  const AuthenticationScreenControllerFamily();

  /// See also [AuthenticationScreenController].
  AuthenticationScreenControllerProvider call(String unlockReason) {
    return AuthenticationScreenControllerProvider(unlockReason);
  }

  @override
  AuthenticationScreenControllerProvider getProviderOverride(
    covariant AuthenticationScreenControllerProvider provider,
  ) {
    return call(provider.unlockReason);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'authenticationScreenControllerProvider';
}

/// See also [AuthenticationScreenController].
class AuthenticationScreenControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AuthenticationScreenController,
          AuthenticationScreenState
        > {
  /// See also [AuthenticationScreenController].
  AuthenticationScreenControllerProvider(String unlockReason)
    : this._internal(
        () => AuthenticationScreenController()..unlockReason = unlockReason,
        from: authenticationScreenControllerProvider,
        name: r'authenticationScreenControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$authenticationScreenControllerHash,
        dependencies: AuthenticationScreenControllerFamily._dependencies,
        allTransitiveDependencies:
            AuthenticationScreenControllerFamily._allTransitiveDependencies,
        unlockReason: unlockReason,
      );

  AuthenticationScreenControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.unlockReason,
  }) : super.internal();

  final String unlockReason;

  @override
  AuthenticationScreenState runNotifierBuild(
    covariant AuthenticationScreenController notifier,
  ) {
    return notifier.build(unlockReason);
  }

  @override
  Override overrideWith(AuthenticationScreenController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AuthenticationScreenControllerProvider._internal(
        () => create()..unlockReason = unlockReason,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        unlockReason: unlockReason,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    AuthenticationScreenController,
    AuthenticationScreenState
  >
  createElement() {
    return _AuthenticationScreenControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AuthenticationScreenControllerProvider &&
        other.unlockReason == unlockReason;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, unlockReason.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AuthenticationScreenControllerRef
    on AutoDisposeNotifierProviderRef<AuthenticationScreenState> {
  /// The parameter `unlockReason` of this provider.
  String get unlockReason;
}

class _AuthenticationScreenControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AuthenticationScreenController,
          AuthenticationScreenState
        >
    with AuthenticationScreenControllerRef {
  _AuthenticationScreenControllerProviderElement(super.provider);

  @override
  String get unlockReason =>
      (origin as AuthenticationScreenControllerProvider).unlockReason;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
