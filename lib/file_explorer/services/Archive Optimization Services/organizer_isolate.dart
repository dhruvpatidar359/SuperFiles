// lib/background/organizer_isolate.dart
import 'dart:isolate';
import 'dart:io';

import 'optimize_folder.dart';

void folderOrganizerIsolate(SendPort sendPort) async {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (final message in port) {
    final folderPath = message[0] as String;
    final replyPort = message[1] as SendPort;

    try {
      final result = await organizeAndArchiveFolder(folderPath);
      replyPort.send(result);
    } catch (e) {
      replyPort.send('❌ Failed: $e');
    }
  }
}
