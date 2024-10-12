import 'package:flutter/material.dart';

class FilePopupMenu {
  static void show(BuildContext context, Offset position, Function(String) onSelect) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'organize',
          child: ListTile(
            leading: Icon(Icons.folder),
            title: Text('Organize'),
            onTap: () {
              Navigator.pop(context, 'organize');
              onSelect('organize');
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'move',
          child: ListTile(
            leading: Icon(Icons.drive_file_move),
            title: Text('Move'),
            onTap: () {
              Navigator.pop(context, 'move');
              onSelect('move');
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'rename',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Rename'),
            onTap: () {
              Navigator.pop(context, 'rename');
              onSelect('rename');
            },
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
            onTap: () {
              Navigator.pop(context, 'delete');
              onSelect('delete');
            },
          ),
        ),
      ],
    );
  }
}
