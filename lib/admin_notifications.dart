import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyApprovalPage extends StatelessWidget {
  const FacultyApprovalPage({Key? key}) : super(key: key);

  Future<void> approveFaculty(String email) async {

    await FirebaseFirestore.instance.collection("faculty").doc(email).set({
      "email": email,
      "approved": true,
    });

    await FirebaseFirestore.instance
        .collection("faculty_requests")
        .doc(email)
        .delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Faculty Approvals")),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("faculty_requests")
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No Requests"));
          }

          return ListView(
            children: docs.map((doc) {
              return Card(
                child: ListTile(
                  title: Text(doc["email"]),
                  trailing: ElevatedButton(
                    child: const Text("Approve"),
                    onPressed: () => approveFaculty(doc["email"]),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}