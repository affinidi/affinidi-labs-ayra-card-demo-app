import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flip_card_controller.g.dart';

/// Controller to manage flip state across all cards in the app.
/// Ensures only one card is flipped at a time across all screens.
@riverpod
class FlipCardController extends _$FlipCardController {
  @override
  String? build() {
    return null; // No card flipped initially
  }

  /// Get the currently flipped card ID
  String? get flippedCardId => state;

  /// Flip a specific card (and auto-flip back any other card)
  void flipCard(String cardId) {
    if (state == cardId) {
      // Same card tapped again, flip it back
      state = null;
    } else {
      // Different card tapped, flip to this one
      state = cardId;
    }
  }

  /// Flip back the current card
  void flipBack() {
    state = null;
  }

  /// Check if a specific card is flipped
  bool isCardFlipped(String cardId) {
    return state == cardId;
  }
}
