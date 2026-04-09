import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'groq_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final rollNo = TextEditingController();
  final branch = TextEditingController();
  final attendance = TextEditingController();
  final year = TextEditingController();
  final skills = TextEditingController();
  final internships = TextEditingController();
  final certificates = TextEditingController();
  final goals = TextEditingController();
  final college = TextEditingController();
  final linkedin = TextEditingController();
  final github = TextEditingController();
  final projects = TextEditingController();

  String? imageUrl;

  bool loading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// 🔥 AI RESUME
  Future<String> generateAIResume() async {

    String prompt = """
Create an ATS-friendly professional resume.

Name: ${firstName.text} ${lastName.text}
College: ${college.text}
Branch: ${branch.text}
Year: ${year.text}

Skills: ${skills.text}
Projects: ${projects.text}
Internships: ${internships.text}
Certificates: ${certificates.text}

LinkedIn: ${linkedin.text}
GitHub: ${github.text}

Career Goals: ${goals.text}

Sections:
- Summary
- Skills
- Projects
- Experience
- Education
- Achievements
- Links

Keep it professional and ATS optimized.
""";

    return await GroqService.askAI(prompt);
  }

  /// 🔥 AI PDF
  Future<void> generateAIPDF(String text) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "${firstName.text} ${lastName.text}",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(text),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/AI_Resume.pdf");

    await file.writeAsBytes(await pdf.save());

    OpenFilex.open(file.path);
  }

  /// 🔹 LOAD PROFILE
  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("students")
        .doc(user.email)
        .get();

    if (doc.exists) {
      final d = doc.data()!;
      firstName.text = d["firstName"] ?? "";
      lastName.text = d["lastName"] ?? "";
      rollNo.text = d["rollNo"] ?? "";
      branch.text = d["branch"] ?? "";
      year.text = (d["year"] ?? "").toString();
      skills.text = d["skills"] ?? "";
      internships.text = d["internships"] ?? "";
      certificates.text = d["certificates"] ?? "";
      goals.text = d["goals"] ?? "";
      attendance.text = (d["attendance"] ?? "").toString();
      college.text = d["college"] ?? "";
      linkedin.text = d["linkedin"] ?? "";
      github.text = d["github"] ?? "";
      projects.text = d["projects"] ?? "";

      imageUrl = d["image"] ?? "";
    }

    setState(() => loading = false);
  }

  /// 🔹 SAVE PROFILE
  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection("students")
        .doc(user!.email)
        .set({
      "firstName": firstName.text,
      "lastName": lastName.text,
      "rollNo": rollNo.text,
      "branch": branch.text,
      "year": int.tryParse(year.text) ?? 1,
      "skills": skills.text,
      "internships": internships.text,
      "certificates": certificates.text,
      "goals": goals.text,
      "attendance": double.tryParse(attendance.text) ?? 0,
      "college": college.text,
      "linkedin": linkedin.text,
      "github": github.text,
      "projects": projects.text,

      "image": imageUrl,
    }, SetOptions(merge: true));

    setState(() => isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
    );
  }

  /// 🔹 IMAGE
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();

    /// 👉 show options (camera / gallery)
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () async {

                  Navigator.pop(context);

                  final picked = await picker.pickImage(source: ImageSource.gallery);

                  if (picked == null) return;

                  uploadToFirebase(File(picked.path));
                },
              ),

              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () async {

                  Navigator.pop(context);

                  final picked = await picker.pickImage(source: ImageSource.camera);

                  if (picked == null) return;

                  uploadToFirebase(File(picked.path));
                },
              ),

            ],
          ),
        );
      },
    );
  }

  Future<void> uploadToFirebase(File file) async {

    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final ref = FirebaseStorage.instance
        .ref("profiles/${user!.email}.jpg");

    await ref.putFile(file);

    String url = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection("students")
        .doc(user.email)
        .set({
      "image": url,
    }, SetOptions(merge: true));

    Navigator.pop(context);

    setState(() {
      imageUrl = url;
    });
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
        title: const Text("AI Profile"),
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

            GestureDetector(
              onTap: isEditing ? pickAndUploadImage : null,
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                (imageUrl != null && imageUrl!.isNotEmpty)
                    ? NetworkImage(
                    "${imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}")
                    : null,
                child: (imageUrl == null || imageUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 40)
                    : null,
              )
            ),

            const SizedBox(height: 20),

            /// ✅ VIEW MODE
            if (!isEditing) ...[

              Text(
                "${firstName.text} ${lastName.text}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text("Branch: ${branch.text}"),
                  subtitle: Text("Year: ${year.text}"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.percent),
                  title: Text("Attendance: ${attendance.text}%"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.business),
                  title: Text("College: ${college.text}"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.code),
                  title: Text("Skills: ${skills.text}"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.link),
                  title: Text("LinkedIn: ${linkedin.text}"),
                ),
              ),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.code_off),
                  title: Text("GitHub: ${github.text}"),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Sample AI Resume"),
                onPressed: () async {

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  String result = await generateAIResume();

                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("AI Resume"),
                      content: SizedBox(
                        height: 400,
                        child: SingleChildScrollView(child: Text(result)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => generateAIPDF(result),
                          child: const Text("Download PDF"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
              ),

            ]

            /// ✅ EDIT MODE
            else ...[

              TextField(controller: firstName, decoration: const InputDecoration(labelText: "First Name")),
              TextField(controller: lastName, decoration: const InputDecoration(labelText: "Last Name")),
              TextField(controller: college, decoration: const InputDecoration(labelText: "College")),
              TextField(controller: branch, decoration: const InputDecoration(labelText: "Branch")),
              TextField(controller: year, decoration: const InputDecoration(labelText: "Year")),

              TextField(controller: skills, decoration: const InputDecoration(labelText: "Skills")),
              TextField(controller: projects, decoration: const InputDecoration(labelText: "Projects")),
              TextField(controller: internships, decoration: const InputDecoration(labelText: "Internships")),
              TextField(controller: certificates, decoration: const InputDecoration(labelText: "Certificates")),
              TextField(controller: goals, decoration: const InputDecoration(labelText: "Goals")),

              TextField(
                controller: attendance,
                decoration: const InputDecoration(labelText: "Attendance (%)"),
                keyboardType: TextInputType.number,
              ),

              TextField(controller: linkedin, decoration: const InputDecoration(labelText: "LinkedIn URL")),
              TextField(controller: github, decoration: const InputDecoration(labelText: "GitHub URL")),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: saveProfile,
                child: const Text("Save"),
              ),
            ]
          ],
        )
      ),
    );
  }
}