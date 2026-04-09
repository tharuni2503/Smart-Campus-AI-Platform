import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  String role = "Student";

  final email = TextEditingController();
  final password = TextEditingController();

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> register() async {

    if (email.text.isEmpty || password.text.length < 6) {
      showMsg("Enter valid email & password (min 6 chars)");
      return;
    }

    try {

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      /// 🔥 STUDENT DATA
      if (role == "Student") {
        await FirebaseFirestore.instance
            .collection("students")
            .doc(email.text.trim())
            .set({
          "email": email.text.trim(),
          "firstName": "",
          "lastName": "",
          "branch": "",
          "year": "",
          "attendance": 0,
        });
      }

      /// 🔥 FACULTY REQUEST
      if (role == "Faculty") {
        await FirebaseFirestore.instance
            .collection("faculty_requests")
            .doc(email.text.trim())
            .set({
          "email": email.text.trim(),
          "status": "Pending",
          "timestamp": Timestamp.now(),
        });
      }

      showMsg("Registration Successful");
      Navigator.pop(context);

    } catch (e) {
      showMsg("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
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

                  const Icon(Icons.person_add, size: 60, color: Colors.green),

                  const SizedBox(height: 10),

                  const Text("Create Account",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: const InputDecoration(labelText: "Select Role"),
                    items: ["Student", "Faculty"]
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
                    onPressed: register,
                    child: const Text("Register"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}