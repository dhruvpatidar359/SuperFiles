import 'dart:io';

import 'package:sqflite_common/sqflite.dart';

import '../Databases/database_helper.dart';
import '../utils/file_utils.dart';
import 'package:path/path.dart' as path;

class GetSummary{
  static Future<Map<String, dynamic>> getSummary(FileSystemEntity entity,Database database) async {
    Map<String, dynamic> details = {};

    if (entity is File) {
      String? summary = await DatabaseHelper.getSummary(database, entity.path);
      details['name'] = path.basename(entity.path);
      details['type'] = 'File';
      details['size'] = UtilServices.formatBytes(await entity.length(), 2);
      details['itemCount'] = 'N/A'; // No item count for files
      details['path'] = entity.path;
      details['summary'] = summary ?? "Summary not available.";
    } else if (entity is Directory) {
      final directory = Directory(entity.path);
      int itemCount = 0;
      int totalSize = 0;

      try {
        await for (var fileEntity
        in directory.list(recursive: true, followLinks: false)) {
          itemCount++;
          if (fileEntity is File) {
            totalSize += await fileEntity.length();
          }
        }

        details['name'] = path.basename(entity.path);
        details['type'] = 'Folder';
        details['size'] = UtilServices.formatBytes(totalSize, 2);
        details['itemCount'] = itemCount;
        details['path'] = entity.path;
      } catch (e) {
        details['error'] = "Error retrieving folder details: $e";
      }
    } else {
      details['error'] = "No summary available.";
    }

    return details;
  }
}