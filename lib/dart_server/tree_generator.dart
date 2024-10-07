import 'dart:convert'; // For JSON encoding/decoding
import 'package:google_generative_ai/google_generative_ai.dart';

const String FILE_PROMPT = """
You will be provided with a list of source files and a summary of their contents. For each file, propose a new path and filename, using a directory structure that optimally organizes the files using known conventions and best practices.
Follow good naming conventions. Here are a few guidelines:
- Think about your files: What related files are you working with?
- Identify metadata (for example, date, sample, experiment): What information is needed to easily locate a specific file?
- Abbreviate or encode metadata.
- Use versioning: Are you maintaining different versions of the same file?
- Think about how you will search for your files: What comes first?
- Deliberately separate metadata elements: Avoid spaces or special characters in your file names.
If the file is already named well or matches a known convention, set the destination path to the same as the source path.

Your response must be a JSON object with the following schema:
```json
{
    "files": [
        {
            "src_path": "original file path",
            "suggested_file_name": "the Proposed file name",
            "dst_path": "new file path under proposed directory structure with proposed file name"
        }
    ]
}
Below is the files Data: """;

class TreeGenerator {
  final GenerativeModel model;

  TreeGenerator(this.model);

// Method to generate the tree structure using file summaries
//   Future<Map<String, dynamic>?> createFileTree(
  Future<String?> createFileTree(
      String summaries) async {
      // List<Map<String, String>> summaries) async {
    try {

      // Convert summaries list to JSON format
      // final String summariesData = jsonEncode(summaries);
      final String summariesData = summaries;
      final String prompt = FILE_PROMPT + summariesData;
      print('Sending prompt: $prompt');

      final Content contentMessage = Content.text(prompt);

      // Start the chat session
      final chatSession = model.startChat(history: []);

      // Send the prompt to the model
      final response = await chatSession.sendMessage(contentMessage);

      // Extract the JSON response from the model's output
      String? responseText = response.text;
      print('Raw response: $responseText');

      // Clean the markdown formatting, if any
      responseText =
          responseText?.replaceAll('```json\n', '').replaceAll('\n```', '');


      return responseText;
      // Parse the response into a JSON object
      final Map<String, dynamic> fileTree = jsonDecode(responseText!);
      // return fileTree;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
