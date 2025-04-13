import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../file_explorer/services/Databases/database_helper.dart';

class Summarizer {
  final GenerativeModel model;

  Summarizer(this.model);



    Future<String> summarizeFile(String batchJson) async {
      final Map<String, dynamic> batchMap = jsonDecode(batchJson);
      final List<dynamic> files = batchMap['files'];

      final List<Map<String, dynamic>> summariesList = [];

      for (var file in files) {
        String filePath = file['filePath'];
        String fileName = file['fileName'];
        String content = file['content'];

        final fileStats = await File(filePath).stat();
        final lastModified = fileStats.modified;

        // Map<String,
        //     dynamic>? alreadyExistingFileData = await getAllColumnsValues(
        //     filePath);
        // if (alreadyExistingFileData != null) {
        //   String? lastSummaryGenerated = alreadyExistingFileData['lastModified'];
        //   DateTime? lastSummaryGeneratedInDateTime = DateTime.tryParse(
        //       lastSummaryGenerated ?? "");
        //
        //   if (lastSummaryGeneratedInDateTime != null &&
        //       (lastSummaryGeneratedInDateTime.isAfter(lastModified) ||
        //           lastSummaryGeneratedInDateTime.isAtSameMomentAs(
        //               lastModified))) {
        //     print("**************************");
        //     print("Summary already exists for $filePath ($fileName)");
        //     print("**************************");
        //
        //     summariesList.add({
        //       "original_file_name": alreadyExistingFileData["original_file_name"],
        //       "suggested_file_name": alreadyExistingFileData["suggested_file_name"],
        //       "summary": alreadyExistingFileData["summary"]
        //     });
        //
        //     continue; // Skip summarizing
        //   }
        // }

        print("Summarizing new/updated file: $filePath ($fileName)");

        final prompt = '''
You will be provided with the contents of a file along with its metadata. Provide a summary of the contents. The purpose of the summary is to organize files based on their content. To this end provide a concise but informative summary. Make the summary as specific to the file as possible.

Return in JSON format:
```{
   "original_file_name" : "original name of the file as given by the user",
   "original_file_path" : "original path of the file as given by the user"
   "suggested_file_name": "suggest a file name that best describes it",
   "summary": "summary of the content"
}```

Below is the file's data:
$fileName
$filePath
$content
''';

        final contentToSummarize = [Content.text(prompt)];

        final tokenCount = await model.countTokens(contentToSummarize);
        print('Token count: ${tokenCount.totalTokens}');

        final responses = model.generateContentStream(contentToSummarize);
        final StringBuffer summaryBuffer = StringBuffer();

        await for (final response in responses) {
          summaryBuffer.write(response.text);
        }

        print("Raw summaryBuffer: $summaryBuffer");

        // Remove triple-backtick and trim
        String cleanJson = summaryBuffer.toString().trim();
        cleanJson =
            cleanJson.replaceAll(RegExp(r'^```({|json)?'), '').replaceAll(
                RegExp(r'```$'), '');

        Map<String, dynamic> summaryMap = jsonDecode(cleanJson);

        String summary = summaryMap["summary"];
        String suggestedFileName = summaryMap["suggested_file_name"];
        String originalFileName = summaryMap["original_file_name"];

        // saveSummary(originalFileName, filePath, summary, suggestedFileName);

        summariesList.add(summaryMap);
      }

      return jsonEncode(summariesList);
    }


    void saveSummary(String fileName, String filePath, String summary, String suggestedFileName) async {
    String currentTime = DateTime.now().toString();

    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    await DatabaseHelper.insertSummary(
        databaseHelper,fileName,  filePath, summary,suggestedFileName, currentTime);
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
    // if (summary != null) {
    //   print('Summary for $filePath: $summary');
    // } else {
    //   print('No summary found for $filePath');
    // }
  }

  // Retrieve lastModified for debugging purposes
  Future<DateTime?> getLastModifiedDate(String filePath) async {
    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    DateTime? lastModified =
        await DatabaseHelper.getLastModified(databaseHelper, filePath);
    if (lastModified != null) {
      print('Last Modified for $filePath: $lastModified');
    } else {
      print('No last modified date found for $filePath');
    }
    return lastModified;
  }


  // Retrieve whole row by filePath
  Future<Map<String, dynamic>?> getAllColumnsValues(String filePath) async {
    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    Map<String, dynamic>? allColumns = await DatabaseHelper.getAllColumns(databaseHelper, filePath);

    return allColumns;
    if (allColumns != null) {
      print('All Columns for $filePath: $allColumns');
    } else {
      print('No data found for $filePath');
    }
  }
}
