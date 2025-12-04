import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as model;
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../secure_storage/secure_storage.dart';

part 'connection_offer_repository_drift_provider.g.dart';

/// A provider that initializes and supplies the [ConnectionOfferDatabase].
///
/// - Creates a secure, encrypted database using a passphrase from
///  secure storage.
/// - Stores the database in the application documents directory.
/// - Closes the database when the provider is disposed.
final _connectionOffersDatabaseProvider = FutureProvider<ConnectionOfferDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await getApplicationDocumentsDirectory();
  // final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ConnectionOfferDatabase(
    databaseName: 'mpx_connections_db',
    passphrase: passphrase,
    directory: directory,
    // logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

/// A provider that supplies the [ConnectionOfferRepositoryDrift] instance.
///
/// - Depends on [_connectionOffersDatabaseProvider] for database
///  initialization.
/// - Keeps the repository alive across the app lifecycle.
@Riverpod(keepAlive: true)
Future<model.ConnectionOfferRepository> connectionOfferRepositoryDrift(
  Ref ref,
) async {
  final database = await ref.read(_connectionOffersDatabaseProvider.future);
  return ConnectionOfferRepositoryDrift(database: database);
}
