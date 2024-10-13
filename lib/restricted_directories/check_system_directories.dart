import 'dart:io';
import 'package:path/path.dart' as p; // Add path dependency in pubspec.yaml

// List of Windows system folders
List<String> windowsSystemFolders = [
  'C:\\Windows',
  'C:\\Windows\\System32',
  'C:\\Windows\\SysWOW64',
  'C:\\Program Files',
  'C:\\Program Files (x86)',
  'C:\\Windows\\Fonts',
  'C:\\Windows\\Temp',
  'C:\\ProgramData',
  'C:\\Windows\\INF',
  'C:\\Windows\\Logs',
  'C:\\Windows\\SoftwareDistribution',
  'C:\\Windows\\Servicing',
  'C:\\Windows\\Prefetch',
  'C:\\Windows\\Assembly'
];

// List of Linux system folders
List<String> linuxSystemFolders = [
  '/bin',
  '/sbin',
  '/usr/bin',
  '/usr/sbin',
  '/lib',
  '/lib64',
  '/usr/lib',
  '/usr/local',
  '/etc',
  '/var',
  '/opt',
  '/root',
  '/boot',
  '/sys',
  '/proc'
];

// Function to check if a folder is a system folder or a subfolder of system folders
bool isSubFolderOrSystemFolder(String folderPath) {
  // Normalize the input folder path to absolute form
  final absoluteFolderPath = p.normalize(folderPath);

  // Get the current operating system
  String os = Platform.operatingSystem;

  // Choose system folders based on the OS
  List<String> systemFolders = os == 'windows' ? windowsSystemFolders : linuxSystemFolders;

  for (var systemFolder in systemFolders) {
    // Normalize system folder path
    final absoluteSystemFolderPath = p.normalize(systemFolder);

    // Check if the folder is either the system folder itself or within a system folder
    if (absoluteFolderPath == absoluteSystemFolderPath || p.isWithin(absoluteSystemFolderPath, absoluteFolderPath)) {
      return true; // The provided folder is either a system folder or a subfolder
    }
  }

  return false; // Not a system folder or a subfolder of any system folders
}