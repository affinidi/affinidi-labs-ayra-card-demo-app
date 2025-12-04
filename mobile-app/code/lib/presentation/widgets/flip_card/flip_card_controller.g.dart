// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flip_card_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$flipCardControllerHash() =>
    r'f1dd6de35ce41eb1fd380a6390cf4ea5330de2be';

/// Controller to manage flip state across all cards in the app.
/// Ensures only one card is flipped at a time across all screens.
///
/// Copied from [FlipCardController].
@ProviderFor(FlipCardController)
final flipCardControllerProvider =
    AutoDisposeNotifierProvider<FlipCardController, String?>.internal(
      FlipCardController.new,
      name: r'flipCardControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$flipCardControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FlipCardController = AutoDisposeNotifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
