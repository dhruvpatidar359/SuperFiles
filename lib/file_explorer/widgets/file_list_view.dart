// file_list_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import '../services/utils/file_utils.dart';
import 'file_item_card.dart'; // Import your FileItemCard

class FileListView extends StatelessWidget {
  final List<FileSystemEntity> filesAndFolders;
  final bool isCardView;
  final bool showSummary;
  final Function(FileSystemEntity) onEntityTap;
  final Function(FileSystemEntity) onEntityDoubleTap;
  final Function(TapDownDetails, FileSystemEntity, bool) onSecondaryTapDown;
  final Function(String, FileSystemEntity) onMenuItemSelected;

  const FileListView({
    Key? key,
    required this.filesAndFolders,
    required this.isCardView,
    required this.showSummary,
    required this.onEntityTap,
    required this.onEntityDoubleTap,
    required this.onSecondaryTapDown,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCardView
        ? GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: showSummary ? 7 : 8,
        childAspectRatio: 0.8,
      ),
      itemCount: filesAndFolders.length,
      itemBuilder: (context, index) {
        FileSystemEntity entity = filesAndFolders[index];
        bool isFolder = entity is Directory;
        IconData icon = UtilServices().getIcon(entity);
        return GestureDetector(
          onTap: () => onEntityTap(entity),
          onDoubleTap: () => onEntityDoubleTap(entity),
          onSecondaryTapDown: (details) => onSecondaryTapDown(details, entity, isFolder),
          child: FileItemCard(
            entity: entity,
            name: path.basename(entity.path),
            isFolder: isFolder,
            isCardView: isCardView,
            icon: icon,
            onMenuItemSelected: (String value) {
              onMenuItemSelected(value, entity);
            },
          ),
        );
      },
    )
        : ListView.builder(
      itemCount: filesAndFolders.length,
      itemBuilder: (context, index) {
        FileSystemEntity entity = filesAndFolders[index];
        IconData icon = UtilServices().getIcon(entity);
        return GestureDetector(
          onTap: () => onEntityTap(entity),
          onDoubleTap: () => onEntityDoubleTap(entity),
          child: ListTile(
            leading: Icon(icon),
            title: Text(path.basename(entity.path)),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (String value) {
                onMenuItemSelected(value, entity);
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
        );
      },
    );
  }
}
