import 'dart:io';
import 'dart:convert';  // For JSON encoding
import 'package:path/path.dart' as p;
import 'summarizer.dart';

class Loader {
  final Summarizer summarizer;

  Loader(this.summarizer);

  // Load all files from a folder, summarize each, and return a list of JSON objects
  Future<String?> loadAndSummarizeDocuments(String folderPath) async {
    final Directory directory = Directory(folderPath);
    final List<FileSystemEntity> entities = directory.listSync(recursive: true);

    final List<String> allowedExtensions = ['.txt', '.pdf', '.png', '.jpg', '.jpeg'];
    final List<Map<String, dynamic>> summariesList = [];

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        final fileExtension = p.extension(entity.path).toLowerCase();
        if (allowedExtensions.contains(fileExtension)) {
          String fileContent = await _getFileContent(entity, fileExtension);
          String summaryJson = await summarizer.summarizeFile(entity.path, fileContent);
          Map<String, dynamic> summaryMap = jsonDecode(summaryJson);
          summariesList.add(summaryMap);  // Add the JSON object to the list
        }
      }
    }

    return summariesList.isNotEmpty ? jsonEncode(summariesList) : null;  // Return the list as JSON string
  }

  // Function to read file content based on its extension
  Future<String> _getFileContent(File file, String extension) async {
    if (extension == '.txt') {
      return await file.readAsString();
    } else if (extension == '.pdf') {
      // Add PDF extraction logic here
      return 'PDF content extraction not implemented';
    } else if (extension == '.png' || extension == '.jpg' || extension == '.jpeg') {
      return 'Image content extraction not implemented';  // For image files
    }
    return '';
  }
}
