import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../utility_functions/option_functions.dart';
import '../../widgets/directory_picker_dialog.dart';


class FileSystemService {
  static void openFile(String filePath,BuildContext context) async {
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: ${result.message}')),
      );
    }
  }

  static Future<void> handleMove(
      BuildContext context, FileSystemEntity entity) async {
    String fullPath = entity.path;

    String newName = await promptForMove(context, fullPath);
    if (newName.isNotEmpty) {
      // Confirm rename action
      bool confirmed = await confirmAction(context, 'move');
      if (confirmed) {
        // Call move file function from UtilityFunctions
        UtilityFunctions.moveFile(entity.path, newName);
      }
    }
  }

  static Future<void> handleRename(
      BuildContext context, FileSystemEntity entity) async {
    // Ask user for new file name
    String fullPath = entity.path;

    // Extract the file name by splitting at the directory separator and getting the last element
    String currentFileName = fullPath.split(Platform.pathSeparator).last;
    String newName = await promptForRename(context, currentFileName);
    if (newName.isNotEmpty) {
      // Confirm rename action
      bool confirmed = await confirmAction(context, 'rename');
      if (confirmed) {
        // Call rename file function from UtilityFunctions
        UtilityFunctions.renameFile(entity.path, newName);
      }
    }
  }

  static Future<void> handleDelete(
      BuildContext context, FileSystemEntity entity) async {
    // Confirm delete action
    bool confirmed = await confirmAction(context, 'delete');
    if (confirmed) {
      // Call delete file function from UtilityFunctions
      UtilityFunctions.deleteFile(entity.path);
    }
  }

// Function to prompt for renaming
  static Future<String> promptForRename(BuildContext context, String hintText) async {
    String newName = '';
    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename File'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // User canceled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, newName); // Close dialog with new name
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
    return newName;
  }

// Modify the promptForMove function to allow browsing directories
  static Future<String> promptForMove(
      BuildContext context, String currentLocation) async {
    String newLocation = '';
    await showDialog<String>(
      context: context,
      builder: (context) {
        return DirectoryPickerDialog(
          initialDirectory: currentLocation,
        );
      },
    ).then((selectedPath) {
      if (selectedPath != null) {
        newLocation = selectedPath;
      }
    });
    return newLocation;
  }

// Function to confirm actions (like delete, rename)
  static Future<bool> confirmAction(BuildContext context, String action) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm $action'),
          content: Text('Are you sure you want to $action this file?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, true), // User confirmed
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false), // User canceled
              child: Text('No'),
            ),
          ],
        );
      },
    ) ??
        false; // Return false if dialog is dismissed without selection
  }

}