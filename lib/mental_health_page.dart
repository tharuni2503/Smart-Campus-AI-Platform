import 'package:flutter/material.dart';
import 'dart:math';

class MentalHealthPage extends StatefulWidget {
  const MentalHealthPage({Key? key}) : super(key: key);

  @override
  State<MentalHealthPage> createState() => _MentalHealthPageState();
}

class _MentalHealthPageState extends State<MentalHealthPage> {

  String moodMessage = "How are you feeling today?";
  String currentMood = "";
  Color moodColor = Colors.blue.shade50;

  List<String> moodHistory = [];

  final List<String> tips = [
    "Close your eyes and take 5 deep breaths.",
    "Go for a short walk and get fresh air.",
    "Listen to your favorite song.",
    "Drink water and relax for a moment.",
    "Talk to someone you trust."
  ];

  final List<String> quotes = [
    "You are stronger than you think 💪",
    "This too shall pass 🌈",
    "Small steps matter ❤️",
    "Take it one day at a time 🌿",
    "You deserve peace 🕊️"
  ];

  /// 🎯 SELECT MOOD
  void selectMood(String mood) {

    currentMood = mood;
    moodHistory.add(mood);

    if (mood == "happy") {
      moodMessage = "😊 Great! Keep going and stay positive.";
      moodColor = Colors.green.shade100;
    }

    if (mood == "neutral") {
      moodMessage = "🙂 Try taking a short break or relaxing.";
      moodColor = Colors.yellow.shade100;
    }

    if (mood == "sad") {
      moodMessage = "💙 It's okay to feel sad. You are not alone.";
      moodColor = Colors.blue.shade100;
    }

    if (mood == "stress") {
      moodMessage = "😌 Relax. Take a deep breath and slow down.";
      moodColor = Colors.orange.shade100;
    }

    setState(() {});
  }

  /// 🎯 RANDOM TIP
  void showTip() {
    String tip = tips[Random().nextInt(tips.length)];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Relaxation Tip"),
        content: Text(tip),
      ),
    );
  }

  /// 🎯 RANDOM QUOTE
  String getQuote() {
    return quotes[Random().nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Mental Health Support"),
        centerTitle: true,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 10),

            /// 🔥 TITLE
            const Text(
              "Daily Mood Check",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 😊 MOOD BUTTONS
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    moodButton("😄", "happy"),
                    moodButton("😐", "neutral"),
                    moodButton("😞", "sad"),
                    moodButton("😣", "stress"),

                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// 💬 MESSAGE BOX
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: moodColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    moodMessage,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getQuote(),
                    style: const TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// 📊 MOOD HISTORY
            if (moodHistory.isNotEmpty)
              Column(
                children: [
                  const Text(
                    "Mood History",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: moodHistory.map((m) {
                      return Chip(label: Text(m));
                    }).toList(),
                  ),
                ],
              ),

            const Spacer(),

            /// 🧘 TIP BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.self_improvement),
              label: const Text("Relaxation Tip"),
              onPressed: showTip,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 15),

            /// 📞 COUNSELOR BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.support_agent),
              label: const Text("Contact Counselor"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text("Counselor Support"),
                    content: Text(
                      "Campus Counselor:\n\n"
                          "Email: counselor@campus.edu\n"
                          "Phone: +91-9876543210",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// 🔥 MOOD BUTTON WIDGET
  Widget moodButton(String emoji, String mood) {
    return IconButton(
      icon: Text(
        emoji,
        style: const TextStyle(fontSize: 32),
      ),
      onPressed: () => selectMood(mood),
    );
  }
}