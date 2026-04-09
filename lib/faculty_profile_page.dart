import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FacultyProfilePage extends StatefulWidget {
  const FacultyProfilePage({Key? key}) : super(key: key);

  @override
  State<FacultyProfilePage> createState() => _FacultyProfilePageState();
}

class _FacultyProfilePageState extends State<FacultyProfilePage> {

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final employeeId = TextEditingController();
  final department = TextEditingController();
  final designation = TextEditingController();
  final subjects = TextEditingController();
  final phone = TextEditingController();
  final officeLocation = TextEditingController();
  final qualifications = TextEditingController();
  final experience = TextEditingController();
  final researchInterests = TextEditingController();

  String? imageUrl;

  bool loading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// 🔹 LOAD PROFILE
  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("faculty")
        .doc(user.email)
        .get();

    if (doc.exists) {
      final d = doc.data()!;
      firstName.text = d["firstName"] ?? "";
      lastName.text = d["lastName"] ?? "";
      employeeId.text = d["employeeId"] ?? "";
      department.text = d["department"] ?? "";
      designation.text = d["designation"] ?? "";
      subjects.text = d["subjects"] ?? "";
      phone.text = d["phone"] ?? "";
      officeLocation.text = d["officeLocation"] ?? "";
      qualifications.text = d["qualifications"] ?? "";
      experience.text = d["experience"] ?? "";
      researchInterests.text = d["researchInterests"] ?? "";
      imageUrl = d["image"] ?? "";
    }

    setState(() => loading = false);
  }

  /// 🔹 IMAGE PICK + UPLOAD
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    final user = FirebaseAuth.instance.currentUser;

    final ref = FirebaseStorage.instance
        .ref("faculty/${user!.email}.jpg");

    await ref.putFile(file);

    String url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("faculty")
        .doc(user.email)
        .set({"image": url}, SetOptions(merge: true));

    setState(() {
      imageUrl = url;
    });
  }

  /// 🔹 SAVE PROFILE
  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("faculty")
        .doc(user!.email)
        .set({
      "firstName": firstName.text.trim(),
      "lastName": lastName.text.trim(),
      "employeeId": employeeId.text.trim(),
      "department": department.text.trim(),
      "designation": designation.text.trim(),
      "subjects": subjects.text.trim(),
      "phone": phone.text.trim(),
      "officeLocation": officeLocation.text.trim(),
      "qualifications": qualifications.text.trim(),
      "experience": experience.text.trim(),
      "researchInterests": researchInterests.text.trim(),
      "image": imageUrl,
    }, SetOptions(merge: true));

    setState(() => isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
    );
  }

  /// 🔹 UI TILE
  Widget infoTile(String title, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value.isEmpty ? "-" : value),
      ),
    );
  }

  /// 🔹 FIELD
  Widget field(TextEditingController c, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Faculty Profile"),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => isEditing = !isEditing),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// 🔥 PROFILE IMAGE
            GestureDetector(
              onTap: isEditing ? pickAndUploadImage : null,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                (imageUrl != null && imageUrl!.isNotEmpty)
                    ? NetworkImage(
                    "${imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}")
                    : null,
                child: (imageUrl == null || imageUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 15),

            /// 🔥 NAME
            Text(
              "${firstName.text} ${lastName.text}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 🔥 VIEW MODE
            if (!isEditing) ...[

              infoTile("Employee ID", employeeId.text, Icons.badge),
              infoTile("Department", department.text, Icons.school),
              infoTile("Designation", designation.text, Icons.work),
              infoTile("Subjects", subjects.text, Icons.menu_book),
              infoTile("Phone", phone.text, Icons.phone),
              infoTile("Office", officeLocation.text, Icons.location_on),
              infoTile("Qualifications", qualifications.text, Icons.school_outlined),
              infoTile("Experience", experience.text, Icons.timeline),
              infoTile("Research", researchInterests.text, Icons.science),

            ]

            /// 🔥 EDIT MODE
            else ...[

              field(firstName, "First Name", Icons.person),
              field(lastName, "Last Name", Icons.person_outline),
              field(employeeId, "Employee ID", Icons.badge),
              field(department, "Department", Icons.school),
              field(designation, "Designation", Icons.work),
              field(subjects, "Subjects", Icons.menu_book),
              field(phone, "Phone", Icons.phone),
              field(officeLocation, "Office Location", Icons.location_on),
              field(qualifications, "Qualifications", Icons.school_outlined),
              field(experience, "Experience", Icons.timeline),
              field(researchInterests, "Research Interests", Icons.science),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: saveProfile,
                child: const Text("Save Profile"),
              ),
            ]

          ],
        ),
      ),
    );
  }
}