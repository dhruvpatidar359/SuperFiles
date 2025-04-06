import 'dart:io';
import 'dart:convert';  // For JSON encoding
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';
import '../file_explorer/services/Databases/database_helper.dart';
import 'summarizer.dart';
import '../file_to_text/file_to_text.dart';


class Loader {
  final Summarizer summarizer;

  Loader(this.summarizer);

  // Load all files from a folder, summarize each, and return a list of JSON objects
  Future<String?> loadAndSummarizeDocuments(String folderPath) async {
    final Directory directory = Directory(folderPath);
    final List<FileSystemEntity> entities = directory.listSync(recursive: true);

    final List<String> allowedExtensions = [
      '.txt', '.c', '.cpp', '.py', '.java', '.js', '.html', '.css',
      '.php', '.swift', '.dart', '.rb', '.pdf', '.png', '.jpg',
      '.jpeg', '.docx', '.csv', '.odt'
    ];

    final List<Map<String, String>> filesData = [];
    final List<Map<String, dynamic>> allSummaries = [];

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        final fileExtension = p.extension(entity.path).toLowerCase();

        if (allowedExtensions.contains(fileExtension)) {
          String fileContent = await extractTextFromFile(entity.path);

          if (fileContent.length > 500) {
            fileContent = fileContent.substring(0, 500);
          }

          filesData.add({
            "filePath": entity.path,
            "fileName": p.basename(entity.path),
            "content": fileContent,
          });

          print("Collected: ${entity.path}");

          // When we have 10 files collected, summarize them
          if (filesData.length == 10) {
            String batchJson = jsonEncode({"files": filesData});
            String summaryJson = await summarizer.summarizeFile(batchJson);
            print("summaryJson (batch): $summaryJson");

            List<dynamic> batchSummaries = jsonDecode(summaryJson);
            allSummaries.addAll(batchSummaries.cast<Map<String, dynamic>>());

            filesData.clear(); // Clear the batch
          }
        }
      }
    }

    // Summarize remaining files (less than 10)
    if (filesData.isNotEmpty) {
      String batchJson = jsonEncode({"files": filesData});
      String summaryJson = await summarizer.summarizeFile(batchJson);
      print("summaryJson (final batch): $summaryJson");

      List<dynamic> batchSummaries = jsonDecode(summaryJson);
      allSummaries.addAll(batchSummaries.cast<Map<String, dynamic>>());
    }

    return allSummaries.isNotEmpty ? jsonEncode(allSummaries) : null;
  }



  void saveSummary(String fileName, String filePath, String summary, String suggestedFileName) async {
    // Current dateTime
    String currentTime = DateTime.now().toString();

    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    await DatabaseHelper.insertSummary(databaseHelper,fileName, filePath, summary, currentTime, suggestedFileName);
    print("Summary saved for $filePath");
  }


  //For debugging purposes
  Future<String?> getSummary(
      String filePath,
      ) async {
    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    String? summary = await DatabaseHelper.getSummary(databaseHelper, filePath);

    return summary;
  }

}
