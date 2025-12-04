import 'package:flutter/material.dart' as material;
import 'package:flutter/painting.dart';

class CredentialHelper {
  static double avatarSize = 100;

  static double qrCodeSize = 120;

  static String ayraBusinessCard = 'AyraBusinessCard';
  static String employment = 'Employment';
  static String verifiedIdentityDocument = 'VerifiedIdentityDocument';

  static String getCredentialTypeName(Set<String> type, {String? issuerId}) {
    if (type.contains(ayraBusinessCard)) {
      return issuerId == null || !issuerId.contains('did:key')
          ? 'Ayra Business Card'
          : 'Ayra Personal Business Card';
    } else if (type.contains(employment)) {
      return 'Employment Credential';
    } else if (type.contains(verifiedIdentityDocument)) {
      return 'Verified Identity Document';
    } else {
      return _getLabel(type.last);
    }
  }

  static LinearGradient getGradientForCredentialType(Set<String> type) {
    if (type.contains(ayraBusinessCard)) {
      // Sunset Bloom - Warm and vibrant
      return const LinearGradient(
        colors: [Color(0xFF4B32E6), Color(0xFF8712EA), Color(0xFFC50068)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (type.contains(employment)) {
      // Solar Flare - High-energy yellow-orange
      return const LinearGradient(
        colors: [Color(0xFFE88A05), Color(0xFFFFB300)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else if (type.contains(verifiedIdentityDocument)) {
      // Cosmic Indigo - Dreamy purple-pink-orange fade
      return const LinearGradient(
        colors: [Color(0xFF0075E0), Color(0xFF00CFC8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    } else {
      // Default: Ocean Pulse
      return const LinearGradient(
        colors: [Color(0xFF0075E0), Color(0xFF00CFC8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
  }

  static Color credentialColor(List<String> types) {
    if (types.contains(CredentialHelper.ayraBusinessCard)) {
      return const Color(0xFF6A1B9A);
    } else if (types.contains(CredentialHelper.verifiedIdentityDocument)) {
      return const Color(0xFF43A047);
    } else if (types.contains(CredentialHelper.employment)) {
      return const Color(0xFF1E88E5);
    }

    return const Color(0xFF6750A4);
  }

  static material.IconData credentialIcon(List<String> types) {
    if (types.contains(CredentialHelper.ayraBusinessCard)) {
      return material.Icons.business_center;
    } else if (types.contains(CredentialHelper.verifiedIdentityDocument)) {
      return material.Icons.verified_user;
    } else if (types.contains(CredentialHelper.employment)) {
      return material.Icons.badge;
    }

    return material.Icons.card_membership;
  }

  static String _getLabel(String type) {
    final spaced = type
        .replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (match) => ' ')
        .replaceAll(RegExp('[_-]+'), ' ')
        .trim();
    if (spaced.isEmpty) {
      return '';
    }
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  static Map<String, dynamic> getSamplePayload(String email) {
    const employeeSampleData = {
      'darrell': {
        'givenName': 'Darrell',
        'familyName': 'Odonnell',
        'role': 'Executive Director',
        'passport': 'FR567890',
        'dob': '1980-01-15',
        'phone': '+1 609 222 3461',
        'linkedIn': 'darrellodonnell',
        'level': 90,
      },
      'maxwell': {
        'givenName': 'Maxwell',
        'familyName': 'Baylin',
        'role': 'Business Advisor',
        'passport': '782315880',
        'dob': '1980-12-20',
        'phone': '+44 20 3421 9567',
        'linkedIn': 'tryingtoleaveitbetterthenwefoundit',
        'level': 50,
      },
      'giri': {
        'givenName': 'Giriraj',
        'familyName': 'Daga',
        'role': 'Director',
        'passport': 'YY1234567',
        'dob': '1985-03-10',
        'phone': '+91 98123 45678',
        'linkedIn': 'giriraj-daga',
        'level': 70,
      },
    };

    final emailLower = email.toLowerCase();

    for (var key in employeeSampleData.keys) {
      if (emailLower.contains(key)) {
        final data = employeeSampleData[key]!;
        return data.map((k, v) => MapEntry(k, v.toString()));
      }
    }

    return {
      'givenName': 'John',
      'familyName': 'Doe',
      'role': 'Software Engineer',
      'passport': 'X1234567',
      'dob': '1990-01-01',
      'phone': '+1 555 555 5555',
      'linkedIn': 'johndoe',
      'level': 50,
    };
  }
}
