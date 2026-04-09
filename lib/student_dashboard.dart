import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ai_study_assistant.dart';
import 'highlight_slider.dart';
import 'study_materials.dart';
import 'navigation_page.dart';
import 'events.dart';
import 'career_page.dart';
import 'lost_found.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'emergency.dart';
import 'student_faculty_availability.dart';
import 'mental_health_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {

  String fullName = "Student";
  String branch = "";
  String year = "";
  String attendance = "";
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("students")
        .doc(user.email)
        .get();

    if (doc.exists) {
      final d = doc.data()!;

      setState(() {
        fullName = "${d["firstName"] ?? ""} ${d["lastName"] ?? ""}";
        branch = d["branch"] ?? "";
        year = d["year"]?.toString() ?? "";
        attendance = d["attendance"]?.toString() ?? "";
        imageUrl = d["image"] ?? "";
      });
    }
  }

  /// 🔥 MODULE CARD (UPGRADED)
  Widget moduleCard(String title, IconData icon, Widget page, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      /// 🔥 APPBAR
      appBar: AppBar(
        title: const Text("Smart Campus"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.indigo],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: Column(
        children: [

          /// 🔥 PROFILE HEADER
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                  (imageUrl != null && imageUrl!.isNotEmpty)
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: (imageUrl == null || imageUrl!.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(fullName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),

                      Text("$branch | Year $year"),

                      Text("Attendance: $attendance%"),
                    ],
                  ),
                )
              ],
            ),
          ),

          /// ⭐ SLIDER
          const Padding(
            padding: EdgeInsets.all(10),
            child: HighlightSlider(),
          ),

          /// 🔥 GRID
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [

                  moduleCard("Study Materials", Icons.book,
                      const StudyMaterialsPage(), Colors.blue),

                  moduleCard("AI Assistant", Icons.psychology,
                      const AIChatPage(), Colors.purple),

                  moduleCard("Navigation", Icons.map,
                      NavigationPage(), Colors.teal),

                  moduleCard("Events", Icons.event,
                      EventsPage(), Colors.orange),

                  moduleCard("Career", Icons.work,
                      CareerPage(), Colors.green),

                  moduleCard("Lost & Found", Icons.search,
                      LostFoundPage(), Colors.red),

                  moduleCard("Faculty", Icons.schedule,
                      StudentFacultyAvailabilityPage(), Colors.indigo),

                  moduleCard("Mental Health", Icons.favorite,
                      const MentalHealthPage(), Colors.pink),

                ],
              ),
            ),
          ),
        ],
      ),

      /// 🚨 EMERGENCY BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EmergencyPage()),
          );
        },
        child: const Icon(Icons.warning),
      ),
    );
  }
}