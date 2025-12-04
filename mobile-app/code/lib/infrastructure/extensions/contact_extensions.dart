import 'dart:convert';

import 'package:flutter/material.dart';
import '../../domain/models/contacts/contact.dart';
import '../../domain/models/contacts/contact_status.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'build_context_extensions.dart';

/// UI helper accessors for Contact model used by widgets:
extension ContactExtensions on Contact {
  /// returns a color for the contact status/avatar.
  Color getStatusColor(
    BuildContext context, {
    bool asAvatar = false,
    bool forceHideBorder = false,
  }) {
    var color = context.colorScheme.surface;

    if (forceHideBorder) {
      color = Colors.transparent;
    } else {
      switch (status) {
        case ContactStatus.pendingApproval:
          color = context.customColors.warning;
          break;
        case ContactStatus.pendingInauguration:
          color = context.colorScheme.primary;
          break;
        case ContactStatus.active:
        case ContactStatus.approved:
          color = context.customColors.success;

          if (asAvatar) {
            if (chatInProgress ||
                badgeCount > 0 ||
                lastMessageSeqNo != 0 ||
                currentMessageSeqNo != 0) {
              color = Colors.transparent;
            }
          }
          break;
        case ContactStatus.deleted:
        case ContactStatus.error:
          color = context.colorScheme.error;
          break;
        default:
          color = Colors.transparent;
      }
    }

    return color;
  }

  /// MemoryImage for the other party profile picture or default.
  MemoryImage get otherPartyImage =>
      (otherPartyProfilePicture != null && otherPartyProfilePicture!.isNotEmpty)
      ? MemoryImage(base64Decode(otherPartyProfilePicture!))
      : defaultProfileImage;
}
