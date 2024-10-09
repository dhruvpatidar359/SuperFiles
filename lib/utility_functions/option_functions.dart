import 'dart:io';
import 'package:path/path.dart' as path;

class UtilityFunctions {
  // Function to delete the file given the path
  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);

      // Check if the file exists
      if (await file.exists()) {
        await file.delete();
        print('File deleted successfully: $filePath');
      } else {
        print('File does not exist: $filePath');
      }
    } catch (e) {
      print('Error occurred while deleting file: $e');
    }
  }

  // Function to rename the file
  static Future<void> renameFile(String currentPath, String newName) async {
    try {
      final entity = FileSystemEntity.typeSync(currentPath);

      if (entity == FileSystemEntityType.file) {
        final file = File(currentPath);

        // Extract the directory path and the file extension
        String directory = file.parent.path;
        String extension =
        path.extension(file.path); // Keep the original extension

        // Construct the new path with the original extension
        String newPath = path.join(directory, '$newName$extension');

        // Check if the file exists
        if (await file.exists()) {
          try {
            // Try renaming the file
            await file.rename(newPath);
            print('File renamed successfully: $newPath');
          } catch (e) {
            print('Rename failed: $e');
          }
        } else {
          print('File does not exist: $currentPath');
        }
      } else if (entity == FileSystemEntityType.directory) {
        final directory = Directory(currentPath);

        // Construct the new directory path
        String parentDirectory = directory.parent.path;
        String newDirectoryPath = path.join(parentDirectory, newName);

        // Check if the directory exists
        if (await directory.exists()) {
          try {
            // Try renaming the directory
            await directory.rename(newDirectoryPath);
            print('Directory renamed successfully: $newDirectoryPath');
          } catch (e) {
            print('Rename failed: $e');
          }
        } else {
          print('Directory does not exist: $currentPath');
        }
      } else {
        print('The provided path is neither a file nor a directory.');
      }
    } catch (e) {
      print('Error occurred while renaming: $e');
    }
  }

  // Function to move the file to a new location
  static Future<void> moveFile(String currentPath, String newLocation) async {
    try {
      final file = File(currentPath);

      // Get the file name
      String fileName = path.basename(currentPath);

      // Construct the new path
      String newPath = path.join(newLocation, fileName);

      // Check if the file exists
      if (await file.exists()) {
        // Move the file
        await file.rename(newPath);
        print('File moved successfully to: $newPath');
      } else {
        print('File does not exist: $currentPath');
      }
    } catch (e) {
      print('Error occurred while moving file: $e');
    }
  }
}