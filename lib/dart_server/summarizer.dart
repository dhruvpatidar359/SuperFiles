import 'dart:convert';  // For JSON encoding
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

class Summarizer {
  final GenerativeModel model;

  Summarizer(this.model);

  // Summarize a single file's content and return a JSON string
  Future<String> summarizeFile(String filePath, String content) async {
    // Define the prompt with the file content
    final prompt = '''
You will be provided with the contents of a file along with its metadata. Provide a summary of the contents. The purpose of the summary is to organize files based on their content. To this end provide a concise but informative summary. Make the summary as specific to the file as possible.

```{
   "file_path": "path to the file including name",
   "summary": " summary of the content"
}```

    
Below is the file's data with file path and its content:
$filePath
$content
    ''';

    print('Summarizing file: $filePath');
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
    String strBuf = summaryBuffer.toString().substring(7, summaryBuffer.length - 3);
    print(strBuf);

    // Return the result as a JSON string
    Map<String, dynamic> result = {
      "file_path": filePath,
      "summary": summaryBuffer.toString()
    };

    return strBuf;
    // return jsonEncode(strBuf);  // Convert to JSON string
    // return summaryBuffer.toString();
  }
}
