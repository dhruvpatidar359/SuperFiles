import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../file_explorer/services/Databases/database_helper.dart';

class Summarizer {
  final GenerativeModel model;

  Summarizer(this.model);

  // Summarize a single file's content and return a JSON string
  Future<String> summarizeFile(
      String filePath, String fileName, String content) async {

    print("debug 1");
    // final db = DatabaseHelper.instance;
    //
    // Database database = await db.getDatabase();
    //
    // // Delete the entire summaries table
    // await DatabaseHelper.deleteTable(database);

    // To read the dateTime when file is last modified.
    File file = File(filePath);
    DateTime lastModified = file.lastModifiedSync();

    //Checking if the summary already exists or not
    Map<String, dynamic>? alreadyExistingFileData = await getAllColumnsValues(filePath);
    if (alreadyExistingFileData != null) {
      String? lastSummaryGenerated = alreadyExistingFileData['lastModified'];
      DateTime? lastSummaryGeneratedInDateTime = DateTime.parse(lastSummaryGenerated!);
      if (lastSummaryGeneratedInDateTime!.isAfter(lastModified) ||
          lastSummaryGeneratedInDateTime!.isAtSameMomentAs(lastModified)) {
        print("**************************");
        print("summary not generated for $filePath $fileName");
        print("**************************");

        Map<String, dynamic> toReturn = <String, dynamic>{
            "original_file_name": alreadyExistingFileData["original_file_name"],
            "suggested_file_name" : alreadyExistingFileData["suggested_file_name"],
            "summary" : alreadyExistingFileData["summary"]
        };

        String result = jsonEncode(toReturn);
        return result;



        String inString = jsonEncode(alreadyExistingFileData);
        return inString;
      }
    }

    print("debug 2");

    // Define the prompt with the file content
    final prompt = '''
You will be provided with the contents of a file along with its metadata. Provide a summary of the contents. The purpose of the summary is to organize files based on their content. To this end provide a concise but informative summary. Make the summary as specific to the file as possible.

```{
   "original_file_name" : "original name of the file as given by the user"
   "suggested_file_name": "suggest a file name that best describes it",
   "summary": " summary of the content"
}```

    
Below is the file's data with file path and its content:
$fileName
$content
    ''';

    print('Summarizing file: $fileName');
    final contentToSummarize = [Content.text(prompt)];

    // Count tokens in the request content
    final tokenCount = await model.countTokens(contentToSummarize);
    print('Token count for the prompt: ${tokenCount.totalTokens}');

    // Generate content stream (summary)
    final responses = model.generateContentStream(contentToSummarize);
    final StringBuffer summaryBuffer = StringBuffer();

    await for (final response in responses) {
      summaryBuffer.write(response.text);
    }

    print("summarBuffer");
    print(summaryBuffer);

    print("summarBuffer to String");
    String strBuf =
        summaryBuffer.toString().substring(7, summaryBuffer.length - 3);
    print(strBuf);

    // Return the result as a JSON string
    // Map<String, dynamic> result = {
    //   "file_path": fileName,
    //   "original_file_name": fileName
    //   "summary": summaryBuffer.toString()
    // };

    Map<String, dynamic> summaryMap = jsonDecode(strBuf);

    String summary = summaryMap["summary"];
    String suggestedFileName = summaryMap["suggested_file_name"];
    String originalFileName = summaryMap["original_file_name"];

    print("summarizer summary ${summary}");

    //Saving the summary of the file
    saveSummary(originalFileName,filePath, summary, suggestedFileName);
    getSummary(filePath);

    return strBuf;
    // return jsonEncode(strBuf);  // Convert to JSON string
    // return summaryBuffer.toString();
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
