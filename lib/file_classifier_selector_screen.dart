import 'package:flutter/material.dart';

class FileClassifierSelectorScreen extends StatefulWidget {
  const FileClassifierSelectorScreen({super.key});

  @override
  State<FileClassifierSelectorScreen> createState() => _FileClassifierSelectorScreenState();
}

class _FileClassifierSelectorScreenState extends State<FileClassifierSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),

          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Card(
              elevation: 10,
              color: Theme.of(context).colorScheme.primary,
              child:Expanded(child:Text("abc")),
            ),
          ),
        ),
      ),
    );
  }
}
