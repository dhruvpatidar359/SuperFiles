import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'dart_server/loader.dart';
import 'dart_server/summarizer.dart';
import 'dart_server/tree_generator.dart';

class TreeStructureSelector extends StatefulWidget {
  const TreeStructureSelector({super.key});

  @override
  State<TreeStructureSelector> createState() => _TreeStructureSelectorState();
}

class _TreeStructureSelectorState extends State<TreeStructureSelector> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(50),
        child: Card(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns widgets to the sides
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Centers the Column in the middle
                        children: [
                          Text("Centered Content"),
                          SizedBox(height: 10),
                          Text("More Content Here"),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        Navigator.pop(context);
                        // Cancel button action here
                      },
                    ),
                  ),
                ],
              ),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.all(20),
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height / 1.5,
                        color: Theme.of(context).colorScheme.secondaryFixed),
                  ),
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.all(20),
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height / 1.5,
                        color: Theme.of(context).colorScheme.secondaryFixed),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height / 1.5,
                      color: Theme.of(context).colorScheme.secondaryFixed,
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
