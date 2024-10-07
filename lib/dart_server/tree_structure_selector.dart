import 'package:flutter/material.dart';

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
              Container(
                child: Text(
                  "We have Generated several Tree Structure",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Container(
                child: Text(
                  "Please select one of the following",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                        margin: EdgeInsets.all(20),
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height / 1.5,
                        color: Theme.of(context).colorScheme.outlineVariant),
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
                      color: Colors.red,
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
