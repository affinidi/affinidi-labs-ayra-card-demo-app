import 'package:affinidi_tdk_vault/affinidi_tdk_vault.dart';
import 'package:affinidi_tdk_vault_edge_drift_provider/affinidi_tdk_vault_edge_drift_provider.dart';
import 'package:affinidi_tdk_vault_edge_provider/affinidi_tdk_vault_edge_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository_drift_provider.g.dart';

/// A provider that initializes and supplies the [Database].
///
/// - Creates a secure, encrypted database using a passphrase
///  from secure storage.
/// - Stores the database in the application documents directory.
/// - Closes the database when the provider is disposed.
final _profileDatabaseProvider = FutureProvider.family<Database, String>((
  ref,
  repositoryId,
) async {
  final directory = await getApplicationDocumentsDirectory();
  final cleanRepositoryId = repositoryId.replaceAll(
    RegExp(r'[^a-zA-Z0-9]'),
    '_',
  );
  final database = DatabaseConfig.createDatabase(
    databaseName: 'edge_profiles_$cleanRepositoryId.db',
    directory: directory.path,
  );

  return database;
});

/// A provider that supplies the [EdgeDriftProfileRepository] instance.
///
/// - Depends on [profileRepositoryDrift] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
@Riverpod(keepAlive: true)
Future<EdgeProfileRepository> profileRepositoryDrift(
  Ref ref,
  String repositoryId,
  VaultStore keyStore,
) async {
  // Create database
  final database = await ref.read(
    _profileDatabaseProvider(repositoryId).future,
  );

  // Create encryption service
  final encryptionService = EdgeEncryptionService(vaultStore: keyStore);

  final factory = EdgeDriftRepositoryFactory(database: database);

  return EdgeProfileRepository(repositoryId, factory, encryptionService);
}
