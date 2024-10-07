import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
// import 'package:admin/screens/local_files/node.dart'; // Import your updated Node class here

import 'node.dart';

class FileExplorerUI extends StatefulWidget {
  final String source_path;
  final String dataList;
  const FileExplorerUI(
      {super.key, required this.dataList, required this.source_path});

  @override
  _FileExplorerUIState createState() => _FileExplorerUIState();
}

class _FileExplorerUIState extends State<FileExplorerUI> {
  late final TreeController<Node> treeController;
  late Node root;
  Node? selectedNode;
  double _panelWidth = 300;
  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    root = Node(id: -1, name: "Root", summary: "");
    populateTreeFromJson(widget.dataList);

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
      parentProvider: (Node node) => node.parent,
    );
  }

  // Updated populateTreeFromJson method
  Future<void> populateTreeFromJson(dynamic jsonData) async {
    if (jsonData.isEmpty) {
      jsonData = '''{
      "files": [
        {"dst_path": "folder1/subfolder1", "suggested_file_name": "file1.txt", "summary": "Summary of file1"},
        {"dst_path": "folder1/subfolder2", "suggested_file_name": "file2.txt", "summary": "Summary of file2"},
        {"dst_path": "folder2", "suggested_file_name": "file3.txt", "summary": "Summary of file3"}
      ]
    }''';
    }

    print("json String before converting");
    print(jsonData);

    Map<String, dynamic> processedJsonData = jsonDecode(jsonData);

    // Access the "files" field which is a List
    List<dynamic> files = processedJsonData['files'];

    for (var file in files) {
      String path = file['dst_path'];
      String suggestedFileName = file['suggested_file_name'];
      String summaryOfFile = file['summary'];

      // Split path to create a tree structure
      List<String> segments = path.split('/');

      // Create nodes for the path
      Node currentNode = root;

      // Traverse the segments to add folder nodes
      for (String segment in segments) {
        // Check if the current segment already exists in the children of the current node
        Node? child = currentNode.children.firstWhere(
              (child) => child.name == segment,
          orElse: () => Node(id: segment.hashCode, name: segment, summary: ""),
        );

        // If the segment is a new node, add it to the tree
        if (!currentNode.children.contains(child)) {
          currentNode.insertChild(currentNode.children.length, child);
        }

        // Move the current node to the child node
        currentNode = child;
      }

      // Add the suggested file node at the appropriate level as a leaf node
      // Make sure it does not already exist as a directory node
      if (!currentNode.children.any((child) => child.name == suggestedFileName)) {
        Node fileNode = Node(
          id: suggestedFileName.hashCode,
          name: suggestedFileName,
          summary: summaryOfFile,
        );
        currentNode.insertChild(currentNode.children.length, fileNode);
      }
    }

    // Update the TreeController after populating the tree
    setState(() {
      treeController.rebuild();
    });
  }


  void updateJsonAfterNodeMove() {
    // Method to generate the JSON string from the current tree structure
    Map<String, dynamic> generateJsonFromTree(Node currentNode) {
      List<Map<String, dynamic>> files = [];

      void traverse(Node node, String currentPath) {
        for (var child in node.children) {
          String newPath =
              currentPath.isEmpty ? child.name : '$currentPath/${child.name}';
          if (child.isLeaf) {
            files.add({
              'dst_path': newPath,
              'suggested_file_name': child.name,
              'summary': child.summary,
              'src_path': '' // Update with source path if needed
            });
          } else {
            traverse(child, newPath);
          }
        }
      }

      traverse(currentNode, '');
      return {'files': files};
    }

    Map<String, dynamic> updatedJson = generateJsonFromTree(root);
    String updatedJsonString = jsonEncode(updatedJson);
    print(updatedJsonString); // This will print the updated JSON string
  }

  void copyTreeStructureToFileSystem(dynamic jsonData) async {
    Map<String, dynamic> processedJsonData = jsonDecode(jsonData);

    // Access the "files" field which is a List
    List<dynamic> files = processedJsonData['files'];

    // Base directory (replace this with your actual path in string format)
    String basePath = widget.source_path; // Replace with actual path

    // Iterate through the file entries and move files
    for (var fileEntry in files) {
      // Convert relative src_path and dst_path to full paths
      String srcPath = fileEntry['src_path'];
      String dstPath = fileEntry['dst_path'];

      // Combine the base path with src_path and dst_path
      String absoluteSrcPath = '$basePath/$srcPath';
      String absoluteDstPath = '$basePath/$dstPath';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TreeViewer'),
        backgroundColor: Colors.grey[800],
        actions: [
          TextButton(
              onPressed: () {},
              child: Text('Directory View',
                  style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () {},
              child:
                  Text('Options Menu', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              if (selectedNode != null) {
                setState(() {
                  _showSummary = !_showSummary;
                });
              }
            },
            child: Text('Summary', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              copyTreeStructureToFileSystem(widget.dataList);
            },
            child: Text('Create Directory Structure',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: _panelWidth,
            child: _buildTreeView(),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                setState(() {
                  _panelWidth += details.delta.dx;
                  _panelWidth = _panelWidth.clamp(
                      100.0, MediaQuery.of(context).size.width - 100);
                });
              },
              child: Container(
                width: 8,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: _buildFileDetailsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView() {
    return Container(
      color: Colors.grey[900],
      child: AnimatedTreeView<Node>(
        treeController: treeController,
        nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
          return _buildDraggableNode(entry);
        },
      ),
    );
  }

  Widget _buildDraggableNode(TreeEntry<Node> entry) {
    return DragTarget<Node>(
      builder: (context, candidateData, rejectedData) {
        return Draggable<Node>(
          data: entry.node,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.blue.withOpacity(0.5),
              child:
                  Text(entry.node.name, style: TextStyle(color: Colors.white)),
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedNode = entry.node;
                if (entry.hasChildren) {
                  treeController.toggleExpansion(entry.node);
                }
              });
            },
            child: TreeIndentation(
              entry: entry,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (entry.node.isLeaf)
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
      },
      onWillAccept: (incomingNode) {
        return entry.node.isLeaf == false &&
            incomingNode != null &&
            !_isDescendant(entry.node, incomingNode);
      },
      onAccept: (incomingNode) {
        setState(() {
          _moveNode(incomingNode, entry.node);
          treeController.rebuild();
          updateJsonAfterNodeMove();
        });
      },
    );
  }

  bool _isDescendant(Node parent, Node child) {
    if (parent == child) return true;
    for (var node in parent.children) {
      if (_isDescendant(node, child)) return true;
    }
    return false;
  }

  void _moveNode(Node nodeToMove, Node newParent) {
    // Remove the node from its current parent
    if (nodeToMove.parent != null) {
      List<Node> updatedChildren = List<Node>.from(nodeToMove.parent!.children);
      updatedChildren.remove(nodeToMove);
      nodeToMove.parent!.children = updatedChildren;
    }

    // Add the node to its new parent
    newParent.insertChild(newParent.children.length, nodeToMove);
    nodeToMove.parent = newParent;
  }

  Widget _buildFileDetailsPanel() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.all(16),
      child: selectedNode != null
          ? (selectedNode!.isLeaf
              ? FileDetailsPanel(
                  node: selectedNode!,
                  onCreateSummary: () {
                    setState(() {
                      _showSummary = true;
                    });
                  })
              : FolderDetailsPanel(node: selectedNode!))
          : Center(
              child: Text('Select a file or folder to view details',
                  style: TextStyle(color: Colors.white))),
    );
  }
}

class FileDetailsPanel extends StatelessWidget {
  final Node node;
  final VoidCallback onCreateSummary;

  const FileDetailsPanel(
      {Key? key, required this.node, required this.onCreateSummary})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File Details',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.name,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 8),
                Text('Created on: July 10, 2023',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 8),
                Text('Size: 1.5 MB',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 8),
                Text("Summary: " + node.summary,
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Open'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FolderDetailsPanel extends StatelessWidget {
  final Node node;

  const FolderDetailsPanel({Key? key, required this.node}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Folder Details',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.name,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 8),
                Text('Created on: July 10, 2023',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 8),
                Text('Number of items: ${node.children.length}',
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Open'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Add File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
