import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:sqflite_common/sqlite_api.dart';


import '../file_explorer/services/Databases/database_helper.dart';
import 'node.dart';

class TreeStructure extends StatefulWidget {
  final List<dynamic> folderStructureData;
  final String srcPath;
  final VoidCallback onCompletion;
  const TreeStructure(
      {super.key,
      required this.folderStructureData,
      required this.srcPath,
      required this.onCompletion});

  @override
  _TreeStructureState createState() => _TreeStructureState();
}

class _TreeStructureState extends State<TreeStructure> {
  late final TreeController<Node> treeController;
  late Node root;
  Node? hoveredNode;
  Offset? hoverPosition;

  @override
  void initState() {
    super.initState();
    root = Node(id: -1, name: "Root", summary: "");
    populateTreeFromJson(widget.folderStructureData);

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
      parentProvider: (Node node) => node.parent,
    );
  }

  Future<void> populateTreeFromJson(dynamic jsonData) async {
    if (jsonData.isEmpty) {
      jsonData = '''{
      "files": [
        {"dst_path": "folder1/subfolder1", "suggested_file_name": "file1.txt", "summary": "Summary of file1"},
        {"dst_path": "folder1/subfolder2", "suggested_file_name": "file2.txt", "summary": "Summary of file2"},
        {"dst_path": "folder2", "suggested_file_name": "file3.txt", "summary": "Summary of file3"}
      ]
    }''';
      Map<String, dynamic> processedJsonData = jsonDecode(jsonData);
      List<dynamic> files = processedJsonData['files'];
    }

    List<dynamic> files = jsonData;

    for (var file in files) {
      String path = file['dst_path'];
      String suggestedFileName = file['suggested_file_name'];
      String summaryOfFile = file['summary'];

      List<String> segments = path.split('/');
      Node currentNode = root;

      for (String segment in segments) {
        Node? child = currentNode.children.firstWhere(
          (child) => child.name == segment,
          orElse: () => Node(id: segment.hashCode, name: segment, summary: ""),
        );

        if (!currentNode.children.contains(child)) {
          currentNode.insertChild(currentNode.children.length, child);
        }

        currentNode = child;
      }

      if (!currentNode.children
          .any((child) => child.name == suggestedFileName)) {
        Node fileNode = Node(
          id: suggestedFileName.hashCode,
          name: suggestedFileName,
          summary: summaryOfFile,
        );
        currentNode.insertChild(currentNode.children.length, fileNode);
      }
    }

    setState(() {});
  }

  void saveSummary(String fileName, String filePath, String summary, String suggestedFileName) async {
    String currentTime = DateTime.now().toString();

    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    await DatabaseHelper.insertSummary(databaseHelper,fileName, filePath, summary, suggestedFileName, currentTime);
    print("Summary saved for $filePath");
  }


  //For debugging purposes
  Future<void> getSummary(
    String filePath,
  ) async {
    final db = DatabaseHelper.instance;
    Database databaseHelper = await db.getDatabase();
    String? summary = await DatabaseHelper.getSummary(databaseHelper, filePath);
    if (summary != null) {
      print('Summary for $filePath: $summary');
    } else {
      print('No summary found for $filePath');
    }
  }

  void copyTreeStructureToFileSystem(dynamic jsonData) async {
    // Map<String, dynamic> processedJsonData = jsonDecode(jsonData);

    // Access the "files" field which is a List
    // List<dynamic> files = processedJsonData['files'];
    List<dynamic> files = jsonData;

    // Base directory (replace this with your actual path in string format)
    String basePath = widget.srcPath; // Replace with actual path

    // Iterate through the file entries and move files
    for (var fileEntry in files) {
      // Convert relative src_path and dst_path to full paths
      String srcPath = fileEntry['src_path'];
      String dstPath = fileEntry['dst_path'];
      String suggestedFileName = fileEntry["suggested_file_name"];
      String summary = fileEntry["summary"];

      // Combine the base path with src_path and dst_path
      String absoluteSrcPath = '$basePath/$srcPath';
      String absoluteDstPath = '$basePath/$dstPath/$suggestedFileName'.replaceAll("//", "/");

      print("absoluteDstPath $absoluteDstPath");



      // Create the destination directory if it doesn't exist
      Directory dstDir = Directory(absoluteDstPath).parent;
      if (!await dstDir.exists()) {
        await dstDir.create(recursive: true);
      }

      // Move the file from srcPath to dstPath
      File srcFile = File(absoluteSrcPath);
      if (await srcFile.exists()) {
        await srcFile.rename(absoluteDstPath);
        print('Moved: $absoluteSrcPath to $absoluteDstPath');
      } else {
        print('Source file not found: $absoluteSrcPath');
      }


      // Storing the summary in the database.

      saveSummary(srcPath, absoluteDstPath, summary, suggestedFileName);

      getSummary(absoluteDstPath);
    }




  }

  Widget _buildTreeView() {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Stack(
        children: [
          AnimatedTreeView<Node>(
            treeController: treeController,
            nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
              return TreeDragTarget<Node>(
                node: entry.node,
                onNodeAccepted: (details) {
                  if (!entry.node.isLeaf ||
                      (entry.node.isLeaf && !entry.node.name.contains('.'))) {
                    // Accept drop only if the target is a folder (not a file)
                    setState(() {
                      _moveNode(details.draggedNode, entry.node);
                      treeController.rebuild();
                    });
                  }
                },
                builder: (BuildContext context,
                    TreeDragAndDropDetails<Node>? details) {
                  return TreeDraggable<Node>(
                    node: entry.node,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.blue.withOpacity(0.5),
                        child: Text(entry.node.name,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _buildTreeNodeTile(entry),
                    ),
                    child: _buildTreeNodeTile(entry),
                  );
                },
              );
            },
          ),
          if (hoveredNode != null &&
              hoveredNode!.isLeaf &&
              hoveredNode!.name.contains('.') &&
              hoverPosition != null)
            Positioned(
              left: hoverPosition!.dx + 10,
              top: hoverPosition!.dy + 10,
              child: Material(
                elevation: 4.0,
                color: Colors.grey[800],
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      hoveredNode!.summary,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTreeNodeTile(TreeEntry<Node> entry) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hoveredNode = entry.node;
          hoverPosition = event.position;
        });
      },
      onHover: (event) {
        setState(() {
          hoverPosition = event.localPosition;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredNode = null;
          hoverPosition = null;
        });
      },
      child: InkWell(
        onTap: () {
          setState(() {
            if (entry.hasChildren) {
              treeController.toggleExpansion(entry.node);
            }
          });
        },
        child: TreeIndentation(
          entry: entry,
          child: Container(
            color: hoveredNode == entry.node
                ? Colors.grey[700]
                : Colors.transparent,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (entry.node.isLeaf && entry.node.name.contains('.'))
                  Icon(
                    Icons.file_copy,
                    color: Colors.amber,
                  )
                else if (entry.isExpanded)
                  Icon(
                    Icons.folder_open,
                    color: Colors.amber,
                  )
                else if (!entry.isExpanded)
                  Icon(
                    Icons.folder,
                    color: Colors.amber,
                  ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.node.name,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _moveNode(Node nodeToMove, Node newParent) {
    if (nodeToMove.parent != null) {
      List<Node> updatedChildren = List<Node>.from(nodeToMove.parent!.children);
      updatedChildren.remove(nodeToMove);
      nodeToMove.parent!.children = updatedChildren;
    }

    newParent.insertChild(newParent.children.length, nodeToMove);
    nodeToMove.parent = newParent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          child: TextButton(
            onPressed: () {
              // Add button action here
              copyTreeStructureToFileSystem(widget.folderStructureData);
              // widget.onCompletion(); // Uncomment in future version, commented for debugging
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      "The Chosen Directory Structure is successfully implemented.")));
            },
            child: const Text(
              'Select this Structure',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
      body: _buildTreeView(),
    );
  }
}
