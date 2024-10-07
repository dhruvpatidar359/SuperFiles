import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// Main function to extract text based on file extension
Future<String> extractTextFromFile(String filePath) async {
  try {
    // Extract file extension
    String extension = filePath.split('.').last.toLowerCase();

    // Call the appropriate extraction function based on the file extension
    switch (extension) {
      case 'pdf':
        return await extractTextFromPDF(filePath);

      case 'txt':
      case 'c':
      case 'cpp':
      case 'py':
      case 'java':
      case 'js':
      case 'html':
      case 'css':
      case 'php':
      case 'swift':
      case 'dart':
      case 'rb':
        return await extractTextFromSourceCode(filePath);

      case 'docx':
        return await extractTextFromDocx(filePath);

      case 'csv':
        return await extractTextFromCSV(filePath);

      case 'png':
      case 'jpeg':
        return await sendPhotoWithPrompt(filePath);

      default:
        return "Unsupported file type: $extension";
    }
  } catch (e) {
    return "Error extracting text: $e";
  }
}

// Extract text from PDF files
Future<String> extractTextFromPDF(String filePath) async {
  try {
    final PdfDocument document = PdfDocument(inputBytes: File(filePath).readAsBytesSync());
    String fullText = PdfTextExtractor(document).extractText();
    document.dispose();
    return fullText;
  } catch (e) {
    return "Error extracting text from PDF: $e";
  }
}

// Extract text from source code and plain text files
Future<String> extractTextFromSourceCode(String filePath) async {
  try {
    return File(filePath).readAsStringSync();  // Read the content as a string
  } catch (e) {
    return "Error extracting text from file: $e";
  }
}

// Extract text from DOCX files
Future<String> extractTextFromDocx(String filePath) async {
  try {
    final fileBytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(fileBytes);

    for (final file in archive.files) {
      if (file.name == 'word/document.xml') {
        final content = file.content as List<int>;
        final xmlString = String.fromCharCodes(content);
        final document = XmlDocument.parse(xmlString);
        final textElements = document.findAllElements('w:t');
        final text = textElements.map((node) => node.text).join(' ');
        return text;
      }
    }

    return "Error: document.xml not found in DOCX file";
  } catch (e) {
    return "Error extracting text from DOCX: $e";
  }
}

// Extract text from CSV files
Future<String> extractTextFromCSV(String filePath) async {
  try {
    final input = File(filePath).openRead();
    final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();
    return fields.map((e) => e.join(', ')).join('\n');
  } catch (e) {
    return "Error extracting text from CSV: $e";
  }
}

// Extract the summary of the text file from gemini
Future<String> sendPhotoWithPrompt(String imagePath) async {

  late final GenerativeModel _model;

  _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw', // Secure the API key!
  );

  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
  <({Image? image, String? text, bool fromUser})>[];


  try {
    // Set the prompt message
    String message = "give context of image concise and precise";

    // Load the image from the local file system
    Uint8List imageBytes = await File(imagePath).readAsBytes();

    // Create the content payload (with a single image and a text message)
    String extension = imagePath.split('.').last.toLowerCase();
    String mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';

    final content = [
      Content.multi([
        TextPart(message),
        DataPart(mimeType, imageBytes), // Only one image
      ])
    ];

    // Make API call to generate content
    var response = await _model.generateContent(content);
    String text = response.text.toString();

    return text;
  }
  catch(e){
    return "Error generating the summary: $e";
  }
}
