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
    Key? key,
    required this.name,
    required this.isFolder,
    required this.isCardView,
    required this.icon,
    required this.entity,
    required this.onMenuItemSelected,
  }) : super(key: key);

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

    if (isCardView) {
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
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (String value) {
                  onMenuItemSelected(value);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (entity is Directory)
                    const PopupMenuItem<String>(
                      value: 'organize',
                      child: Text('Organize'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'move',
                    child: Text('Move'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'rename',
                    child: Text('Rename'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return ListTile(
        leading: content,
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (String value) {
            onMenuItemSelected(value);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            if (entity is Directory)
              const PopupMenuItem<String>(
                value: 'organize',
                child: Text('Organize'),
              ),
            const PopupMenuItem<String>(
              value: 'move',
              child: Text('Move'),
            ),
            const PopupMenuItem<String>(
              value: 'rename',
              child: Text('Rename'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      );
    }
  }
}
