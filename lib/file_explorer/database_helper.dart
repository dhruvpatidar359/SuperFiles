// database_helper.dart

import 'package:sqflite_common/sqlite_api.dart';

class DatabaseHelper {
  // Insert or update a summary
  static Future<void> insertSummary(
      Database database, String filePath, String summary) async {
    await database.insert(
      'summaries',
      {'filePath': filePath, 'summary': summary},
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

  // database_helper.dart

  static Future<void> deleteSummary(Database database, String filePath) async {
    await database.delete(
      'summaries',
      where: 'filePath = ?',
      whereArgs: [filePath],
    );
  }
}
