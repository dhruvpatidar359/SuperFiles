import 'dart:convert'; // For JSON encoding/decoding
import 'package:google_generative_ai/google_generative_ai.dart';

const String TREE_STRUCTURE_PROMPT = """
You will be provided with a list of source files, a summary of their contents, and a set of user-defined folders for classification. Using this information, create a hierarchical tree structure that optimally organizes the files according to best practices, known conventions, and the specified folders.

User-defined folders to use in the structure:
[folderNames]  

User's custom instructions:
[customPrompt]
  
(Additional folders can be created as necessary to improve organization.)

Guidelines for creating the tree:
- Start with the given folders as primary categories, and add new subfolders as necessary to enhance organization.
- Follow good naming conventions for folders and files:
    - Group related files under logical subfolders.
    - Organize based on metadata such as date, version, sample, or experiment.
    - Minimize the use of spaces or special characters in names.
- Generate three unique hierarchical structures:
    - Each structure should demonstrate a distinct way of classifying the files, while adhering to the user-defined folder structure.
    - In each structure, provide clear folder and subfolder names and include sample file names that match conventions.
    - Ensure each structure is completely unique from the others.
    
If the file is already named well or matches a known convention, set the destination path to the same as the source path.

Your response must be a JSON object with the following schema:
You should include 3 different suggestion for each(Each one should be completely different and unique from other), Give JSON as given below
```json
{
    "files1": [
        {
            "src_path": "original file path",
            "suggested_file_name": "the Proposed file name",
            "dst_path": "new folder path under proposed directory structure without proposed file name",
            "summary": "The summary of the file given by user"
        }
    ],
    "files2": [
        {
            "src_path": "original file path",
            "suggested_file_name": "the Proposed file name",
            "dst_path": "new folder path under proposed directory structure without proposed file name",
            "summary": "The summary of the file given by user"
        }
    ],
    "files3": [
        {
            "src_path": "original file path",
            "suggested_file_name": "the Proposed file name",
            "dst_path": "new folder path under proposed directory structure without proposed file name",
            "summary": "The summary of the file given by user"
        }
    ]
}
Below is the files Data: """;

class TreeGeneratorUserDefined {
  final GenerativeModel model;

  TreeGeneratorUserDefined(this.model);

  Future<String?> createFileTree(String summaries, String folders,
      {String customPrompt = ""}) async {
    try {
      // Replace placeholders in the prompt template
      String modifiedPrompt = TREE_STRUCTURE_PROMPT
          .replaceFirst("[folderNames]", folders)
          .replaceFirst(
              "[customPrompt]", customPrompt.isEmpty ? "None" : customPrompt);

      final String prompt = modifiedPrompt + summaries;
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

      print('Raw response after replacement: $responseText');

      return responseText;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
