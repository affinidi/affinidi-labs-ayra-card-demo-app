import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../contact_card/contact_card.dart';

part 'identity.freezed.dart';

/// Identity
///
/// Represents a user identity in the app. This model pairs a stable local
/// identifier with a ContactCard (the public, displayable profile).
///
/// Factory parameters:
/// - [id] - Unique identifier for the identity record.
/// - [card] - ContactCard holding the public profile information for this
///  identity.
@freezed
abstract class Identity with _$Identity {
  const factory Identity({required String id, required ContactCard card}) =
      _Identity;

  /// Create an "empty" identity placeholder using environment defaults.
  ///
  /// This is used when no persisted identities are available and provides a
  /// consistent fallback identity id and an empty ContactCard.
  factory Identity.empty(Environment env) {
    return Identity(id: env.nonExistentIdentityId, card: ContactCard.empty());
  }

  /// Create a special "add new" identity placeholder used by UI pickers.
  ///
  /// The resulting identity should not be treated as a persisted identity;
  /// it's a UI sentinel allowing users to trigger the create-new flow.
  factory Identity.addNew(Environment env) {
    return Identity(id: env.addNewIdentityId, card: ContactCard.empty());
  }
}
