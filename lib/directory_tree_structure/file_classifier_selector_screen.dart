import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:superfiles/directory_tree_structure/tree_structure.dart';
import 'package:superfiles/directory_tree_structure/tree_structure_selector.dart';
import 'package:superfiles/restricted_directories/check_development_directories.dart';
import 'package:superfiles/restricted_directories/check_software_directories.dart';

import '../dart_server/loader.dart';
import '../dart_server/summarizer.dart';
import '../dart_server/tree_generator.dart';

import '../restricted_directories/check_system_directories.dart';

class FileClassifierSelectorScreen extends StatefulWidget {
  final String directoryPath;
  const FileClassifierSelectorScreen({super.key, required this.directoryPath});

  @override
  State<FileClassifierSelectorScreen> createState() =>
      _FileClassifierSelectorScreenState();
}

class _FileClassifierSelectorScreenState
    extends State<FileClassifierSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Theme.of(context).colorScheme.primary,
          ),
          height: double.infinity,
          width: double.infinity,
          child: Center(
            child: Card(
              elevation: 10,
              color: Theme.of(context).colorScheme.onPrimary,
              child: AddDocumentForm(directoryPath: widget.directoryPath),
            ),
          ),
        ),
      ),
    );
  }
}

class AddDocumentForm extends StatefulWidget {
  final String directoryPath;
  const AddDocumentForm({super.key, required this.directoryPath});
  @override
  _AddDocumentFormState createState() => _AddDocumentFormState();
}

class _AddDocumentFormState extends State<AddDocumentForm> {
  final _folderPathController = TextEditingController();
  List<TextEditingController> fieldControllers = [];
  String? selectedFolderPath;
  String? combinedSummariesJson;
  String? treeGenerator;
  bool dataSent = false;

  @override
  void initState() {
    super.initState();
    _folderPathController.text = widget.directoryPath;
  }

  final summarizer = Summarizer(GenerativeModel(
    model: 'gemini-1.5-flash-latest', // The model you are using
    apiKey:
        'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw', // Replace with your actual Google Generative AI API key
  ));

  late final loader = Loader(summarizer); // Initialize loader with summarizer

  late final tree = TreeGenerator(GenerativeModel(
    model: 'gemini-1.5-flash-latest', // The model you are using
    apiKey:
        'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw', // Replace with your actual Google Generative AI API key
  ));

  Future<void> _pickFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        setState(() {
          _folderPathController.text = selectedDirectory;
        });
      }
    } catch (e) {
      // Handle any exceptions that might occur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking folder: $e")),
      );
    }
  }

  Future<void> summarizeAllFilesInDirectory(String selectedDirectory) async {
    try {
      // Load and summarize document content from the selected folder
      combinedSummariesJson =
          await loader.loadAndSummarizeDocuments(selectedDirectory);
      treeGenerator = await tree.createFileTree(combinedSummariesJson!);

      print("tree Generator");
      print(treeGenerator);
    } catch (e) {
      // Handle exceptions that occur during summarization or tree generation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during summarization: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (dataSent)
          Center(
            child: CircularProgressIndicator(),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Parent Path" label (this can be hardcoded or dynamically displayed)
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Parent Path\n${widget.directoryPath}",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Document ID Input
            Container(
              margin: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _folderPathController,
                      decoration: InputDecoration(
                        labelText: 'Folder Path',
                        border: OutlineInputBorder(),
                        hintText: 'Enter Folder Path',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // Square border
                      ),
                    ),
                    onPressed: _pickFolder,
                    child: Text("Pick Folder"),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),

            // Dynamic list of field entries
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                child: ListView.builder(
                  itemCount: fieldControllers.length,
                  itemBuilder: (context, index) {
                    return _buildFieldRow(index);
                  },
                ),
              ),
            ),

            // Add Field Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    fieldControllers.add(TextEditingController());
                  });
                },
                icon: Icon(Icons.add_circle),
                label: Text(
                  'Add field',
                ),
              ),
            ),

            SizedBox(height: 20),

            // Cancel and Save buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 30, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      // Handle cancel logic
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // Square border
                      ),
                    ),
                    onPressed: () async {
                      if(_folderPathController.text != "%" &&
                          _folderPathController.text.isNotEmpty
                          && !isSubFolderOrSystemFolder(_folderPathController.text)
                          && !isSoftwareInstallFolder(_folderPathController.text)
                          && !isAppDevelopmentFolder(_folderPathController.text)
                          && !isWebDevelopmentFolder(_folderPathController.text)
                      ){

                        if (_folderPathController.text != "%" &&
                            _folderPathController.text.isNotEmpty) {

                          setState(() {
                            dataSent = true; // Show progress indicator
                          });

                          await summarizeAllFilesInDirectory(
                              _folderPathController.text);

                          setState(() {
                            dataSent = false; // Hide progress indicator
                          });

                          // Navigate to the next screen if summary is successful
                          if (treeGenerator != null) {
                            // combinedSummariesJson = combinedSummariesJson?.replaceAll("```json", "").replaceAll("```", "replace");
                            // print("combinerSummaries after replacement");
                            // print(treeGenerator);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => TreeStructureSelector(
                                  dataList: treeGenerator!,
                                  srcPath: widget.directoryPath,
                                )));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Summarization failed.")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Please enter or select a valid folder path.")),
                          );
                        }
                      }
                      else{
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "System Files and Software Files cannot be Manipulated ")),
                        );
                      }
                    },
                    child: Text("Save"),
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  // Helper to build a row for each field
  Widget _buildFieldRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Field name input
          Expanded(
            child: TextField(
              controller: fieldControllers[index],
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Field',
              ),
            ),
          ),
          SizedBox(width: 10),

          // Remove field button
          IconButton(
            icon: Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () {
              setState(() {
                fieldControllers.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }
}
