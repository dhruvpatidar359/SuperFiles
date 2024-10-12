import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:superfiles/directory_tree_structure/tree_structure.dart';

import '../dart_server/loader.dart';
import '../dart_server/summarizer.dart';
import '../dart_server/tree_generator.dart';

class TreeStructureSelector extends StatefulWidget {
  final String dataList;
  final String srcPath;
  const TreeStructureSelector({super.key, required this.dataList, required this.srcPath});

  @override
  State<TreeStructureSelector> createState() => _TreeStructureSelectorState();
}

class _TreeStructureSelectorState extends State<TreeStructureSelector> {
  late Map<String, dynamic> processedJsonData;
  late List<dynamic> dirStructure1;
  late List<dynamic> dirStructure2;
  late List<dynamic> dirStructure3;

  void setup(String jsonData) {
    processedJsonData = jsonDecode(jsonData);
    dirStructure1 = processedJsonData['files1'];
    dirStructure2 = processedJsonData['files2'];
    dirStructure3 = processedJsonData['files3'];
  }

  @override
  void initState() {
    super.initState();
    setup(widget.dataList);
  }


  void closeThisScreen(){
    Navigator.pop(context);
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Please choose one directory structure..",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 24
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "You can drag and drop the folder to change their position",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(20),
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height / 1.5,
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: TreeStructure(
                            folderStructureData: dirStructure1,
                            srcPath: widget.srcPath,
                            onCompletion: closeThisScreen,
                          ),
                        ),

                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(20),
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height / 1.5,
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: TreeStructure(
                            folderStructureData: dirStructure2,
                            srcPath: widget.srcPath,
                            onCompletion: closeThisScreen,
                          ),
                        ),

                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.all(20),
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height / 1.5,
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: TreeStructure(
                            folderStructureData: dirStructure3,
                            srcPath: widget.srcPath,
                            onCompletion: closeThisScreen,
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
