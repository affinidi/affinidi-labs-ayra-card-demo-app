// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_repository_drift_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$channelRepositoryDriftHash() =>
    r'9d66e938ec087b023f95b26b72ab455df20e2f4d';

/// A provider that supplies the [ChannelRepositoryDrift] instance.
///
/// - Depends on [channelDatabaseProvider] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
///
/// Copied from [channelRepositoryDrift].
@ProviderFor(channelRepositoryDrift)
final channelRepositoryDriftProvider =
    FutureProvider<model.ChannelRepository>.internal(
      channelRepositoryDrift,
      name: r'channelRepositoryDriftProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$channelRepositoryDriftHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChannelRepositoryDriftRef = FutureProviderRef<model.ChannelRepository>;
String _$allChannelsHash() => r'5065765e7c6fcf3bdfc84ca52614a06bc51667f5';

/// A provider that retrieves all channels from the database.
///
/// Similar to findChannelByDid but returns all channels.
/// Returns a list of [model.Channel] objects with their associated vCards.
///
/// Copied from [allChannels].
@ProviderFor(allChannels)
final allChannelsProvider =
    AutoDisposeFutureProvider<List<model.Channel>>.internal(
      allChannels,
      name: r'allChannelsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allChannelsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllChannelsRef = AutoDisposeFutureProviderRef<List<model.Channel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
