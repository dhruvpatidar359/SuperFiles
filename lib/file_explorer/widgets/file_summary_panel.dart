import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:superfiles/file_explorer/services/Summary/get_summary.dart';



class FileSummaryPanel extends StatelessWidget {
  final FileSystemEntity selectedEntity;
  final Database database;

  const FileSummaryPanel({super.key,
    required this.selectedEntity,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: GetSummary.getSummary(selectedEntity,database),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final details = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem(Icons.folder, "Name", details['name']),
                _buildDetailItem(Icons.description, "Type", details['type']),
                _buildDetailItem(Icons.storage, "Size", details['size']),
                _buildDetailItem(Icons.list_alt, "Items", details['itemCount']),
                _buildDetailItem(Icons.location_on, "Path", details['path']),
                if (details.containsKey('summary'))
                  _buildDetailItem(Icons.article, "Summary", details['summary']),
              ],
            ),
          );
        } else {
          return Text("No details available.");
        }
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title: $value",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}