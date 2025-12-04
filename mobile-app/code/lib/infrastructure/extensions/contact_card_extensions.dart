import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../domain/models/contact_card/contact_card.dart';
import '../../presentation/widgets/images/default_profile_image.dart';
import 'vcard_extensions.dart';

/// Simple in-memory cache for MemoryImage instances created
///  from base64 strings.
class MemoryImageCache {
  static final _cache = <String, MemoryImage>{};

  static MemoryImage fromBase64(String base64) {
    return _cache.putIfAbsent(base64, () {
      final bytes = base64Decode(base64);
      return MemoryImage(bytes);
    });
  }
}

/// Convenience helpers on ContactCard:
extension ContactCardExtensions on ContactCard {
  /// True when the contact card contains a non-empty profile picture.
  bool get hasProfilePic => profilePic != null && profilePic!.isNotEmpty;

  /// Full display name composed from first and last name.
  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  /// MemoryImage for the contact's profile picture or default placeholder.
  MemoryImage get image {
    if (!hasProfilePic || profilePic!.trim().isEmpty) {
      return defaultProfileImage;
    }
    return MemoryImageCache.fromBase64(profilePic!);
  }

  /// Primary mobile phone or empty string.
  String get mobilePhone => mobile ?? '';

  /// Primary email or empty string.
  String get emailAddress => email ?? '';

  /// Convert this ContactCard into an SDK VCard.
  VCard toVCard() {
    final vcard = VCard.empty();
    vcard.firstName = firstName;
    vcard.lastName = lastName ?? '';
    vcard.email = email ?? '';
    vcard.mobile = mobile ?? '';
    vcard.profilePic = profilePic ?? '';
    vcard.meetingplaceIdentityCardColor = cardColor ?? '';

    return vcard;
  }
}
