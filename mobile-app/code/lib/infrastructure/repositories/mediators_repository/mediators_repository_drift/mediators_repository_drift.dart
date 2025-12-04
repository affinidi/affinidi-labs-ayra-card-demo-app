import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqlite3/common.dart';

import '../../../../domain/models/mediator/mediator.dart' as model;
import '../../../../domain/models/mediator/mediator_type.dart';
import '../../../../domain/repositories/mediators_repository.dart';
import '../../../exceptions/app_exception.dart';
import '../../../exceptions/app_exception_type.dart';
import 'mediators_database.dart' as db;

part 'mediators_repository_drift.g.dart';

/// Provides a [MediatorsRepositoryDrift] instance backed by Drift database.
@Riverpod(keepAlive: true)
Future<MediatorsRepositoryDrift> mediatorsRepositoryDrift(Ref ref) async {
  final database = await ref.read(db.mediatorsDatabaseProvider.future);
  return MediatorsRepositoryDrift(database: database);
}

/// Drift implementation of [MediatorsRepository].
class MediatorsRepositoryDrift implements MediatorsRepository {
  MediatorsRepositoryDrift({required db.MediatorsDatabase database})
    : _database = database;

  final db.MediatorsDatabase _database;

  @override
  Future<List<model.Mediator>> listDefaultMediators() async {
    final results = await (_database.select(
      _database.mediators,
    )..where((table) => table.type.equalsValue(MediatorType.local))).get();

    return results.map(_MediatorMapper.fromDatabaseRecord).toList();
  }

  /// Retrieves all **custom** mediators stored in the database.
  ///
  /// Custom mediators are those added by the user at runtime
  /// (with type [MediatorType.custom]).
  @override
  Future<List<model.Mediator>> listCustomMediators() async {
    final results = await (_database.select(
      _database.mediators,
    )..where((table) => table.type.equalsValue(MediatorType.custom))).get();
    return results.map(_MediatorMapper.fromDatabaseRecord).toList();
  }

  /// Retrieves **all mediators** regardless of type.
  ///
  /// This includes both [MediatorType.local] and [MediatorType.custom].
  @override
  Future<List<model.Mediator>> listMediators() async {
    final results = await _database.select(_database.mediators).get();
    return results.map(_MediatorMapper.fromDatabaseRecord).toList();
  }

  /// Adds a **custom mediator** to the database.
  ///
  /// - The [name] must be provided by the caller and will be stored as the
  ///   human-friendly label of the mediator.
  /// - The [did] must be unique. If a mediator with the same [did] already
  ///   exists, the underlying database will enforce uniqueness and an
  ///   [AppException] will be thrown.
  ///
  /// [name] - Human-friendly label for the mediator.
  /// [did]  - Unique DID identifier of the mediator.
  @override
  Future<void> addCustomMediator({
    required String name,
    required String did,
  }) async {
    try {
      await _database
          .into(_database.mediators)
          .insert(
            db.MediatorsCompanion.insert(
              mediatorDid: did,
              mediatorName: name,
              type: MediatorType.custom,
            ),
            mode: InsertMode.insert,
          );
    } catch (e) {
      if (e is SqliteException && e.extendedResultCode == 2067) {
        throw AppException(
          'Mediator with the same DID already exists.',
          code: AppExceptionType.mediatorAlreadyExists.name,
        );
      }
      rethrow;
    }
  }

  /// Removes a **custom mediator** identified by [did].
  ///
  /// - Only mediators of type [MediatorType.custom] can be removed.
  /// - Default mediators ([MediatorType.local]) are left untouched.
  @override
  Future<void> removeMediator(String did) async {
    await (_database.delete(_database.mediators)..where(
          (table) => Expression.and([
            table.mediatorDid.equals(did),
            table.type.equals(MediatorType.custom.value),
          ]),
        ))
        .go();
  }

  /// Rename a custom mediator identified by its DID.
  ///
  /// Updates the mediator's name in the database
  /// while ensuring only custom mediators can be renamed.
  ///
  /// [did] - The DID of the mediator to rename.
  /// [newName] - The new human-friendly name to assign.
  @override
  Future<void> renameCustomMediator({
    required String did,
    required String newName,
  }) async {
    await (_database.update(_database.mediators)..where(
          (table) => Expression.and([
            table.mediatorDid.equals(did),
            table.type.equals(MediatorType.custom.value),
          ]),
        ))
        .write(db.MediatorsCompanion(mediatorName: Value(newName)));
  }
}

/// Maps Drift database records to [model.Mediator] domain objects.
class _MediatorMapper {
  static model.Mediator fromDatabaseRecord(db.Mediator record) {
    return model.Mediator(
      id: record.id,
      mediatorName: record.mediatorName,
      mediatorDid: record.mediatorDid,
      type: record.type,
    );
  }
}
