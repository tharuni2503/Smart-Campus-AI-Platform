import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class LostFoundPage extends StatefulWidget {
  const LostFoundPage({Key? key}) : super(key: key);

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage>
    with SingleTickerProviderStateMixin {

  Uint8List? lostImage;
  Uint8List? foundImage;

  final lostNameCtrl = TextEditingController();
  final foundNameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  List<Map<String, dynamic>> matchedItems = [];

  late TabController tabController;

  bool isLoading = false;

  /// 🔹 PICK IMAGE
  Future<void> pickImage(bool isLost) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        if (isLost) {
          lostImage = result.files.single.bytes!;
        } else {
          foundImage = result.files.single.bytes!;
        }
      });
    }
  }

  /// 🔹 DELETE ITEM
  Future<void> deleteItem(String docId) async {
    await FirebaseFirestore.instance
        .collection("found_items")
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item deleted")),
    );
  }

  /// 🔹 IMAGE SIMILARITY (IMPROVED)
  Future<double> imageSimilarity(Uint8List img1, Uint8List img2) async {

    Future<List<int>> getHash(Uint8List img) async {
      final codec = await ui.instantiateImageCodec(img, targetWidth: 16, targetHeight: 16);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);

      if (data == null) return [];

      List<int> gray = [];

      for (int i = 0; i < data.lengthInBytes; i += 4) {
        int r = data.getUint8(i);
        int g = data.getUint8(i + 1);
        int b = data.getUint8(i + 2);

        int avg = ((r + g + b) ~/ 3);
        gray.add(avg);
      }

      int mean = gray.reduce((a, b) => a + b) ~/ gray.length;

      return gray.map((e) => e > mean ? 1 : 0).toList();
    }

    List<int> hash1 = await getHash(img1);
    List<int> hash2 = await getHash(img2);

    if (hash1.isEmpty || hash2.isEmpty) return 0;

    int diff = 0;

    for (int i = 0; i < hash1.length; i++) {
      if (hash1[i] != hash2[i]) diff++;
    }

    return 1 - (diff / hash1.length);
  }
  /// 🔹 SMART TEXT MATCH (KEYWORDS + SYNONYMS)
  bool smartTextMatch(String lost, String found, String desc) {

    List<String> synonyms(String word) {
      word = word.toLowerCase();

      if (word.contains("phone")) return ["phone","mobile","iphone"];
      if (word.contains("bag")) return ["bag","backpack","luggage"];
      if (word.contains("bottle")) return ["bottle","flask"];
      if (word.contains("wallet")) return ["wallet","purse"];
      if (word.contains("watch")) return ["watch","smartwatch"];

      return [word];
    }

    List<String> lostWords = synonyms(lost);

    for (String w in lostWords) {
      if (found.contains(w) || desc.contains(w)) {
        return true;
      }
    }

    return false;
  }

  /// 🔹 MATCH ITEMS (FAST + ACCURATE)
  Future<void> matchItems() async {

    if (lostImage == null) return;

    setState(() {
      isLoading = true;
    });

    String lostText = lostNameCtrl.text.toLowerCase();

    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection("found_items").get();

    List<Map<String, dynamic>> matches = [];

    for (var doc in snapshot.docs) {

      Uint8List foundImg = base64Decode(doc["image"]);

      double similarity = await imageSimilarity(lostImage!, foundImg);

      String foundName = doc["name"].toString().toLowerCase();
      String foundDesc = foundName;

      bool textMatch = smartTextMatch(lostText, foundName, foundDesc);

      double score = similarity;

      if (textMatch) score += 0.4;

      if (score > 0.45) {

        matches.add({
          "name": doc["name"],
          "location": doc["location"],
          "image": doc["image"],
          "reason": "High similarity & keyword match",
          "score": score
        });
      }
    }

    matches.sort((a, b) => b["score"].compareTo(a["score"]));

    setState(() {
      matchedItems = matches;
      isLoading = false;
    });

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No matches found")),
      );
    }
  }

  /// 🔹 UPLOAD FOUND ITEM
  Future<void> uploadFoundItem() async {

    if (foundImage == null ||
        foundNameCtrl.text.isEmpty ||
        locationCtrl.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    String base64Image = base64Encode(foundImage!);

    await FirebaseFirestore.instance.collection("found_items").add({
      "name": foundNameCtrl.text.trim(),
      "location": locationCtrl.text.trim(),
      "image": base64Image,
      "timestamp": Timestamp.now(),
    });

    foundNameCtrl.clear();
    locationCtrl.clear();

    setState(() {
      foundImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Uploaded")),
    );
  }

  /// 🔹 LOST TAB UI
  Widget lostTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          TextField(
            controller: lostNameCtrl,
            decoration: const InputDecoration(labelText: "Lost Item Name"),
          ),

          const SizedBox(height: 10),

          lostImage == null
              ? const Text("Upload Lost Image")
              : Image.memory(lostImage!, height: 120),

          ElevatedButton(
            onPressed: () => pickImage(true),
            child: const Text("Select Image"),
          ),

          ElevatedButton(
            onPressed: matchItems,
            child: const Text("Find Matches"),
          ),

          const SizedBox(height: 20),

          isLoading
              ? const CircularProgressIndicator()
              : Expanded(
            child: ListView.builder(
              itemCount: matchedItems.length,
              itemBuilder: (context, index) {

                final item = matchedItems[index];
                final img = base64Decode(item["image"]);

                return Card(
                  child: ListTile(
                    leading: Image.memory(img, width: 50),
                    title: Text(item["name"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Location: ${item["location"]}"),
                        Text(item["reason"]),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 FOUND TAB UI
  Widget foundTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          TextField(
            controller: foundNameCtrl,
            decoration: const InputDecoration(labelText: "Item Name"),
          ),

          TextField(
            controller: locationCtrl,
            decoration: const InputDecoration(labelText: "Location"),
          ),

          foundImage == null
              ? const Text("Upload Image")
              : Image.memory(foundImage!, height: 120),

          ElevatedButton(
            onPressed: () => pickImage(false),
            child: const Text("Select Image"),
          ),

          ElevatedButton(
            onPressed: uploadFoundItem,
            child: const Text("Upload"),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("found_items")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final doc = docs[index];
                    final img = base64Decode(doc["image"]);

                    return Card(
                      child: ListTile(
                        leading: Image.memory(img, width: 50),
                        title: Text(doc["name"]),
                        subtitle: Text("Location: ${doc["location"]}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteItem(doc.id),
                        ),
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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Lost & Found"),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Lost"),
            Tab(text: "Found"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          lostTab(),
          foundTab(),
        ],
      ),
    );
  }
}