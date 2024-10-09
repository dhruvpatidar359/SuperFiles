// file_item_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class FileItemCard extends StatelessWidget {
  final String name;
  final bool isFolder;
  final bool isCardView;
  final IconData icon;
  final FileSystemEntity entity;
  final Function(String) onMenuItemSelected;

  const FileItemCard({
    super.key,
    required this.name,
    required this.isFolder,
    required this.isCardView,
    required this.icon,
    required this.entity,
    required this.onMenuItemSelected,
  });

  bool _isImageFile(String extension) {
    return ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final fileExtension = path.extension(entity.path).toLowerCase();
    Widget content;

    if (!isFolder && _isImageFile(fileExtension)) {
      // Display image thumbnail
      content = Image.file(
        File(entity.path),
        fit: BoxFit.cover,
      );
    } else {
      // Display icon centered
      content = Icon(icon, size: 40);
    }

     return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(5), // Reduced margin
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(child: content),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0), // Reduced padding
                  child: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  }
}
