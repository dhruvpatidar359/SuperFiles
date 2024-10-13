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
        filePath TEXT UNIQUE NOT NULL,
        summary TEXT NOT NULL
      )
      '''
    );
  }

  // Insert or update a summary
  static Future<void> insertSummary(
      Database database, String filePath, String summary) async {
    await database.insert(
      'summaries',
      {
        'filePath': filePath,
        'summary': summary
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

  // Delete all summaries
  static Future<void> deleteAllSummaries(Database database) async {
    await database.delete('summaries');
  }
}

// Usage Example
void main() async {
  final dbHelper = DatabaseHelper.instance;
  Database database = await dbHelper.getDatabase();

  // Insert summary
  await DatabaseHelper.insertSummary(database, '/path/to/file.txt', 'This is a summary of the file.');

  // Get summary
  String? summary = await DatabaseHelper.getSummary(database, '/path/to/file.txt');
  print('Retrieved Summary: $summary');

  // Update summary
  await DatabaseHelper.updateSummary(database, '/path/to/file.txt', 'Updated summary of the file.');

  // Get all summaries
  List<Map<String, dynamic>> allSummaries = await DatabaseHelper.getAllSummaries(database);
  print('All Summaries: $allSummaries');

  // Delete summary
  await DatabaseHelper.deleteSummary(database, '/path/to/file.txt');

  // Delete all summaries
  await DatabaseHelper.deleteAllSummaries(database);
}