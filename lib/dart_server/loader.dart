import 'dart:io';
import 'dart:convert';  // For JSON encoding
import 'package:path/path.dart' as p;
import 'summarizer.dart';
import '../file_to_text/file_to_text.dart';


class Loader {
  final Summarizer summarizer;

  Loader(this.summarizer);

  // Load all files from a folder, summarize each, and return a list of JSON objects
  Future<String?> loadAndSummarizeDocuments(String folderPath) async {
    final Directory directory = Directory(folderPath);
    final List<FileSystemEntity> entities = directory.listSync(recursive: true);

    final List<String> allowedExtensions = ['.txt','.c','.cpp','.py','.java', '.js', '.html','.css','.php','.swift','.dart','.rb', '.pdf', '.png', '.jpg', '.jpeg','.docx','.csv','.odt'];
    final List<Map<String, dynamic>> summariesList = [];

    for (FileSystemEntity entity in entities) {
      if (entity is File) {
        final fileExtension = p.extension(entity.path).toLowerCase();
        if (allowedExtensions.contains(fileExtension)) {
          String fileContent = await extractTextFromFile(entity.path);

          // extracting the first 500 characters of a file
          if (fileContent.length > 500) {
            fileContent =  fileContent.substring(0, 500);  // Extract the first 500 characters
          }

          String summaryJson = await summarizer.summarizeFile(entity.path, fileContent);
          Map<String, dynamic> summaryMap = jsonDecode(summaryJson);
          summariesList.add(summaryMap);  // Add the JSON object to the list
        }
      }
    }

    return summariesList.isNotEmpty ? jsonEncode(summariesList) : null;  // Return the list as JSON string
  }

}
