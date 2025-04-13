// lib/background/organizer_runner.dart
import 'dart:isolate';
import 'organizer_isolate.dart';

// Future<String> runOrganizerInIsolate(String folderPath) async {
//   final receivePort = ReceivePort();
//   final isolate = await Isolate.spawn(folderOrganizerIsolate, receivePort.sendPort);
//
//   final sendPort = await receivePort.first as SendPort;
//   final responsePort = ReceivePort();
//
//   sendPort.send(folderPath);
//   final result = await responsePort.first;
//
//   isolate.kill(priority: Isolate.immediate);
//   return result.toString();
// }
Future<String> runOrganizerInIsolate(String folderPath) async {
  final receivePort = ReceivePort();
  final isolate = await Isolate.spawn(folderOrganizerIsolate, receivePort.sendPort);

  final sendPort = await receivePort.first as SendPort;
  final responsePort = ReceivePort();

  sendPort.send([folderPath, responsePort.sendPort]);

  final result = await responsePort.first as String;

  isolate.kill();
  return result;
}

