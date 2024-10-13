import 'dart:io';
import 'package:path/path.dart' as p; // Add path dependency in pubspec.yaml

// List of common software installation directories for Windows
List<String> windowsSoftwareFolders = [
  'C:\\Program Files',
  'C:\\Program Files (x86)',
  'C:\\ProgramData',
  'C:\\Users\\YourUserName\\AppData\\Local'
];

// List of common software installation directories for Linux
List<String> linuxSoftwareFolders = [
  '/usr/local',
  '/opt',
  '/usr/bin',
  '/usr/sbin',
  '/var/lib',
  '/var/cache',
  '/etc',
  '/home/username/.local/share'
];

// Function to check if a folder was likely created during software installation
bool isSoftwareInstallFolder(String folderPath) {
  // Normalize the input folder path to absolute form
  final absoluteFolderPath = p.normalize(folderPath);

  // Get the current operating system
  String os = Platform.operatingSystem;

  // Choose software installation folders based on the OS
  List<String> softwareFolders = os == 'windows' ? windowsSoftwareFolders : linuxSoftwareFolders;

  for (var softwareFolder in softwareFolders) {
    // Normalize software folder path
    final absoluteSoftwareFolderPath = p.normalize(softwareFolder);

    // Check if the folder is within any software installation directories
    if (absoluteFolderPath == absoluteSoftwareFolderPath || p.isWithin(absoluteSoftwareFolderPath, absoluteFolderPath)) {
      return true; // The provided folder is within a software installation folder
    }
  }

  return false; // Not within a known software installation folder
}