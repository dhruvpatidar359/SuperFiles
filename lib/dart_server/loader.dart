import 'dart:io';
import 'dart:convert';  // For JSON encoding
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:superfiles/dart_server/file_rearranger.dart';
import '../file_explorer/services/Databases/database_helper.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'summarizer.dart';
import '../file_to_text/file_to_text.dart';


class Loader {
  final Summarizer summarizer;

  Loader(this.summarizer);

  // Load all files from a folder, summarize each, and return a list of JSON objects
  Future<String?> loadAndSummarizeDocuments(String folderPath) async {
    final fileRearranger = FileRearranger(GenerativeModel(
      model: 'gemini-1.5-flash-latest', // The model you are using
      apiKey:
      'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw', // Replace with your actual Google Generative AI API key
    ));



    final filteredItemsFromGemini = await fileRearranger.getRearrangeableItems(folderPath);

    final List<Map<String, String>> filesData = [];
    final List<Map<String, dynamic>> allSummaries = [];

    for (var item in filteredItemsFromGemini) {
      final filePath = item["filePath"]!;
      final fileName = item["fileName"]!;
      final content = item["content"]!;

      if (content == "file") {
        final fileContent =  await extractTextFromFile(filePath);
        filesData.add({
          "filePath": filePath,
          "fileName": fileName,
          "content": fileContent.length > 500 ? fileContent.substring(0, 500) : fileContent,
        });

        print("Reading File: $filePath");

        if (filesData.length == 10) {
          final batchJson = jsonEncode({"files": filesData});
          final summaryJson = await summarizer.summarizeFile(batchJson);
          print("summaryJson (batch): $summaryJson");

          final batchSummaries = jsonDecode(summaryJson);
          allSummaries.addAll(batchSummaries.cast<Map<String, dynamic>>());

          filesData.clear();
        }
      } else {
        // It's a folder – use Gemini's description directly
        allSummaries.add({
          "filePath": filePath,
          "fileName": fileName,
          "content": content, // Gemini's description
        });

        print("Using Gemini description for folder: $filePath");
      }
    }

    // Summarize remaining files
    if (filesData.isNotEmpty) {
      final batchJson = jsonEncode({"files": filesData});
      final summaryJson = await summarizer.summarizeFile(batchJson);
      print("summaryJson (final batch): $summaryJson");

      final batchSummaries = jsonDecode(summaryJson);
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
