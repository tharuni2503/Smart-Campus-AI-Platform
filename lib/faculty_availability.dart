import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyAvailabilityPage extends StatefulWidget {
  const FacultyAvailabilityPage({Key? key}) : super(key: key);

  @override
  State<FacultyAvailabilityPage> createState() => _FacultyAvailabilityPageState();
}

class _FacultyAvailabilityPageState extends State<FacultyAvailabilityPage> {

  late String email;
  String facultyName = "";

  Map<String, Map<String, String>> timetable = {};

  final days = ["Mon","Tue","Wed","Thu","Fri","Sat"];

  final slots = [
    "9:15-10:10",
    "10:10-11:00",
    "Break",
    "11:15-12:05",
    "12:05-12:55",
    "Lunch",
    "1:40-2:30",
    "2:30-3:20",
    "3:20-4:10"
  ];

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser!;
    email = user.email!;
    facultyName = email.split("@")[0];

    loadTimetable();
  }

  Future<void> loadTimetable() async {

    final doc = await FirebaseFirestore.instance
        .collection("faculty_timetable")
        .doc(email)
        .get();

    if (doc.exists) {

      final data = doc.data();

      if (data != null && data["timetable"] is Map) {

        timetable = {};

        (data["timetable"] as Map).forEach((day, value) {

          timetable[day] =
          Map<String, String>.from(value);

        });

        setState(() {});
      }
    }
  }

  Future<void> saveTimetable() async {

    await FirebaseFirestore.instance
        .collection("faculty_timetable")
        .doc(email)
        .set({

      "facultyName": facultyName,
      "facultyEmail": email,
      "timetable": timetable,
      "timestamp": Timestamp.now()

    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Timetable Updated")));
  }

  Color getColor(String value) {

    value = value.toLowerCase();

    if (value.contains("break")) return Colors.orange.shade200;
    if (value.contains("lunch")) return Colors.yellow.shade300;
    if (value.contains("free")) return Colors.green.shade200;

    return Colors.blue.shade200;
  }

  Widget buildTable() {

    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,

      child: DataTable(

        columnSpacing: 8,
        headingRowHeight: 35,
        dataRowHeight: 40,

        columns: [
          const DataColumn(label: Text("Day")),
          ...slots.map((s) => DataColumn(
              label: Text(s, style: const TextStyle(fontSize: 11))))
        ],

        rows: days.map((day) {

          return DataRow(

            cells: [

              DataCell(Text(day)),

              ...slots.map((slot) {

                String value;

                if (slot == "Break") {
                  value = "Break";
                } else if (slot == "Lunch") {
                  value = "Lunch";
                } else {
                  value = timetable[day]?[slot] ?? "Free";
                }

                bool fixed = slot == "Break" || slot == "Lunch";

                return DataCell(

                  GestureDetector(

                    onTap: fixed
                        ? null
                        : () async {

                      TextEditingController ctrl =
                      TextEditingController(text: value);

                      await showDialog(

                        context: context,

                        builder: (_) => AlertDialog(

                          title: Text("$day  $slot"),

                          content: TextField(
                            controller: ctrl,
                            decoration: const InputDecoration(
                                labelText: "Subject"),
                          ),

                          actions: [

                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(context),
                                child: const Text("Cancel")),

                            ElevatedButton(

                                onPressed: () {

                                  setState(() {

                                    timetable.putIfAbsent(day, () => {});

                                    timetable[day]![slot] =
                                        ctrl.text;

                                  });

                                  Navigator.pop(context);
                                },

                                child: const Text("Save"))

                          ],
                        ),
                      );
                    },

                    child: Container(

                      alignment: Alignment.center,
                      width: 70,

                      padding: const EdgeInsets.all(4),

                      decoration: BoxDecoration(
                        color: getColor(value),
                        borderRadius: BorderRadius.circular(5),
                      ),

                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),

                    ),
                  ),

                );

              }).toList()

            ],

          );

        }).toList(),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Faculty Timetable"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(12),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Text(
              "Faculty: $facultyName",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Expanded(child: buildTable()),

            const SizedBox(height: 10),

            Center(
              child: ElevatedButton(
                onPressed: saveTimetable,
                child: const Text("Update Timetable"),
              ),
            )
          ],
        ),
      ),
    );
  }
}