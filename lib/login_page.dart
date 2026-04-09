import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_page.dart';
import 'student_dashboard.dart';
import 'faculty_dashboard.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String role = "Student";

  final email = TextEditingController();
  final password = TextEditingController();

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> login() async {

    if (email.text.isEmpty || password.text.isEmpty) {
      showMsg("Enter email & password");
      return;
    }

    final enteredEmail = email.text.trim();

    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: enteredEmail,
        password: password.text.trim(),
      );

      /// 🔐 ADMIN
      if (role == "Admin") {
        if (enteredEmail == "admin@gmail.com") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AdminDashboard()));
        } else {
          await FirebaseAuth.instance.signOut();
          showMsg("Not an Admin account");
        }
        return;
      }

      /// 🎓 STUDENT
      if (role == "Student") {

        final doc = await FirebaseFirestore.instance
            .collection("students")
            .doc(enteredEmail)
            .get();

        if (doc.exists) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => StudentDashboard()));
        } else {
          await FirebaseAuth.instance.signOut();
          showMsg("Not a Student account");
        }
        return;
      }

      /// 👨‍🏫 FACULTY
      if (role == "Faculty") {

        final doc = await FirebaseFirestore.instance
            .collection("faculty")
            .doc(enteredEmail)
            .get();

        if (doc.exists) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => FacultyDashboard()));
        } else {
          await FirebaseAuth.instance.signOut();
          showMsg("Faculty not approved yet");
        }
        return;
      }

    } catch (e) {
      showMsg("Login Failed");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43cea2), Color(0xFF185a9d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            child: Container(
              width: 350,
              padding: const EdgeInsets.all(20),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Icon(Icons.school, size: 60, color: Colors.blue),

                  const SizedBox(height: 10),

                  const Text("Smart Campus Login",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: "Select Role"),
                    items: ["Student", "Faculty", "Admin"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => role = val!),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: "Password",
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: login,
                    child: const Text("Login"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterPage()),
                    ),
                    child: const Text("Create Account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}