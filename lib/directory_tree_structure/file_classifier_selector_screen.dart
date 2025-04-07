import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:superfiles/dart_server/tree_generator_user_defined.dart';
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
  final _customPromptController = TextEditingController();

  List<TextEditingController> fieldControllers = [];
  String? combinedSummariesJson;
  String? treeGenerator;
  bool dataSent = false;

  @override
  void initState() {
    super.initState();
    _folderPathController.text = widget.directoryPath;
  }

  final summarizer = Summarizer(GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw',
  ));

  late final loader = Loader(summarizer);

  late final tree = TreeGenerator(GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw',
  ));

  late final treeUserDefined = TreeGeneratorUserDefined(GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: 'AIzaSyDqXskrI3gT1axkZGkYRCBW8tBENIjlpNw',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking folder: $e")),
      );
    }
  }

  Future<void> summarizeAllFilesInDirectory(String selectedDirectory) async {
    try {
      combinedSummariesJson =
          await loader.loadAndSummarizeDocuments(selectedDirectory);

      if (fieldControllers.isNotEmpty ||
          _customPromptController.text.isNotEmpty) {
        // Get folder names from field controllers
        String folderNames =
            convertFieldControllersListToString(fieldControllers);

        // Get custom prompt from controller
        String customPrompt = _customPromptController.text;

        // Pass both folder names and custom prompt separately
        treeGenerator = await treeUserDefined.createFileTree(
            combinedSummariesJson!, folderNames,
            customPrompt: customPrompt);
      } else {
        // If no custom folders or prompt, use the standard tree generator
        treeGenerator = await tree.createFileTree(combinedSummariesJson!);
      }

      print("Tree Generated:\n$treeGenerator");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during summarization: $e")),
      );
    }
  }

  String convertFieldControllersListToString(
      List<TextEditingController> fieldControllers) {
    String result = "";
    int it = 0;
    for (TextEditingController textEditingController in fieldControllers) {
      if (textEditingController.text.isNotEmpty) {
        result +=
            "- Folder ${it++}: ${textEditingController.text.toString()} \n";
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (dataSent)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Parent Path\n${widget.directoryPath}",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Folder Path Input Row
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _folderPathController,
                      decoration: const InputDecoration(
                        labelText: 'Folder Path',
                        border: OutlineInputBorder(),
                        hintText: 'Enter Folder Path',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: _pickFolder,
                    child: const Text("Pick Folder"),
                  )
                ],
              ),
            ),

            // ✨ Custom Prompt Input Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _customPromptController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Extra Prompt for Sorting',
                    hintText: 'e.g., Group files by deadlines or usage...',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Dynamic field list
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
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
                icon: const Icon(Icons.add_circle),
                label: const Text('Add field'),
              ),
            ),

            const SizedBox(height: 20),

            // Cancel and Save Buttons
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
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () async {
                      final folderPath = _folderPathController.text;
                      if (folderPath != "%" &&
                          folderPath.isNotEmpty &&
                          !isSubFolderOrSystemFolder(folderPath) &&
                          !isSoftwareInstallFolder(folderPath) &&
                          !isAppDevelopmentFolder(folderPath) &&
                          !isWebDevelopmentFolder(folderPath)) {
                        setState(() {
                          dataSent = true;
                        });

                        await summarizeAllFilesInDirectory(folderPath);

                        setState(() {
                          dataSent = false;
                        });

                        if (treeGenerator != null) {
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
                                  "System Files and Software Files cannot be Manipulated")),
                        );
                      }
                    },
                    child: const Text("Save"),
                  )
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  // Helper for field UI
  Widget _buildFieldRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: fieldControllers[index],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Field',
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
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
