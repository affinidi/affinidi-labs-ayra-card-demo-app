import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedPreferencesKeys {
  alreadyInstalled,
  alreadyOnboarded,
  issuerDidCache,
  provider,
  email,
  displayName,
}

/// A provider that supplies the global [SharedPreferences] instance.
///
/// Used for storing and retrieving simple key-value pairs
/// across the app lifecycle.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
}, name: 'sharedPreferencesProvider');
