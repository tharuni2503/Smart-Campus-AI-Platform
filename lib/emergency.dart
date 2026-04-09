import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({Key? key}) : super(key: key);

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {

  String aiMessage = "";
  bool alertSent = false;
  String? alertDocId;
  String userRole = "UNKNOWN";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    detectRole();
  }

  /// 🔍 DETECT ROLE
  Future<void> detectRole() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final student = await FirebaseFirestore.instance
        .collection("students")
        .doc(user.email)
        .get();

    if (student.exists) {
      if (!mounted) return;
      setState(() => userRole = "STUDENT");
      return;
    }

    final faculty = await FirebaseFirestore.instance
        .collection("faculty")
        .doc(user.email)
        .get();

    if (faculty.exists) {
      if (!mounted) return;
      setState(() => userRole = "FACULTY");
    }
  }

  /// 🚨 PANIC BUTTON (SAFE VERSION)
  Future<void> sendEmergencyAlert() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => loading = true);

    /// ❗ prevent duplicate alerts
    final existing = await FirebaseFirestore.instance
        .collection("emergency_alerts")
        .where("user", isEqualTo: user.email)
        .where("status", isEqualTo: "ACTIVE")
        .get();

    if (existing.docs.isNotEmpty) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alert already active")),
      );
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("emergency_alerts")
        .add({
      "user": user.email,
      "role": userRole,
      "status": "ACTIVE",
      "time": Timestamp.now(),
    });

    setState(() {
      alertDocId = doc.id;
      alertSent = true;
      loading = false;
      aiMessage =
      "🚨 ALERT SENT\n\nSecurity notified.\nStay calm & follow instructions.";
    });

    /// 🔥 listen for status change (admin resolves)
    FirebaseFirestore.instance
        .collection("emergency_alerts")
        .doc(doc.id)
        .snapshots()
        .listen((snapshot) {

      if (snapshot.exists && snapshot["status"] == "RESOLVED") {

        if (!mounted) return;

        setState(() {
          alertSent = false;
          alertDocId = null;
          aiMessage = "✅ Your emergency has been resolved.";
        });
      }
    });
  }

  /// ✅ CLEAR ALERT
  Future<void> clearEmergency() async {

    if (alertDocId == null) return;

    await FirebaseFirestore.instance
        .collection("emergency_alerts")
        .doc(alertDocId)
        .update({"status": "RESOLVED"});

    if (!mounted) return;

    setState(() {
      alertSent = false;
      alertDocId = null;
      aiMessage = "";
    });
  }

  /// 🤖 AI HELP
  void aiHelp(String type) {

    final map = {
      "Fire": "🔥 FIRE\n• Use stairs\n• Avoid elevators\n• Exit immediately",
      "Earthquake": "🌍 EARTHQUAKE\n• Drop, Cover, Hold\n• Stay away from glass",
      "Medical": "🏥 MEDICAL\n• Call help\n• Stay with patient",
      "General": "⚠️ SAFETY\n• Stay calm\n• Follow instructions",
    };

    setState(() => aiMessage = map[type]!);
  }

  /// 🔔 LIVE NOTIFICATIONS
  Widget liveAlerts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("emergency_notifications")
          .orderBy("time", descending: true)
          .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Text("No notifications");
        }

        return Column(
          children: docs.map((doc) {
            return Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.red),
                title: Text(doc["title"]),
                subtitle: Text(doc["message"]),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Emergency ($userRole)"),
        backgroundColor: Colors.red,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// 🚨 PANIC BUTTON
            ElevatedButton.icon(
              onPressed: (alertSent || loading) ? null : sendEmergencyAlert,
              icon: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.warning),

              label: const Text("PANIC BUTTON"),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
              ),
            ),

            /// ✅ SAFE BUTTON
            if (alertSent)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton.icon(
                  onPressed: clearEmergency,
                  icon: const Icon(Icons.check),
                  label: const Text("Mark as Safe"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /// 🤖 QUICK HELP
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(onPressed: () => aiHelp("Fire"), child: const Text("🔥 Fire")),
                ElevatedButton(onPressed: () => aiHelp("Earthquake"), child: const Text("🌍 Earthquake")),
                ElevatedButton(onPressed: () => aiHelp("Medical"), child: const Text("🏥 Medical")),
                ElevatedButton(onPressed: () => aiHelp("General"), child: const Text("⚠️ General")),
              ],
            ),

            /// 📢 AI MESSAGE BOX
            if (aiMessage.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: 20),
                color: Colors.yellow.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(aiMessage),
                ),
              ),

            const SizedBox(height: 25),

            const Text(
              "Live Safety Notifications",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            liveAlerts(),
          ],
        ),
      ),
    );
  }
}