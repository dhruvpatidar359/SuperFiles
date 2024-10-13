// Create a DirectoryPickerDialog widget
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class DirectoryPickerDialog extends StatefulWidget {
  final String initialDirectory;

  DirectoryPickerDialog({required this.initialDirectory});

  @override
  _DirectoryPickerDialogState createState() => _DirectoryPickerDialogState();
}

class _DirectoryPickerDialogState extends State<DirectoryPickerDialog> {
  late String currentDirectory;
  List<FileSystemEntity> directories = [];

  @override
  void initState() {
    super.initState();
    currentDirectory = widget.initialDirectory;
    _loadDirectories();
  }

  void _loadDirectories() {
    try {
      Directory dir = Directory(currentDirectory);
      List<FileSystemEntity> entities = dir
          .listSync()
          .where((entity) => FileSystemEntity.isDirectorySync(entity.path))
          .toList();
      setState(() {
        directories = entities;
      });
    } catch (e) {
      print("Error accessing directory: $e");
    }
  }

  void _navigateTo(String path) {
    setState(() {
      currentDirectory = path;
      _loadDirectories();
    });
  }

  void _navigateUp() {
    String parentPath = Directory(currentDirectory).parent.path;
    _navigateTo(parentPath);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Destination Folder'),
      content: Container(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Address bar
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _navigateUp,
                ),
                Expanded(
                  child: Text(
                    currentDirectory,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Divider(),
            // Directory list
            Expanded(
              child: ListView.builder(
                itemCount: directories.length,
                itemBuilder: (context, index) {
                  FileSystemEntity entity = directories[index];
                  return ListTile(
                    leading: Icon(Icons.folder),
                    title: Text(path.basename(entity.path)),
                    onTap: () {
                      _navigateTo(entity.path);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
            Navigator.pop(context,
                currentDirectory); // Close dialog with selected directory
          },
          child: Text('Select'),
        ),
      ],
    );
  }
}