import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class StudyMaterialsPage extends StatefulWidget {
  const StudyMaterialsPage({Key? key}) : super(key: key);

  @override
  State<StudyMaterialsPage> createState() => _StudyMaterialsPageState();
}

class _StudyMaterialsPageState extends State<StudyMaterialsPage> {

  String search = "";

  /// DOWNLOAD + OPEN PDF
  Future<void> downloadMaterial(String title, String base64File) async {

    try {

      final bytes = base64Decode(base64File);

      /// Save to device storage
      final dir = await getExternalStorageDirectory();

      final filePath =
          "${dir!.path}/${title.replaceAll(" ", "_")}.pdf";

      final file = File(filePath);

      await file.writeAsBytes(bytes);

      /// Show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF downloaded")),
      );

      /// Open PDF
      await OpenFilex.open(filePath);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download failed")),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Study Materials"),
      ),

      body: Column(
        children: [

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search materials...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
            ),
          ),

          /// MATERIAL LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("materials")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {

                  final title = doc["title"].toString().toLowerCase();
                  final subject = doc["subject"].toString().toLowerCase();

                  return title.contains(search) || subject.contains(search);

                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text("No materials found"),
                  );
                }

                return ListView.builder(

                  itemCount: docs.length,

                  itemBuilder: (context, index) {

                    final doc = docs[index];

                    return Card(

                      margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6
                      ),

                      child: ListTile(

                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),

                        title: Text(doc["title"]),

                        subtitle: Text(doc["subject"]),

                        trailing: const Icon(Icons.download),

                        onTap: () {

                          downloadMaterial(
                            doc["title"],
                            doc["file"],   // Base64 file
                          );

                        },

                      ),
                    );
                  },
                );
              },
            ),
          )

        ],
      ),
    );
  }
}