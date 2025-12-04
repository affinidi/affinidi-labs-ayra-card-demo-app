import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../configuration/environment.dart';

/// Class with implementations specific to native platforms
class DatabasePlatform {
  /// Creates a database for native platform using SQLite
  ///
  /// [databaseName] - The database name
  /// it is required on native
  static Future<QueryExecutor> createDatabase({
    required String databaseName,
    required String passphrase,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, databaseName);

    final sqliteDb = sqlite3.open(dbPath);
    sqliteDb.execute("PRAGMA key = '$passphrase';");

    final cipherVersion = sqliteDb.select('PRAGMA cipher_version;');
    if (cipherVersion.isEmpty) {
      throw UnsupportedError('SQLCipher not available');
    }

    sqliteDb.select('SELECT count(*) FROM sqlite_master;');

    return NativeDatabase.opened(
      sqliteDb,
      logStatements: Environment.instance.isDatabaseLoggingEnabled,
    );
  }

  /// Creates an in-memory database for native platform using SQLite
  static Future<QueryExecutor> createInMemoryDatabase({
    required String passphrase,
  }) async {
    final sqliteDb = sqlite3.openInMemory();
    sqliteDb.execute("PRAGMA key = '$passphrase';");

    return NativeDatabase.opened(
      sqliteDb,
      logStatements: Environment.instance.isDatabaseLoggingEnabled,
    );
  }

  /// Gets the current platform info
  static Map<String, String> get info {
    return {'platform': 'native', 'database': 'SQLite'};
  }
}

LazyDatabase openConnection({
  required String databaseName,
  required String passphrase,
}) {
  return LazyDatabase(() async {
    final database = await DatabasePlatform.createDatabase(
      databaseName: databaseName,
      passphrase: passphrase,
    );
    return database;
  });
}
