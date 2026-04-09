import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'highlight_slider.dart';
import 'faculty_upload.dart';
import 'faculty_availability.dart';
import 'faculty_profile_page.dart';
import 'events.dart';
import 'lost_found.dart';
import 'navigation_page.dart';
import 'emergency.dart';
import 'login_page.dart';

class FacultyDashboard extends StatefulWidget {
  const FacultyDashboard({Key? key}) : super(key: key);

  @override
  State<FacultyDashboard> createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {

  String fullName = "Faculty";
  String department = "";
  String designation = "";
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchFacultyData();
  }

  Future<void> fetchFacultyData() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("faculty")
        .doc(user.email)
        .get();

    if (doc.exists) {
      final d = doc.data()!;

      setState(() {
        fullName = "${d["firstName"] ?? ""} ${d["lastName"] ?? ""}";
        department = d["department"] ?? "";
        designation = d["designation"] ?? "";
        imageUrl = d["image"] ?? "";
      });
    }
  }

  /// 🔥 MODERN CARD
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
        title: const Text("Faculty Dashboard"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blue],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FacultyProfilePage()),
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

                      Text("$designation"),

                      Text("$department"),
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

                  moduleCard(
                      "Upload Materials",
                      Icons.upload_file,
                      const UploadMaterialPage(),
                      Colors.blue),

                  moduleCard(
                      "Availability",
                      Icons.schedule,
                      const FacultyAvailabilityPage(),
                      Colors.green),

                  moduleCard(
                      "Events",
                      Icons.event,
                      EventsPage(),
                      Colors.orange),

                  moduleCard(
                      "Lost & Found",
                      Icons.search,
                      LostFoundPage(),
                      Colors.red),

                  moduleCard(
                      "Navigation",
                      Icons.map,
                      NavigationPage(),
                      Colors.purple),
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
            MaterialPageRoute(builder: (_) => const EmergencyPage()),
          );
        },
        child: const Icon(Icons.warning),
      ),
    );
  }
}