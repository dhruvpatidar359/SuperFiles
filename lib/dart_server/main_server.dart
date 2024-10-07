import 'dart:convert';

import 'package:superfiles/dart_server/summarizer.dart';
import 'package:superfiles/dart_server/tree_generator.dart';


import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:file_picker/file_picker.dart';

import 'loader.dart'; // Import file picker

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Summarizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DocumentSummarizerScreen(),
    );
  }
}

class DocumentSummarizerScreen extends StatefulWidget {
  @override
  _DocumentSummarizerScreenState createState() =>
      _DocumentSummarizerScreenState();
}

class _DocumentSummarizerScreenState extends State<DocumentSummarizerScreen> {
  String? selectedFolderPath;
  String? combinedSummariesJson;
  String? treeGenerator;
  bool isLoading = false;

  final summarizer = Summarizer(GenerativeModel(
    model: 'gemini-1.5-flash-latest', // The model you are using
    apiKey:
    'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw', // Replace with your actual Google Generative AI API key
  ));

  late final loader = Loader(summarizer); // Initialize loader with summarizer

  late final tree = TreeGenerator(GenerativeModel(
    model: 'gemini-1.5-flash-latest', // The model you are using
    apiKey:
    'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw', // Replace with your actual Google Generative AI API key
  ));

  Future<void> pickFolderAndSummarizeDocuments() async {
    // Use file picker to select a folder
    String? folderPath = await FilePicker.platform.getDirectoryPath();

    if (folderPath != null) {
      setState(() {
        selectedFolderPath = folderPath;
        isLoading = true;
      });

      // Load and summarize document content from the selected folder
      combinedSummariesJson =
      await loader.loadAndSummarizeDocuments(folderPath);

      treeGenerator = await tree.createFileTree(combinedSummariesJson!);
      setState(() {
        isLoading = false;
      });
    }
  }

  String prettyPrintJson(String jsonString) {
    var jsonObject = jsonDecode(jsonString); // Decode the JSON string
    var prettyString = JsonEncoder.withIndent('  ')
        .convert(jsonObject); // Pretty-print with 2 spaces for indentation
    print(prettyString);
    return prettyString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Summarizer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFolderAndSummarizeDocuments,
              child: Text('Select Folder to Load and Summarize Documents'),
            ),
            SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
            SizedBox(height: 20),
            if (combinedSummariesJson != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                      'Combined Summaries (JSON):\n\n${prettyPrintJson(combinedSummariesJson!)}'),
                ),
              ),
            if (treeGenerator != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                      'Tree (JSON):\n\n${prettyPrintJson(treeGenerator!)}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
