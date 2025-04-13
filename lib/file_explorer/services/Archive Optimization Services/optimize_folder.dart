import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

/// Organizes a given folder by moving files older than 90 days
/// into an `Archive` subfolder within that folder.
// Future<void> optimizeFolder(String folderPath) async {
//   try {
//     final directory = Directory(folderPath);
//     if (!await directory.exists()) {
//       print("❌ Folder does not exist: $folderPath");
//       return;
//     }
//
//     final archiveFolder = Directory('${directory.path}/Archive');
//
//     // Create Archive folder if not exists
//     if (!await archiveFolder.exists()) {
//       await archiveFolder.create();
//       print("📁 Created archive folder: ${archiveFolder.path}");
//     }
//
//     final now = DateTime.now();
//     final files = directory.listSync(recursive: false);
//
//     for (var entity in files) {
//       if (entity is File) {
//         final stat = await entity.stat();
//         final modifiedDate = stat.modified;
//
//         // If older than 90 days, move it
//         if (now.difference(modifiedDate).inDays > 90) {
//           final fileName = entity.uri.pathSegments.last;
//           final newPath = '${archiveFolder.path}/$fileName';
//
//           try {
//             await entity.rename(newPath);
//             print("✅ Archived: $fileName");
//           } catch (e) {
//             print("⚠️ Could not move $fileName: $e");
//           }
//         }
//       }
//     }
//
//     print("🎉 Organize completed for: $folderPath");
//
//   } catch (e) {
//     print("🚨 Error during organization: $e");
//   }
// }
Future<String> organizeAndArchiveFolder(String folderPath) async {
  final dir = Directory(folderPath);
  if (!await dir.exists()) return '❌ Folder doesn’t exist';

  final archiveDir = Directory(p.join(folderPath, 'archive'));
  if (!await archiveDir.exists()) await archiveDir.create();

  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 90));
  final files = dir.listSync(recursive: false).whereType<File>();

  final Map<String, List<File>> filesByMonth = {};
  int movedCount = 0;

  for (final file in files) {
    final stat = await file.stat();
    if (stat.modified.isBefore(cutoff)) {
      final monthKey = '${stat.modified.year}-${stat.modified.month.toString().padLeft(2, '0')}';
      filesByMonth.putIfAbsent(monthKey, () => []).add(file);
      movedCount++;
    }
  }

  for (final entry in filesByMonth.entries) {
    final month = entry.key;
    final zipPath = p.join(archiveDir.path, '$month.zip');
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    for (final file in entry.value) {
      encoder.addFile(file);
      await file.delete(); // clean up original
    }

    encoder.close();
  }

  return '✅ Done ($movedCount files zipped)';
}
