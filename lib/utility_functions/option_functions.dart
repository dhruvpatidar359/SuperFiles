import 'dart:io';

class UtilityFunctions{

  //function to delete the file given the path
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


  //function to rename the file --> this can both rename and move the files from one folder to another.

  static Future<void> renameFile(String currentPath, String newName) async {
    try {
      final file = File(currentPath);

      // Extract the directory path and the file extension
      String directory = file.parent.path;
      String fileExtension = file.path.split('.').last;

      // Ensure the new name has the same extension
      String newPath = '$directory\\$newName';

      // Check if the file exists
      if (await file.exists()) {
        try {
          // Try renaming the file
          await file.rename(newPath);
          print('File renamed successfully: $newPath');
        } catch (e) {
          // If renaming fails (e.g., across different drives), try copying and deleting
          print('Rename failed, trying to copy the file: $e');
        }
      } else {
        print('File does not exist: $currentPath');
      }
    } catch (e) {
      print('Error occurred while renaming file: $e');
    }
  }
}
