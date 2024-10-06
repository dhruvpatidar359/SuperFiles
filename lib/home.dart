import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart'; // Add this import

class FileExplorerScreen extends StatefulWidget {
  @override
  _FileExplorerScreenState createState() => _FileExplorerScreenState();
}

class _FileExplorerScreenState extends State<FileExplorerScreen> {
  bool isCardView = true;
  String currentPath = Directory.current.path;
  List<FileSystemEntity> filesAndFolders = [];
  TextEditingController pathController = TextEditingController();
  FileSystemEntity? selectedEntity; // For tracking selected file/folder
  bool showSummary =
      false; // For controlling the visibility of the summary panel
  double summaryWidth = 250; // Initial width of the summary panel
  double minSummaryWidth = 150; // Minimum width of the summary panel
  double maxSummaryWidth = 400; // Maximum width of the summary panel

  @override
  void initState() {
    super.initState();
    pathController.text = currentPath;
    _loadFilesAndFolders();
  }

  void _loadFilesAndFolders() {
    try {
      Directory dir = Directory(currentPath);
      List<FileSystemEntity> entities = dir.listSync();
      setState(() {
        filesAndFolders = entities;
        pathController.text = currentPath;
        selectedEntity = null; // Reset selection on folder change
        showSummary =
            false; // Hide summary panel when navigating to a new folder
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

  void _openFile(String filePath) {
    OpenFile.open(filePath);
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
    // Get the summaries directory
    Directory summariesDir = await _getSummariesDirectory();

    // List all files in the directory
    List<FileSystemEntity> files = directory.listSync();

    for (var entity in files) {
      if (entity is File) {
        String fileName = path.basename(entity.path);
        String summaryFilePath =
            path.join(summariesDir.path, '$fileName.summary');

        // Simulate summary generation
        String summary = await _generateSummaryForFile(entity);

        // Save the summary to a file
        File summaryFile = File(summaryFilePath);
        await summaryFile.writeAsString(summary);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Organize completed for ${path.basename(directory.path)}')),
    );
  }

  Future<Directory> _getSummariesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final summariesDir = Directory(path.join(appDocDir.path, 'summaries'));

    if (!await summariesDir.exists()) {
      await summariesDir.create(recursive: true);
    }

    return summariesDir;
  }

  Future<String> _generateSummaryForFile(File file) async {
    // Simulate network call delay
    await Future.delayed(Duration(seconds: 1));

    // Simulate summary generation
    return "Summary for ${path.basename(file.path)}: This is a generated summary of the file.";
  }

  Future<String> _getSummary(FileSystemEntity entity) async {
    if (entity is File) {
      Directory summariesDir = await _getSummariesDirectory();
      String fileName = path.basename(entity.path);
      String summaryFilePath =
          path.join(summariesDir.path, '$fileName.summary');

      File summaryFile = File(summaryFilePath);

      if (await summaryFile.exists()) {
        String summary = await summaryFile.readAsString();
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
                  flex: showSummary ? 1 : 1, // Adjusted flex
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

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NavButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class FileItemCard extends StatelessWidget {
  final String name;
  final bool isFolder;
  final bool isCardView;
  final IconData icon;
  final FileSystemEntity entity;
  final Function(String) onMenuItemSelected;

  const FileItemCard({
    Key? key,
    required this.name,
    required this.isFolder,
    required this.isCardView,
    required this.icon,
    required this.entity,
    required this.onMenuItemSelected,
  }) : super(key: key);

  bool _isImageFile(String extension) {
    return ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    final fileExtension = path.extension(entity.path).toLowerCase();
    Widget content;

    if (!isFolder && _isImageFile(fileExtension)) {
      // Display image thumbnail
      content = Image.file(
        File(entity.path),
        fit: BoxFit.cover,
      );
    } else {
      // Display icon centered
      content = Icon(icon, size: 40);
    }

    if (isCardView) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(5), // Reduced margin
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(child: content),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0), // Reduced padding
                  child: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (String value) {
                  onMenuItemSelected(value);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
          ],
        ),
      );
    } else {
      return ListTile(
        leading: content,
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (String value) {
            onMenuItemSelected(value);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
      );
    }
  }
}
