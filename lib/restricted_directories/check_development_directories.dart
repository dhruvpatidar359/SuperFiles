import 'dart:io';
import 'package:path/path.dart' as p;

// List of common indicators for app development (mobile/desktop) folders
List<String> appDevelopmentIndicators = [
  'android',     // Flutter, Native Android
  'ios',         // Flutter, Native iOS
  'pubspec.yaml', // Flutter
  'build.gradle', // Android
  'gradle',      // Android project structure
  'flutter',     // Flutter directory
  'electron',    // Electron app development
  'main.dart',   // Dart main file for Flutter apps
  'main.js'      // Electron main process entry point
];

// List of common indicators for web development folders
List<String> webDevelopmentIndicators = [
  'package.json', // Node.js, npm/yarn projects
  'index.html',   // Web project entry point
  'webpack.config.js', // Webpack config for web projects
  'src',         // Source folder for web projects
  'public',      // Public assets for web projects
  'node_modules', // Node.js dependencies
  '.env',        // Environment variables for web projects
  'vite.config.js', // Vite config for modern web projects
  'next.config.js', // Next.js configuration for web development
];

// Function to recursively check if a folder or its subfolders is an app development folder
bool isAppDevelopmentFolder(String folderPath) {
  final dir = Directory(folderPath);

  // List entities (files and subdirectories) recursively
  List<FileSystemEntity> entities = dir.listSync(recursive: true);

  for (var entity in entities) {
    final entityName = p.basename(entity.path);

    if (appDevelopmentIndicators.contains(entityName)) {
      return true; // The folder or a subfolder is an app development folder
    }
  }

  return false; // Not identified as an app development folder
}

// Function to recursively check if a folder or its subfolders is a web development folder
bool isWebDevelopmentFolder(String folderPath) {
  final dir = Directory(folderPath);

  // List entities (files and subdirectories) recursively
  List<FileSystemEntity> entities = dir.listSync(recursive: true);

  for (var entity in entities) {
    final entityName = p.basename(entity.path);

    if (webDevelopmentIndicators.contains(entityName)) {
      return true; // The folder or a subfolder is a web development folder
    }
  }

  return false; // Not identified as a web development folder
}