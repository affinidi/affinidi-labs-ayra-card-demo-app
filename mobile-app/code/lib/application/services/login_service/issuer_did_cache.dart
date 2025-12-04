import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/providers/shared_preferences_provider.dart';

Future<void> cacheIssuerDid({
  required Ref ref,
  required String issuerDid,
}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  await prefs.setString(SharedPreferencesKeys.issuerDidCache.name, issuerDid);
}

Future<String?> readCachedIssuerDid({required Ref ref}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  return prefs.getString(SharedPreferencesKeys.issuerDidCache.name);
}

Future<String?> readCachedProvider({required Ref ref}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  return prefs.getString(SharedPreferencesKeys.provider.name);
}
