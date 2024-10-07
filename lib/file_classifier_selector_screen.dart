import 'package:flutter/material.dart';
import 'package:superfiles/dart_server/tree_structure_selector.dart';

class FileClassifierSelectorScreen extends StatefulWidget {
  const FileClassifierSelectorScreen({super.key});

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
              child: AddDocumentForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class AddDocumentForm extends StatefulWidget {
  @override
  _AddDocumentFormState createState() => _AddDocumentFormState();
}

class _AddDocumentFormState extends State<AddDocumentForm> {
  final documentIdController = TextEditingController();
  List<TextEditingController> fieldControllers = [];

  @override
  Widget build(BuildContext context) {
    return Column(
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
              "Parent Path\n/CSE",
              style: TextStyle(
                  fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
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
                  controller: documentIdController,
                  decoration: InputDecoration(
                    labelText: 'Document ID',
                    border: OutlineInputBorder(),
                    hintText: 'Enter Document ID',
                  ),
                ),
              ),
              SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  // Logic to generate Auto-ID
                  documentIdController.text = "Auto-ID Generated";
                },
                child: Text("Auto-ID"),
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
                onPressed: () {
                  // Handle button press
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TreeStructureSelector()));
                  print("Document ID: ${documentIdController.text}");
                  fieldControllers.forEach((controller) {
                    print("Field: ${controller.text}");
                  });
                },
                child: Text("Save"),
              )
            ],
          ),
        )
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
