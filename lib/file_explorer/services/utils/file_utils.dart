import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class UtilServices {
  static String getUserDirectory(String folderName) {
    String homeDir = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '/';
    return path.join(homeDir, folderName);
  }

  static List<String> getAvailableDrives() {
    if (Platform.isWindows) {
      // On Windows, generate A-Z drive letters and safely check if a drive exists and is accessible
      return List.generate(26, (i) => String.fromCharCode(i + 65) + ':\\')
          .where((drive) {
        try {
          var dir = Directory(drive);
          // Check if the drive exists and can be listed (avoids unmounted CD/DVDs)
          return dir.existsSync() && dir.listSync(recursive: false).isNotEmpty;
        } catch (e) {
          return false; // Drive is not accessible or does not exist
        }
      }).toList();
    } else if (Platform.isLinux) {
      // On Linux, filter out only mounted external/internal storage (excluding pseudo-filesystems)
      List<String> drives = [];
      try {
        File('/proc/mounts').readAsLinesSync().forEach((line) {
          var parts = line.split(' ');
          if (parts.length > 1) {
            var mountPoint = parts[1];
            if ((mountPoint.startsWith('/media') ||
                    mountPoint == '/mnt' ||
                    mountPoint == '/') &&
                Directory(mountPoint).existsSync()) {
              drives.add(mountPoint);
            }
          }
        });
      } catch (_) {}
      return drives.toSet().toList(); // Remove duplicates
    } else if (Platform.isMacOS) {
      try {
        return Directory('/Volumes')
            .listSync()
            .whereType<Directory>()
            .where((dir) => dir
                .listSync(recursive: false)
                .isNotEmpty) // avoid empty volumes
            .map((dir) => dir.path)
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  // Helper function to format bytes into a more readable format
  static String formatBytes(int bytes, int decimals) {
    if (bytes == 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    var size = bytes /
        pow(1024, i).toDouble(); // Ensure result is double for formatting
    return size.toStringAsFixed(decimals) + " " + suffixes[i];
  }

  IconData getIcon(FileSystemEntity entity) {
    if (entity is Directory) {
      return Icons.folder;
    } else if (entity is File) {
      String extension = path.extension(entity.path).toLowerCase();
      switch (extension) {
        case '.jpg':
        case '.jpeg':
        case '.png':
        case '.gif':
          return Icons.image;
        case '.mp3':
        case '.wav':
          return Icons.music_note;
        case '.mp4':
        case '.avi':
          return Icons.movie;
        case '.pdf':
          return Icons.picture_as_pdf;
        case '.doc':
        case '.docx':
          return Icons.description;
        case '.txt':
          return Icons.text_snippet;
        case '.zip':
        case '.rar':
          return Icons.archive;
        default:
          return Icons.insert_drive_file;
      }
    }
    return Icons.help;
  }
}
