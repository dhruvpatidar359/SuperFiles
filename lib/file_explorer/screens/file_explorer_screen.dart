// file_explorer_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:superfiles/directory_tree_structure/file_classifier_selector_screen.dart';
import 'package:superfiles/file_explorer/services/File%20System%20Services/file_system_service.dart';
import 'package:watcher/watcher.dart';
import '../widgets/file_list_view.dart';
import '../widgets/file_popup_menu.dart';
import '../widgets/file_summary_panel.dart';
import '../services/Databases/database_helper.dart';
import '../widgets/navigation_drawer.dart';

class FileExplorerScreen extends StatefulWidget {
  const FileExplorerScreen({super.key});

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
  bool isAutoOrganizeEnabled = false;

  StreamSubscription? _directoryWatcherSubscription;
  Map<String, StreamSubscription> _fileWatchers = {};

  Future<void> _handleFileAdded(String filePath) async {
    final file = File(filePath);

    // Generate summary
    final summary = await _generateSummaryForFile(file);

    // Save summary to database
    await DatabaseHelper.insertSummary(database, filePath, summary);

    // Refresh the UI
    _loadFilesAndFolders();
  }

  Future<void> _handleFileModified(String filePath) async {
    final file = File(filePath);
    final summary = await _generateSummaryForFile(file);
    // Update summary in database
    await DatabaseHelper.insertSummary(database, filePath, summary);
    // Refresh the UI if necessary
  }

  Future<void> _handleFileRemoved(String filePath) async {
    // Remove summary from database
    await DatabaseHelper.deleteSummary(database, filePath);

    // Refresh the UI

    _loadFilesAndFolders();
  }

  void _handleFileSystemEvent(WatchEvent event) async {
    if (!isAutoOrganizeEnabled) return;

    final filePath = event.path;
    final entityType = await FileSystemEntity.type(filePath);

    switch (event.type) {
      case ChangeType.ADD:
        if (entityType == FileSystemEntityType.file) {
          // Handle file addition
          await _handleFileAdded(filePath);
        }
        break;
      case ChangeType.MODIFY:
        if (entityType == FileSystemEntityType.file) {
          // Handle file modification
          await _handleFileModified(filePath);
        }
        break;
      case ChangeType.REMOVE:
        if (entityType == FileSystemEntityType.file) {
          // Handle file removal
          await _handleFileRemoved(filePath);
        }
        break;
    }
  }

  void _startWatching() {
    _stopWatching(); // Ensure previous watchers are cancelled

    // Start watching the current directory
    final directoryWatcher = DirectoryWatcher(currentPath);
    print("we are watching to the $currentPath");
    _directoryWatcherSubscription = directoryWatcher.events.listen((event) {
      _handleFileSystemEvent(event);
    });
  }

  void _stopWatching() {
    _directoryWatcherSubscription?.cancel();
    _directoryWatcherSubscription = null;

    // Cancel all file watchers
    for (var subscription in _fileWatchers.values) {
      subscription.cancel();
    }
    _fileWatchers.clear();
  }

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

      if (isAutoOrganizeEnabled) {
        _startWatching();
      }
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
        const SnackBar(content: Text('Directory does not exist')),
      );
    }
  }




  Future<void> _handleMenuSelection(FileSystemEntity entity, String value) async {
    switch (value) {
      case 'organize':
        if (entity is Directory) {
          _organizeFolder(entity).then(
                (value) {
              _loadFilesAndFolders();
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Organize is only available for folders.')),
          );
        }
        break;
      case 'move':
        await FileSystemService.handleMove(context, entity).then(
              (value) {
            _loadFilesAndFolders();
          },
        );// Call move handler// Call move handler
        break;
      case 'rename':
        await FileSystemService.handleRename(context, entity).then(
              (value) {
            _loadFilesAndFolders();
          },
        );// Call move handler
        break;
      case 'delete':
        await FileSystemService.handleDelete(context, entity).then(
              (value) {
            _loadFilesAndFolders();
          },
        );// Call move handler// Call delete handler
        break;
    }
  }

  Future<void> _organizeFolder(Directory directory) async {
    String directoryPath = directory.path;
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            FileClassifierSelectorScreen(directoryPath: directoryPath)));
  }

  Future<String> _generateSummaryForFile(File file) async {
    // Simulate network call delay
    await Future.delayed(Duration(seconds: 1));

    // Simulate summary generation
    return "Summary for ${path.basename(file.path)}: This is a generated summary of the file.";
  }



  void showPopupMenu(BuildContext context, Offset position, FileSystemEntity entity, bool isFolder) {
    FilePopupMenu.show(context, position, (value) {
      _handleMenuSelection(entity, value);
    });
  }


  // Variables for dragging the divider
  bool isDragging = false;
  double initialDragX = 0.0;
  double initialSummaryWidth = 0.0;

  // Helper function to check if a path is selected
  bool _isSelectedPath(String pathToCheck) {
    // On Windows, paths are case-insensitive
    if (Platform.isWindows) {
      return currentPath.toLowerCase() == pathToCheck.toLowerCase();
    } else {
      return currentPath == pathToCheck;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isCardView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isCardView = !isCardView;
              });
            },
          ),
          Row(
            children: [
              const Text('Auto-Organize'),
              Switch(
                value: isAutoOrganizeEnabled,
                onChanged: (value) {
                  setState(() {
                    isAutoOrganizeEnabled = value;
                    if (isAutoOrganizeEnabled) {
                      _startWatching();
                    } else {
                      _stopWatching();
                    }
                  });
                },
              ),
            ],
          ),
        ],
        title: Text('Super Files'),
      ),
      body: Row(
        children: [
          // Left-side navigation
          CustomNavigationDrawer(
            navigateToFolder: (path) {
              _navigateToFolder(path);
            },
            isSelectedPath: (path) {
              return _isSelectedPath(path);
            },
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
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back,
                                    color: Colors.black), // Styled icon
                                onPressed: _navigateUp,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: pathController,
                                  onSubmitted: _onPathSubmitted,
                                  decoration: InputDecoration(
                                    filled: true,

                                    // TextField background color
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Rounded TextField
                                      borderSide: BorderSide.none, // No border
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 10), // Inner padding
                                    hintText: 'Enter path...', // Hint text
                                    hintStyle: TextStyle(), // Hint text style
                                  ),
                                  style: TextStyle(
                                      fontSize: 16), // Font size for text
                                ),
                              ),
                              SizedBox(width: 8), // Spacer
                              // Optional search icon
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: FileListView(
                          filesAndFolders: filesAndFolders,
                          isCardView: isCardView,
                          showSummary: showSummary,
                          onEntityTap: (entity) {
                            setState(() {
                              selectedEntity = entity;
                              showSummary = true;
                            });
                          },
                          onEntityDoubleTap: (entity) {
                            if (entity is Directory) {
                              _navigateToFolder(entity.path);
                            } else {
                              FileSystemService.openFile(entity.path, context);
                            }
                          },
                          onSecondaryTapDown: (details, entity, isFolder) {
                            showPopupMenu(context, details.globalPosition, entity, isFolder);
                          },
                          onMenuItemSelected: (value, entity) {
                            _handleMenuSelection(entity, value);
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
                              child: FileSummaryPanel(
                                selectedEntity: selectedEntity!, database: database,
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


