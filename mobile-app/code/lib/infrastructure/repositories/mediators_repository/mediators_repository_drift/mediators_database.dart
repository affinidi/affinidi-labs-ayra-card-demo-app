import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/models/mediator/mediator_type.dart';
import '../../../database/database_platform.dart';
import '../../../secure_storage/secure_storage.dart';
import 'default_mediators.dart';

part 'mediators_database.g.dart';

/// Drift database for storing mediator records.
///
/// This database manages a single table: [Mediators].
/// It ensures that foreign keys are enabled and inserts default mediators
/// (from [DefaultMediators]) if they don't already exist.
@DriftDatabase(tables: [Mediators])
class MediatorsDatabase extends _$MediatorsDatabase {
  MediatorsDatabase({required String databaseName, required String passphrase})
    : super(openConnection(databaseName: databaseName, passphrase: passphrase));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      for (final entry in DefaultMediators.entries) {
        final existing = await (select(
          mediators,
        )..where((tbl) => tbl.mediatorDid.equals(entry.did))).getSingleOrNull();

        if (existing == null) {
          await into(mediators).insert(
            MediatorsCompanion.insert(
              mediatorDid: entry.did,
              mediatorName: entry.name,
              type: MediatorType.local,
            ),
          );
        }
      }
    },
  );
}

/// Drift table definition for [Mediator] entities.
///
/// Stores mediator information such as name, DID, and type.
@DataClassName('Mediator')
class Mediators extends Table {
  TextColumn get id => text().clientDefault(const Uuid().v4)();
  TextColumn get mediatorName => text()();
  TextColumn get mediatorDid => text()();
  IntColumn get type => integer().map(const _MediatorTypeConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {mediatorDid},
  ];
}

/// Handles conversion between [MediatorType] enum and integer for storage.
class _MediatorTypeConverter extends TypeConverter<MediatorType, int> {
  const _MediatorTypeConverter();

  @override
  MediatorType fromSql(int fromDb) {
    return MediatorType.values.firstWhere((type) => type.value == fromDb);
  }

  @override
  int toSql(MediatorType value) {
    return value.value;
  }
}

/// Provider that exposes a [MediatorsDatabase] instance.
///
/// Opens the encrypted database with a passphrase from [SecureStorage].
/// The database is automatically closed when the provider is disposed.
final mediatorsDatabaseProvider = FutureProvider<MediatorsDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();

  final database = MediatorsDatabase(
    databaseName: 'mpx_mediators_db',
    passphrase: passphrase,
  );

  ref.onDispose(database.close);

  return database;
});
