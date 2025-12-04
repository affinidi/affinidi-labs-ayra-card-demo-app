import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as model;
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../secure_storage/secure_storage.dart';

part 'channel_repository_drift_provider.g.dart';

/// A provider that initializes and supplies the [ChannelDatabase].
///
/// - Creates a secure, encrypted database using a passphrase
///  from secure storage.
/// - Stores the database in the application documents directory.
/// - Closes the database when the provider is disposed.
final channelDatabaseProvider = FutureProvider<ChannelDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await getApplicationDocumentsDirectory();
  // final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ChannelDatabase(
    databaseName: 'mpx_channel_db',
    passphrase: passphrase,
    directory: directory,
    // logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

/// A provider that supplies the [ChannelRepositoryDrift] instance.
///
/// - Depends on [channelDatabaseProvider] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
@Riverpod(keepAlive: true)
Future<model.ChannelRepository> channelRepositoryDrift(Ref ref) async {
  final database = await ref.read(channelDatabaseProvider.future);
  return ChannelRepositoryDrift(database: database);
}

/// A provider that retrieves all channels from the database.
///
/// Similar to findChannelByDid but returns all channels.
/// Returns a list of [model.Channel] objects with their associated vCards.
@riverpod
Future<List<model.Channel>> allChannels(Ref ref) async {
  final database = await ref.watch(channelDatabaseProvider.future);
  final query = database.select(database.channels);

  final results = await query.get();

  final repository = await ref.read(channelRepositoryDriftProvider.future);

  // Fetch each channel with full details using findChannelByDid
  final channels = await Future.wait(
    results.map((row) async {
      final channel = await repository.findChannelByDid(
        row.permanentChannelDid!,
      );
      return channel;
    }),
  );

  // Filter out any null channels
  return channels.whereType<model.Channel>().toList();
}
