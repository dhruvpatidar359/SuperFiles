import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../directory_tree_structure/node.dart';


class TreeStructure extends StatefulWidget {
  // final String dataList;
  final List<dynamic> folderStructureData;
  const TreeStructure({super.key, required this.folderStructureData});

  @override
  _TreeStructureState createState() => _TreeStructureState();
}

class _TreeStructureState extends State<TreeStructure> {
  late final TreeController<Node> treeController;
  late Node root;
  Node? hoveredNode;

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

  void closeThisScreen(){

    Navigator.pop(context);
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


    // Map<String, dynamic> processedJsonData = jsonDecode(jsonData);
    // List<dynamic> files = processedJsonData['files'];



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

      if (!currentNode.children.any((child) => child.name == suggestedFileName)) {
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

  Widget _buildTreeView() {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: AnimatedTreeView<Node>(
        treeController: treeController,
        nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
          return TreeDragTarget<Node>(
            node: entry.node,
            onNodeAccepted: (details) {
              if (!entry.node.isLeaf || (entry.node.isLeaf && !entry.node.name.contains('.'))) {
                // Accept drop only if the target is a folder (not a file)
                setState(() {
                  _moveNode(details.draggedNode, entry.node);
                  treeController.rebuild();
                });
              }
            },
            builder: (BuildContext context, TreeDragAndDropDetails<Node>? details) {
              return TreeDraggable<Node>(
                node: entry.node,
                feedback: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.blue.withOpacity(0.5),
                    child: Text(entry.node.name, style: TextStyle(color: Colors.white)),
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
    );
  }

  Widget _buildTreeNodeTile(TreeEntry<Node> entry) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredNode = entry.node;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredNode = null;
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
            color: hoveredNode == entry.node ? Colors.grey[700] : Colors.transparent,
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
      body: _buildTreeView(),
    );
  }
}