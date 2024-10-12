// import 'package:watcher/watcher.dart';
//
// class WatcherService{
//   void _handleFileSystemEvent(WatchEvent event) async {
//     if (!isAutoOrganizeEnabled) return;
//
//     final filePath = event.path;
//     final entityType = await FileSystemEntity.type(filePath);
//
//     switch (event.type) {
//       case ChangeType.ADD:
//         if (entityType == FileSystemEntityType.file) {
//           // Handle file addition
//           await _handleFileAdded(filePath);
//         }
//         break;
//       case ChangeType.MODIFY:
//         if (entityType == FileSystemEntityType.file) {
//           // Handle file modification
//           await _handleFileModified(filePath);
//         }
//         break;
//       case ChangeType.REMOVE:
//         if (entityType == FileSystemEntityType.file) {
//           // Handle file removal
//           await _handleFileRemoved(filePath);
//         }
//         break;
//     }
//   }
//   static void _startWatching(String currentPath) {
//     _stopWatching(); // Ensure previous watchers are cancelled
//
//     // Start watching the current directory
//     final directoryWatcher = DirectoryWatcher(currentPath);
//     print("we are watching to the $currentPath");
//     _directoryWatcherSubscription = directoryWatcher.events.listen((event) {
//       _handleFileSystemEvent(event);
//     });
//   }
// }