import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlertsPage extends StatelessWidget {
  const EmergencyAlertsPage({Key? key}) : super(key: key);

  /// 🔥 SAFE DATA EXTRACT
  Map<String, dynamic> safeData(DocumentSnapshot doc) {
    try {
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🚨 Emergency Alerts"),
        backgroundColor: Colors.red,
      ),

      body: StreamBuilder<QuerySnapshot>(
        /// ✅ Only ACTIVE alerts
        stream: FirebaseFirestore.instance
            .collection("emergency_alerts")
            .where("status", isEqualTo: "ACTIVE")
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Active Alerts",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,

            itemBuilder: (context, index) {

              final doc = docs[index];
              final data = safeData(doc);

              /// ✅ SAFE VALUES
              final user = data["user"] ?? data["email"] ?? "Unknown User";
              final role = data["role"] ?? "Unknown";
              final time = data["time"];

              String timeText = "";
              if (time != null && time is Timestamp) {
                final dt = time.toDate();
                timeText = "${dt.hour}:${dt.minute} | ${dt.day}/${dt.month}";
              }

              return Card(
                elevation: 6,
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.red, size: 30),

                  title: Text(
                    user,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Role: $role"),
                      if (timeText.isNotEmpty)
                        Text("Time: $timeText",
                            style: const TextStyle(fontSize: 12)),
                    ],
                  ),

                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),

                    child: const Text("Resolve"),

                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("emergency_alerts")
                          .doc(doc.id)
                          .update({"status": "RESOLVED"});

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Alert Resolved")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}