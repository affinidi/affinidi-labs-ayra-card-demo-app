import 'package:flutter/material.dart';
import '../../domain/models/identity/identity.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import '../configuration/environment.dart';
import 'build_context_extensions.dart';
import 'contact_card_extensions.dart';

/// Extension methods on [Identity?] for handling display properties,
/// colors, gradients, images, and identity-specific information.
extension IdentityExtensions on Identity? {
  /// Returns the card color for the identity.
  Color getCardColor(
    Environment env,
    BuildContext context, {
    double intensity = 1.0,
  }) {
    if (this == null) {
      return context.colorScheme.primary;
    }

    final card = this!.card;

    if (card.cardColor != null && card.cardColor!.isNotEmpty) {
      final colorValue = int.parse(card.cardColor!);
      final customColor = Color(colorValue);

      if (intensity == 1.0) {
        return customColor;
      } else {
        final red = (customColor.r * 255 * intensity).round();
        final green = (customColor.g * 255 * intensity).round();
        final blue = (customColor.b * 255 * intensity).round();
        final alpha = (customColor.a * 255).round();

        return Color.fromARGB(alpha, red, green, blue);
      }
    }

    final id = this!.id;

    if (id == env.defaultIdentityId) {
      return Color.fromARGB(
        255,
        (3 * intensity).round(),
        (104 * intensity).round(),
        (192 * intensity).round(),
      );
    } else if (id == env.addNewIdentityId) {
      return Color.fromARGB(
        255,
        (180 * intensity).round(),
        (180 * intensity).round(),
        (180 * intensity).round(),
      );
    } else {
      final defaultColor = const Color.fromARGB(255, 122, 166, 488);
      final r = (defaultColor.r * 255 * intensity).round();
      final g = (defaultColor.g * 255 * intensity).round();
      final b = (defaultColor.b * 255 * intensity).round();
      final a = (defaultColor.a * 255).round();
      return Color.fromARGB(a, r, g, b);
    }
  }

  /// Returns a linear gradient for the identity card.
  LinearGradient getLinearGradient(
    Environment env,
    BuildContext context, {
    Alignment center = Alignment.bottomCenter,
    double radius = 2.0,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [getCardColor(env, context), context.colorScheme.surface],
    );
  }

  /// Returns `true` if this identity is the environment's default identity.
  bool isDefault(Environment env) => this?.id == env.defaultIdentityId;

  /// Returns `true` if this identity represents a non-existent identity.
  bool isEmpty(Environment env) => this?.id == env.nonExistentIdentityId;

  /// Returns `true` if this identity is the "add new" identity option.
  bool isAddNew(Environment env) => this?.id == env.addNewIdentityId;

  /// Returns a display name for the identity.
  String getDisplayName({
    required Environment env,
    required AppLocalizations l10n,
  }) {
    if (isDefault(env)) return l10n.displayNamePrimary;
    if (isAddNew(env)) return l10n.displayNameAddNew;
    return this?.card.displayName.isNotEmpty == true
        ? this!.card.displayName
        : '';
  }

  /// Returns a subtitle for the identity.
  String getSubtitle({
    required Environment env,
    required AppLocalizations l10n,
  }) {
    if (isDefault(env)) return l10n.subtitlePrimary;
    if (isAddNew(env)) return l10n.subtitleAddNew;
    return l10n.subtitleAlias;
  }

  /// Returns the profile image for the identity.
  ImageProvider get profileImage {
    if (this == null) {
      return defaultProfileImage;
    }
    return this!.card.image;
  }
}
