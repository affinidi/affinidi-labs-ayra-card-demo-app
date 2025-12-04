// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_offer_repository_drift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectionOfferRepositoryDriftHash() =>
    r'40451186d59da45b73d2de3337473e73e4616e91';

/// A provider that supplies the [ConnectionOfferRepositoryDrift] instance.
///
/// - Depends on [_connectionOffersDatabaseProvider] for database
///  initialization.
/// - Keeps the repository alive across the app lifecycle.
///
/// Copied from [connectionOfferRepositoryDrift].
@ProviderFor(connectionOfferRepositoryDrift)
final connectionOfferRepositoryDriftProvider =
    FutureProvider<model.ConnectionOfferRepository>.internal(
      connectionOfferRepositoryDrift,
      name: r'connectionOfferRepositoryDriftProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$connectionOfferRepositoryDriftHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectionOfferRepositoryDriftRef =
    FutureProviderRef<model.ConnectionOfferRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
