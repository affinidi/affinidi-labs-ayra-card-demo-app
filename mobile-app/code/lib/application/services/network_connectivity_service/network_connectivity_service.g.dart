// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_connectivity_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$networkConnectivityServiceHash() =>
    r'edaca1c64a8e124fb69b09ef192b1c25f80e9dcf';

/// Service for monitoring network connectivity status.
///
/// This service provides functionality to:
/// - Monitor real-time network connectivity changes
/// - Log connectivity changes for debugging
///
/// Copied from [NetworkConnectivityService].
@ProviderFor(NetworkConnectivityService)
final networkConnectivityServiceProvider =
    NotifierProvider<
      NetworkConnectivityService,
      NetworkConnectivityServiceState
    >.internal(
      NetworkConnectivityService.new,
      name: r'networkConnectivityServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$networkConnectivityServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NetworkConnectivityService =
    Notifier<NetworkConnectivityServiceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
