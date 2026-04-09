import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class UploadMaterialPage extends StatefulWidget {
  const UploadMaterialPage({Key? key}) : super(key: key);

  @override
  State<UploadMaterialPage> createState() => _UploadMaterialPageState();
}

class _UploadMaterialPageState extends State<UploadMaterialPage> {

  final titleCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();

  Uint8List? fileBytes;
  String? fileName;

  /// PICK FILE
  Future<void> pickFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {

      setState(() {
        fileBytes = result.files.single.bytes;
        fileName = result.files.single.name;
      });

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );

    }
  }

  /// UPLOAD MATERIAL
  Future<void> uploadMaterial() async {

    if (titleCtrl.text.isEmpty ||
        subjectCtrl.text.isEmpty ||
        fileBytes == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields and select file")),
      );
      return;
    }

    String base64File = base64Encode(fileBytes!);

    await FirebaseFirestore.instance.collection("materials").add({

      "title": titleCtrl.text.trim(),
      "subject": subjectCtrl.text.trim(),
      "file": base64File,
      "fileName": fileName,
      "timestamp": Timestamp.now(),

    });

    titleCtrl.clear();
    subjectCtrl.clear();

    setState(() {
      fileBytes = null;
      fileName = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Material Uploaded")),
    );
  }

  /// DELETE MATERIAL
  Future<void> deleteMaterial(String docId) async {

    await FirebaseFirestore.instance
        .collection("materials")
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Material Deleted")),
    );
  }

  /// OPEN PDF
  Future<void> openPDF(String title, String base64File) async {

    final bytes = base64Decode(base64File);

    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/$title.pdf");

    await file.writeAsBytes(bytes);

    await OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Upload Study Material"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// TITLE
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 10),

            /// SUBJECT
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: "Subject"),
            ),

            const SizedBox(height: 15),

            /// PICK FILE
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Select PDF"),
              onPressed: pickFile,
            ),

            if (fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Selected File: $fileName",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 20),

            /// UPLOAD
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text("Upload Material"),
              onPressed: uploadMaterial,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const Text(
              "Uploaded Materials",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// MATERIAL LIST
            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("materials")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text("No materials uploaded yet");
                }

                return ListView.builder(

                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {

                    final doc = docs[index];

                    return Card(

                      child: ListTile(

                        leading: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                        ),

                        title: Text(doc["title"]),

                        subtitle: Text(doc["subject"]),

                        onTap: () {

                          openPDF(
                            doc["title"],
                            doc["file"],
                          );

                        },

                        trailing: IconButton(

                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () {

                            showDialog(

                              context: context,

                              builder: (_) => AlertDialog(

                                title: const Text("Delete Material"),

                                content: const Text(
                                    "Are you sure you want to delete this material?"),

                                actions: [

                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteMaterial(doc.id);
                                    },
                                    child: const Text("Delete"),
                                  ),

                                ],
                              ),
                            );

                          },
                        ),

                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}