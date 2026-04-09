import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentFacultyAvailabilityPage extends StatefulWidget {
  const StudentFacultyAvailabilityPage({Key? key}) : super(key: key);

  @override
  State<StudentFacultyAvailabilityPage> createState() =>
      _StudentFacultyAvailabilityPageState();
}

class _StudentFacultyAvailabilityPageState
    extends State<StudentFacultyAvailabilityPage> {

  String search = "";

  /// SHORT DAY FORMAT (MATCH FACULTY PAGE)
  final String today =
  ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
  [DateTime.now().weekday % 7];

  int parseTime(String time) {
    final parts = time.split(":");
    int h = int.parse(parts[0]);
    int m = int.parse(parts[1]);
    return h * 60 + m;
  }

  String formatTime(int minutes) {
    int h = minutes ~/ 60;
    int m = minutes % 60;
    return "${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}";
  }

  String getFacultyStatus(Map<String, dynamic> timetable) {

    final now = TimeOfDay.now();
    int current = now.hour * 60 + now.minute;

    Map<String, dynamic> todaySlots =
    Map<String, dynamic>.from(timetable[today] ?? {});

    String? nextClass;
    int? nextStart;

    for (var entry in todaySlots.entries) {

      String slot = entry.key;
      String subject = entry.value.toString();

      if (!slot.contains("-")) continue;

      final times = slot.split("-");

      int start = parseTime(times[0]);
      int end = parseTime(times[1]);

      if (current >= start && current <= end) {

        subject = subject.toLowerCase();

        if (subject.contains("break")) {
          return "🟢 Available now (Break)";
        }

        if (subject.contains("lunch")) {
          return "🟡 Lunch break";
        }

        if (subject.contains("free")) {
          return "🟢 Available now";
        }

        return "🔴 In class: $subject\nFree at ${formatTime(end)}";
      }

      if (start > current && nextStart == null) {
        nextStart = start;
        nextClass = subject;
      }
    }

    if (nextClass != null) {
      return "🟢 Available now\nNext class: $nextClass";
    }

    return "🟢 Free for the rest of the day";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Faculty Availability"),
      ),

      body: Column(

        children: [

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(

              decoration: InputDecoration(
                hintText: "Search faculty...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),

              onChanged: (val){
                setState(() {
                  search = val.toLowerCase();
                });
              },

            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("faculty_timetable")
                  .snapshots(),

              builder: (context, snapshot){

                if(!snapshot.hasData){
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc){

                  final name =
                  (doc["facultyName"] ?? "").toString().toLowerCase();

                  return name.contains(search);

                }).toList();

                if(docs.isEmpty){
                  return const Center(child: Text("No faculty found"));
                }

                return ListView(

                  padding: const EdgeInsets.all(10),

                  children: docs.map((doc){

                    Map<String, dynamic> timetable = {};

                    final data = doc["timetable"];

                    if(data is Map){
                      timetable = Map<String, dynamic>.from(data);
                    }

                    String status = getFacultyStatus(timetable);

                    return Card(

                      elevation: 5,

                      child: ListTile(

                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade200,
                          child: const Icon(Icons.person),
                        ),

                        title: Text(
                          doc["facultyName"] ?? "Faculty",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        subtitle: Text(status),

                      ),
                    );

                  }).toList(),

                );
              },
            ),
          )

        ],
      ),
    );
  }
}