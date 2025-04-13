import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class FileRearranger {
  final GenerativeModel model;

  FileRearranger(this.model);

  Future<List<Map<String, dynamic>>> getRearrangeableItems(String folderPath) async {
    final Directory root = Directory(folderPath);
    if (!await root.exists()) throw Exception('Folder does not exist');

    // 1. Build folder structure as JSON
    final folderJson = await _buildFolderJson(root);

    // 2. Prepare Gemini prompt
    final prompt = '''
You are an AI-based file organizer.

Here is a folder structure as JSON. Your job is to return a list of files/folders that can be **rearranged**.

Rules:
1. Ignore and skip any files/folders that are inside of structured projects like Flutter, React, Node.js, etc. For structured projects folder return its summary in following format.
  - "filePath": full absolute path
   - "fileName": file name
   - "content": "Summary of the folder"
2. For any rearrangeable **file**, return an object with:
   - "filePath": full absolute path
   - "fileName": file name
   - "content": "file"
3. For a **folder**, only return its summary *if its inner contents should NOT be rearranged* Example of this type of folders are like Android Project, Flutter Project, etc. In that case:
   - "content": one-line summary like "contains backup logs"
4. If a folder contains rearrangeable files, don't return the folder itself—just return its children.

Return a JSON list like this:
{
  {
    "filePath": "...",
    "fileName": "...",
    "content": "file" | "one-line folder summary"
  }
}

Here is the folder structure:

${jsonEncode(folderJson)}
''';


    final response = await model.generateContent([Content.text(prompt)]);
    final res = response.text;
    var text = res;

    if (text == null) throw Exception('Gemini did not return a response.');

    try {

      print("text" + text.toString());
      text = text.substring(7,text.length-4);
      print("text 2: " + text.toString());
      final decoded = jsonDecode(text.trim());
      print("decoded" + decoded.toString());
      if (decoded is List) {
        var temp = List<Map<String, dynamic>>.from(decoded);
        print("File arranger result " + temp.toString());
        return temp;
      } else {
        throw Exception('Unexpected format from Gemini.');
      }
    } catch (e) {
      print("Error parsing Gemini response: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _buildFolderJson(Directory dir) async {
    final List<Map<String, dynamic>> structure = [];

    await for (var entity in dir.list(recursive: true, followLinks: false)) {
      final filePath = entity.path;
      final fileName = filePath
          .split(Platform.pathSeparator)
          .last;
      final isFile = entity is File;

      structure.add({
        "type": isFile ? "file" : "folder",
        "filePath": filePath,
        "fileName": fileName,
      });
    }

    return structure;
  }
}