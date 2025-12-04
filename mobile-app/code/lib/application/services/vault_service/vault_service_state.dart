import 'package:affinidi_tdk_vault/affinidi_tdk_vault.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vault_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class VaultServiceState with _$VaultServiceState {
  factory VaultServiceState({
    Vault? vault,
    Profile? defaultProfile,
    List<DigitalCredential>? claimedCredentials,
  }) = _VaultServiceState;
}
