// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_repository_drift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupsRepositoryDriftHash() =>
    r'5d752da93a6917590b5dafc1794d41799dc2c1f0';

/// A provider that supplies the [GroupsRepositoryDrift] instance.
///
/// - Depends on [_groupsDatabaseProvider] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
///
/// Copied from [groupsRepositoryDrift].
@ProviderFor(groupsRepositoryDrift)
final groupsRepositoryDriftProvider =
    FutureProvider<model.GroupRepository>.internal(
      groupsRepositoryDrift,
      name: r'groupsRepositoryDriftProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groupsRepositoryDriftHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupsRepositoryDriftRef = FutureProviderRef<model.GroupRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
