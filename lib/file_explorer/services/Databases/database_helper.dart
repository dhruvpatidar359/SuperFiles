// database_helper.dart

import 'package:path/path.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final String _databaseName = 'summaries.db';
  static final int _databaseVersion = 1;

  // Create a singleton instance of the DatabaseHelper
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database reference
  static Database? _database;

  // Get or create the database instance
  Future<Database> getDatabase() async {
    databaseFactory = databaseFactoryFfi;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create the database table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        '''
      CREATE TABLE summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fileName TEXT UNIQUE NOT NULL,
        filePath TEXT UNIQUE NOT NULL,
        summary TEXT NOT NULL,
        suggested_file_name TEXT,
        lastModified DATETIME NOT NULL
      )
      '''
    );
  }

  // Retrieve all columns for a specific filePath
  static Future<Map<String, dynamic>?> getAllColumns(Database database, String filePath) async {
    List<Map<String, dynamic>> results = await database.query(
      'summaries',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  // Insert or update a summary
  static Future<void> insertSummary(
      Database database,String fileName, String filePath, String summary, String suggestedFileName, String lastModified) async {
    await database.insert(
      'summaries',
      {
        'fileName':fileName,
        'filePath': filePath,
        'summary': summary,
        'suggested_file_name': suggestedFileName,
        'lastModified': lastModified
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve a summary
  static Future<String?> getSummary(Database database, String filePath) async {
    List<Map<String, dynamic>> results = await database.query(
      'summaries',
      columns: ['summary'],
      where: 'filePath = ?',
      whereArgs: [filePath],
    );

    if (results.isNotEmpty) {
      return results.first['summary'] as String;
    } else {
      return null;
    }
  }

  // Retrieve lastModified field
  static Future<DateTime?> getLastModified(Database database, String filePath) async {
    List<Map<String, dynamic>> results = await database.query(
      'summaries',
      columns: ['lastModified'],
      where: 'filePath = ?',
      whereArgs: [filePath],
    );

    if (results.isNotEmpty) {
      return DateTime.parse(results.first['lastModified'] as String);
    } else {
      return null;
    }
  }

  // Delete a summary
  static Future<void> deleteSummary(Database database, String filePath) async {
    await database.delete(
      'summaries',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );
  }

  // Retrieve all summaries
  static Future<List<Map<String, dynamic>>> getAllSummaries(Database database) async {
    return await database.query('summaries');
  }

  // Update an existing summary
  static Future<void> updateSummary(Database database, String filePath, String newSummary) async {
    await database.update(
      'summaries',
      {
        'summary': newSummary,
      },
      where: 'filePath = ?',
      whereArgs: [filePath],
    );
  }

  // Delete the entire summaries table
  static Future<void> deleteTable(Database database) async {
    await database.execute('DROP TABLE IF EXISTS summaries');
  }

  // // Delete all summaries
  // static Future<void> deleteAllSummaries(Database database) async {
  //   await database.delete('summaries');
  // }

  // Retrieve lastModified for debugging purposes
  Future<DateTime?> getLastModifiedDebug(String filePath) async {
    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    DateTime? lastModified = await DatabaseHelper.getLastModified(databaseHelper, filePath);
    if (lastModified != null) {
      print('Last Modified for $filePath: $lastModified');
    } else {
      print('No last modified date found for $filePath');
    }
    return lastModified;
  }
}

// Usage Example
// void main() async {
  // final dbHelper = DatabaseHelper.instance;
  // Database database = await dbHelper.getDatabase();

  //   // Delete the entire summaries table
  // await DatabaseHelper.deleteTable(database);

  // // Insert summary
  // await DatabaseHelper.insertSummary(database, '/path/to/file.txt', 'This is a summary of the file.', DateTime.now().toString());
  //
  // // Get summary
  // String? summary = await DatabaseHelper.getSummary(database, '/path/to/file.txt');
  // print('Retrieved Summary: $summary');
  //
  // // Get last modified date
  // DateTime? lastModified = await DatabaseHelper.getLastModified(database, '/path/to/file.txt');
  // print('Last Modified: $lastModified');
  //
  // // Update summary
  // await DatabaseHelper.updateSummary(database, '/path/to/file.txt', 'Updated summary of the file.');
  //
  // // Get all summaries
  // List<Map<String, dynamic>> allSummaries = await DatabaseHelper.getAllSummaries(database);
  // print('All Summaries: $allSummaries');
  //
  // // Delete summary
  // await DatabaseHelper.deleteSummary(database, '/path/to/file.txt');
  //
  // // Delete all summaries
  // await DatabaseHelper.deleteAllSummaries(database);
// }