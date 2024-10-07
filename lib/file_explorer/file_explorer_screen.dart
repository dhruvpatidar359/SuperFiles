// file_explorer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'nav_button.dart';
import 'file_item_card.dart';
import 'database_helper.dart';

class FileExplorerScreen extends StatefulWidget {
  @override
  _FileExplorerScreenState createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool isCardView = true;
  String currentPath = Directory.current.path;
  List<FileSystemEntity> filesAndFolders = [];
  TextEditingController pathController = TextEditingController();
  FileSystemEntity? selectedEntity;
  bool showSummary = false;
  double summaryWidth = 250;
  double minSummaryWidth = 150;
  double maxSummaryWidth = 400;
  late Database database;

  @override
  void initState() {
    super.initState();
    _initializeDatabase(); // Initialize the database
    pathController.text = currentPath;
    _loadFilesAndFolders();
  }

  @override
  void dispose() {
    database.close(); // Close the database when done
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    // Initialize FFI
    sqfliteFfiInit();

    // Use the ffi factory
    var databaseFactory = databaseFactoryFfi;

    // Get the application documents directory
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(appDocDir.path, 'summaries.db');

    // Open the database
    database = await databaseFactory.openDatabase(dbPath);

    // Create the summaries table if it doesn't exist
    await database.execute('''
      CREATE TABLE IF NOT EXISTS summaries (
        filePath TEXT PRIMARY KEY,
        summary TEXT NOT NULL
      )
    ''');
  }

  void _loadFilesAndFolders() {
    try {
      Directory dir = Directory(currentPath);
      List<FileSystemEntity> entities = dir.listSync();
      setState(() {
        filesAndFolders = entities;
        pathController.text = currentPath;
        selectedEntity = null;
        showSummary = false;
      });
    } catch (e) {
      print("Error accessing directory: $e");
    }
  }

  void _navigateToFolder(String path) {
    setState(() {
      currentPath = path;
      _loadFilesAndFolders();
    });
  }

  void _navigateUp() {
    String parentPath = Directory(currentPath).parent.path;
    _navigateToFolder(parentPath);
  }

  void _onPathSubmitted(String inputPath) {
    if (Directory(inputPath).existsSync()) {
      _navigateToFolder(inputPath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Directory does not exist')),
      );
    }
  }

  void _openFile(String filePath) async {
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: ${result.message}')),
      );
    }
  }

  IconData _getIcon(FileSystemEntity entity) {
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

  void _handleMenuSelection(FileSystemEntity entity, String value) {
    switch (value) {
      case 'organize':
        if (entity is Directory) {
          _organizeFolder(entity);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Organize is only available for folders.')),
          );
        }
        break;
      case 'move':
        // Implement move action
        break;
      case 'rename':
        // Implement rename action
        break;
      case 'delete':
        // Implement delete action
        break;
    }
  }

  Future<void> _organizeFolder(Directory directory) async {
    List<FileSystemEntity> files = directory.listSync();

    for (var entity in files) {
      if (entity is File) {
        String filePath = entity.path;

        // Generate summary (replace with actual implementation)
        String summary = await _generateSummaryForFile(entity);

        // Save the summary to the database
        await DatabaseHelper.insertSummary(database, filePath, summary);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Organize completed for ${path.basename(directory.path)}')),
    );
  }

  Future<String> _generateSummaryForFile(File file) async {
    // Simulate network call delay
    await Future.delayed(Duration(seconds: 1));

    // Simulate summary generation
    return "Summary for ${path.basename(file.path)}: This is a generated summary of the file.";
  }

  Future<String> _getSummary(FileSystemEntity entity) async {
    if (entity is File) {
      String? summary = await DatabaseHelper.getSummary(database, entity.path);
      if (summary != null) {
        return summary;
      } else {
        return "Summary not available. Please organize the folder to generate summaries.";
      }
    } else if (entity is Directory) {
      int itemCount = Directory(entity.path).listSync().length;
      return "This folder '${path.basename(entity.path)}' contains $itemCount items.";
    } else {
      return "No summary available.";
    }
  }

  String getUserDirectory(String folderName) {
    String homeDir = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '/';
    return path.join(homeDir, folderName);
  }

  // Variables for dragging the divider
  bool isDragging = false;
  double initialDragX = 0.0;
  double initialSummaryWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Explorer'),
        actions: [
          IconButton(
            icon: Icon(isCardView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isCardView = !isCardView;
              });
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left-side navigation
          Container(
            width: 180, // Reduced width
            padding: EdgeInsets.all(10),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NavButton(
                    icon: Icons.home,
                    label: "Home",
                    onTap: () => _navigateToFolder(
                        Platform.environment['USERPROFILE'] ??
                            Platform.environment['HOME'] ??
                            '/'),
                  ),
                  NavButton(
                    icon: Icons.desktop_windows,
                    label: "Desktop",
                    onTap: () => _navigateToFolder(getUserDirectory('Desktop')),
                  ),
                  NavButton(
                    icon: Icons.folder,
                    label: "Documents",
                    onTap: () =>
                        _navigateToFolder(getUserDirectory('Documents')),
                  ),
                  NavButton(
                    icon: Icons.download,
                    label: "Downloads",
                    onTap: () =>
                        _navigateToFolder(getUserDirectory('Downloads')),
                  ),
                  NavButton(
                    icon: Icons.image,
                    label: "Pictures",
                    onTap: () =>
                        _navigateToFolder(getUserDirectory('Pictures')),
                  ),
                  NavButton(
                    icon: Icons.music_note,
                    label: "Music",
                    onTap: () => _navigateToFolder(getUserDirectory('Music')),
                  ),
                  NavButton(
                    icon: Icons.video_library,
                    label: "Videos",
                    onTap: () => _navigateToFolder(getUserDirectory('Videos')),
                  ),
                  NavButton(
                    icon: Icons.storage,
                    label: "C: Drive",
                    onTap: () => _navigateToFolder("C:/"),
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(thickness: 1, width: 1),
          // Middle content area
          Expanded(
            child: Row(
              children: [
                // Main content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address bar
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: _navigateUp,
                            ),
                            Expanded(
                              child: TextField(
                                controller: pathController,
                                onSubmitted: _onPathSubmitted,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isCardView
                            ? GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      showSummary ? 3 : 4, // Adjust columns
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: filesAndFolders.length,
                                itemBuilder: (context, index) {
                                  FileSystemEntity entity =
                                      filesAndFolders[index];
                                  bool isFolder = entity is Directory;
                                  IconData icon = _getIcon(entity);
                                  return GestureDetector(
                                    onTap: () {
                                      // Show summary on single tap
                                      setState(() {
                                        selectedEntity = entity;
                                        showSummary = true;
                                      });
                                    },
                                    onDoubleTap: () {
                                      // Open file or navigate to folder on double tap
                                      if (isFolder) {
                                        _navigateToFolder(entity.path);
                                      } else {
                                        _openFile(entity.path);
                                      }
                                    },
                                    child: FileItemCard(
                                      entity: entity,
                                      name: path.basename(entity.path),
                                      isFolder: isFolder,
                                      isCardView: isCardView,
                                      icon: icon,
                                      onMenuItemSelected: (String value) {
                                        _handleMenuSelection(entity, value);
                                      },
                                    ),
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: filesAndFolders.length,
                                itemBuilder: (context, index) {
                                  FileSystemEntity entity =
                                      filesAndFolders[index];
                                  bool isFolder = entity is Directory;
                                  IconData icon = _getIcon(entity);
                                  return GestureDetector(
                                    onTap: () {
                                      // Show summary on single tap
                                      setState(() {
                                        selectedEntity = entity;
                                        showSummary = true;
                                      });
                                    },
                                    onDoubleTap: () {
                                      // Open file or navigate to folder on double tap
                                      if (isFolder) {
                                        _navigateToFolder(entity.path);
                                      } else {
                                        _openFile(entity.path);
                                      }
                                    },
                                    child: ListTile(
                                      leading: Icon(icon),
                                      title: Text(path.basename(entity.path)),
                                      trailing: PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert),
                                        onSelected: (String value) {
                                          _handleMenuSelection(entity, value);
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                          if (entity is Directory)
                                            const PopupMenuItem<String>(
                                              value: 'organize',
                                              child: Text('Organize'),
                                            ),
                                          const PopupMenuItem<String>(
                                            value: 'move',
                                            child: Text('Move'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'rename',
                                            child: Text('Rename'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                // Draggable divider
                showSummary
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onHorizontalDragStart: (details) {
                          isDragging = true;
                          initialDragX = details.globalPosition.dx;
                          initialSummaryWidth = summaryWidth;
                        },
                        onHorizontalDragUpdate: (details) {
                          if (isDragging) {
                            setState(() {
                              double delta =
                                  details.globalPosition.dx - initialDragX;
                              summaryWidth = (initialSummaryWidth - delta)
                                  .clamp(minSummaryWidth, maxSummaryWidth);
                            });
                          }
                        },
                        onHorizontalDragEnd: (details) {
                          isDragging = false;
                        },
                        child: VerticalDivider(
                          thickness: 4,
                          width: 4,
                          color: Colors.grey[300],
                        ),
                      )
                    : SizedBox.shrink(),
                // Summary panel
                showSummary
                    ? Container(
                        width: summaryWidth,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Close button
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    showSummary = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Summary',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Divider(),
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _getSummary(selectedEntity!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return SingleChildScrollView(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        snapshot.data ?? '',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
