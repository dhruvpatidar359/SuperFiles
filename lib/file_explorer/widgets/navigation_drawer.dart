// navigation_drawer.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../services/utils/file_utils.dart';
import 'nav_button.dart'; // Import your NavButton widget

class CustomNavigationDrawer extends StatelessWidget {
  final Function(String) navigateToFolder;
  final Function(String) isSelectedPath;

  const CustomNavigationDrawer({
    super.key,
    required this.navigateToFolder,
    required this.isSelectedPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Fixed width
      padding: EdgeInsets.all(10),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NavButton(
              icon: Icons.home,
              label: "Home",
              selected: isSelectedPath(
                Platform.environment['USERPROFILE'] ??
                    Platform.environment['HOME'] ??
                    '/',
              ),
              onTap: () => navigateToFolder(
                Platform.environment['USERPROFILE'] ??
                    Platform.environment['HOME'] ??
                    '/',
              ),
            ),
            NavButton(
              icon: Icons.desktop_windows,
              label: "Desktop",
              selected: isSelectedPath(
                UtilServices.getUserDirectory('Desktop'),
              ),
              onTap: () => navigateToFolder(
                UtilServices.getUserDirectory('Desktop'),
              ),
            ),
            NavButton(
              icon: Icons.folder,
              label: "Documents",
              selected: isSelectedPath(
                UtilServices.getUserDirectory('Documents'),
              ),
              onTap: () => navigateToFolder(
                UtilServices.getUserDirectory('Documents'),
              ),
            ),
            NavButton(
              icon: Icons.download,
              label: "Downloads",
              selected: isSelectedPath(
                UtilServices.getUserDirectory('Downloads'),
              ),
              onTap: () => navigateToFolder(
                UtilServices.getUserDirectory('Downloads'),
              ),
            ),
            NavButton(
              icon: Icons.image,
              label: "Pictures",
              selected: isSelectedPath(
                UtilServices.getUserDirectory('Pictures'),
              ),
              onTap: () => navigateToFolder(
                UtilServices.getUserDirectory('Pictures'),
              ),
            ),
            NavButton(
              icon: Icons.music_note,
              label: "Music",
              selected: isSelectedPath(
                UtilServices.getUserDirectory('Music'),
              ),
              onTap: () => navigateToFolder(
                UtilServices.getUserDirectory('Music'),
              ),
            ),
            NavButton(
              icon: Icons.video_library,
              label: "Videos",
              selected: isSelectedPath(
                UtilServices.getUserDirectory('Videos'),
              ),
              onTap: () => navigateToFolder(
                UtilServices.getUserDirectory('Videos'),
              ),
            ),
            // Adding available drives dynamically
            for (var drive in UtilServices.getAvailableDrives())
              NavButton(
                icon: Icons.storage,
                label: "$drive",
                selected: isSelectedPath(drive),
                onTap: () => navigateToFolder(drive),
              ),
          ],
        ),
      ),
    );
  }
}
