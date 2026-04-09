import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostEventPage extends StatefulWidget {
  const PostEventPage({Key? key}) : super(key: key);

  @override
  State<PostEventPage> createState() => _PostEventPageState();
}

class _PostEventPageState extends State<PostEventPage> {

  final titleCtrl = TextEditingController();
  Uint8List? imageBytes;
  bool isUploading = false;

  String facultyEmail = "";

  @override
  void initState() {
    super.initState();
    facultyEmail = FirebaseAuth.instance.currentUser?.email ?? "";
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 📸 PICK IMAGE (LIKE LOST & FOUND)
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        imageBytes = bytes;
      });
    }
  }

  /// 🚀 UPLOAD EVENT (NO STORAGE)
  Future<void> uploadEvent() async {

    if (titleCtrl.text.isEmpty || imageBytes == null) {
      showMsg("Add title & image");
      return;
    }

    try {
      setState(() => isUploading = true);

      /// 🔥 CONVERT TO BASE64
      String base64Image = base64Encode(imageBytes!);

      await FirebaseFirestore.instance.collection("events").add({
        "title": titleCtrl.text.trim(),
        "image": base64Image,
        "facultyId": facultyEmail,
        "timestamp": Timestamp.now(),
      });

      setState(() {
        isUploading = false;
        imageBytes = null;
        titleCtrl.clear();
      });

      showMsg("✅ Event Posted");

    } catch (e) {
      setState(() => isUploading = false);
      showMsg("❌ Error: $e");
    }
  }

  /// 🗑 DELETE
  Future<void> deleteEvent(String id) async {
    await FirebaseFirestore.instance.collection("events").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("✨ Create Event")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// TITLE
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: "Event Title",
              ),
            ),

            const SizedBox(height: 15),

            /// IMAGE PICK
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: imageBytes == null
                    ? const Center(child: Text("Tap to upload image"))
                    : Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 15),

            /// BUTTON
            ElevatedButton(
              onPressed: isUploading ? null : uploadEvent,
              child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("🚀 Post Event"),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("📌 My Events"),
            ),

            /// EVENTS LIST
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No events yet"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      final data = docs[index].data() as Map<String, dynamic>;
                      final img = base64Decode(data["image"]);

                      return Card(
                        child: Stack(
                          children: [

                            Image.memory(
                              img,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),

                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black54,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  data["title"],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteEvent(docs[index].id),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}