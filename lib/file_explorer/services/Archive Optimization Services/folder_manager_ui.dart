import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../Databases/database_helper.dart';
import 'organizer_runner.dart';

class FolderManager extends StatefulWidget {
  const FolderManager({Key? key}) : super(key: key);

  @override
  State<FolderManager> createState() => _FolderManagerState();
}

class _FolderManagerState extends State<FolderManager> {
  List<String> folders = [];
  Map<String, String> folderStatus = {};

  Future<void> _loadFolders() async {
    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    folders = await DatabaseHelper.getAllFolders(databaseHelper);
    setState(() {
      folderStatus = {for (var f in folders) f: 'Idle 💤'};
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _addFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path != null && !folders.contains(path)) {
      final db = DatabaseHelper.instance;
      Database databaseHelper = await db.getDatabase();
      await DatabaseHelper.insertFolder(databaseHelper, path);
      await _loadFolders();
    }
  }

  Future<void> _removeFolder(String path) async {
    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    await DatabaseHelper.deleteFolder(databaseHelper, path);
    await _loadFolders();
  }

  Future<void> _optimizeAll() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🧹 Organizing folders in background...")),
    );

    for (final folder in folders) {
      setState(() {
        folderStatus[folder] = '⏳ In Progress';
      });

      try {
        final result = await runOrganizerInIsolate(folder);
        setState(() {
          folderStatus[folder] = result;
        });
      } catch (e) {
        setState(() {
          folderStatus[folder] = '❌ Failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📁 Folder Organizer"),
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _addFolder,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Folder"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _optimizeAll,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Run Optimizer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: folders.isEmpty
                  ? const Center(
                  child: Text("No folders added yet 🗂️",
                      style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  final status = folderStatus[folder] ?? 'Idle 💤';

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 4),
                    child: ListTile(
                      leading: const Icon(Icons.folder,
                          color: Colors.deepPurple),
                      title: Text(
                        folder.split('/').last,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(status),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFolder(folder),
                      ),
                      onTap: () {
                        // Optionally, show full folder path in dialog
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Folder Path"),
                            content: Text(folder),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text("Close"))
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
