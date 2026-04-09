import 'package:flutter/material.dart';
import 'dart:async';
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  String getTimeBasedSuggestion() {
    final hour = DateTime.now().hour;

    if (hour >= 7 && hour < 11) {
      return "🌅 Good Morning! Start your day at Library 📚";
    }
    else if (hour >= 11 && hour < 15) {
      return "🍔 Lunch Time! Cafeteria is best now";
    }
    else if (hour >= 15 && hour < 18) {
      return "🏫 Afternoon! Check labs or classes";
    }
    else if (hour >= 18 && hour < 21) {
      return "🏃 Evening time! Visit Sports Ground";
    }
    else {
      return "🌙 Late hours! Navigate safely";
    }
  }

  int currentStep = 0;
  String selectedPlace = "";
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("🤖 Smart Suggestion"),
          content: Text(getTimeBasedSuggestion()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    });
  }
  /// 📍 ROUTES
  final Map<String, List<Map<String, String>>> campusRoutes = {

    "Cafeteria":[
      {"image":"assets/main_block.jpg","text":"Start from Main Block"},
      {"image":"assets/cafeteria_indoor_corner.jpg","text":"Turn LEFT and walk towards Cafeteria corner"},
      {"image":"assets/cafeteria_entrance.jpg","text":"You reached Cafeteria Entrance"},
    ],

    "Indoor Sports":[
      {"image":"assets/main_block.jpg","text":"Start from Main Block"},
      {"image":"assets/cafeteria_entrance.jpg","text":"Walk towards Cafeteria"},
      {"image":"assets/indoor_sport.jpg","text":"Indoor sports are on first floor"},
    ],

    "Central Library":[
      {"image":"assets/main_block.jpg","text":"Start from Main Block"},
      {"image":"assets/second_floor_corridor.jpg","text":"Take LEFT steps to second floor"},
      {"image":"assets/library_corridor.jpg","text":"Walk through Library corridor"},
      {"image":"assets/central_library.jpg","text":"Central Library entrance"},
      {"image":"assets/library_inside.jpg","text":"Inside Central Library"},
    ],

    "AIML HOD":[
      {"image":"assets/main_block.jpg","text":"Start from Main Block"},
      {"image":"assets/second_floor_corridor.jpg","text":"Take steps to third floor"},
      {"image":"assets/aiml_corridor.jpg","text":"Walk towards AIML corridor"},
      {"image":"assets/aiml_hod.jpg","text":"AIML HOD Office"},
      {"image":"assets/aiml_4th_year.jpg","text":"AIML 4th year classroom"},
    ],

    "AIML 4th year":[
      {"image":"assets/main_block.jpg","text":"Start from Main Block"},
      {"image":"assets/aiml_corridor.jpg","text":"Walk towards AIML corridor"},
      {"image":"assets/aiml_4th_year.jpg","text":"AIML 4th year classroom"},
    ],

    "Sports Ground":[
      {"image":"assets/cricket_ground.jpg","text":"From Main Gate go towards parking"},
      {"image":"assets/cricket_ground.jpg","text":"Cricket ground on LEFT"},
      {"image":"assets/football.jpg","text":"Football ground on RIGHT"},
    ],
  };

  /// 🎯 START NAVIGATION
  void startNavigation(String place) {
    setState(() {
      selectedPlace = place;
      currentStep = 0;
    });
  }

  /// 👉 NEXT STEP
  void nextStep() {
    if (currentStep < campusRoutes[selectedPlace]!.length - 1) {
      setState(() => currentStep++);
    }
  }

  /// 👈 PREVIOUS STEP
  void prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  /// 🤖 SMART TIP (AI-LIKE)
  String getSmartTip() {
    if (selectedPlace.isEmpty) return "";

    final hour = DateTime.now().hour;

    if (selectedPlace.contains("Library")) {
      return hour < 17
          ? "📚 Best time to study now"
          : "🌙 Library may close soon";
    }

    if (selectedPlace.contains("Cafeteria")) {
      return (hour >= 12 && hour <= 14)
          ? "🔥 Peak lunch time (crowded)"
          : "🍔 Good time to visit";
    }

    if (selectedPlace.contains("Sports")) {
      return hour >= 17
          ? "🏃 Perfect time for sports"
          : "☀️ Better in evening";
    }

    if (selectedPlace.contains("AIML")) {
      return "💻 Classes & labs active";
    }

    return "🚶 Follow the steps carefully";
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧭 Smart Navigation"),
        centerTitle: true,
      ),

      body: selectedPlace.isEmpty
          ? buildSelectionUI()
          : buildNavigationUI(),
    );
  }

  /// 🟢 PLACE SELECTION UI
  Widget buildSelectionUI() {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [

          /// 🤖 AI SUGGESTION (TOP)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    getTimeBasedSuggestion(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const Text(
            "Where do you want to go?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// 📍 BUTTONS
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: campusRoutes.keys.map((place) {

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => startNavigation(place),
                child: Text(place),
              );

            }).toList(),
          )
        ],
      ),
    );
  }
  /// 🔵 NAVIGATION UI
  Widget buildNavigationUI() {

    final steps = campusRoutes[selectedPlace]!;
    final step = steps[currentStep];

    return Column(
      children: [

        /// 📊 PROGRESS BAR
        LinearProgressIndicator(
          value: (currentStep + 1) / steps.length,
          minHeight: 6,
        ),

        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "Step ${currentStep + 1} of ${steps.length}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        /// 🖼 IMAGE
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),

            child: ClipRRect(
              key: ValueKey(step["image"]),
              borderRadius: BorderRadius.circular(20),

              child: Image.asset(
                step["image"]!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        /// 📝 TEXT
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

              Text(
                step["text"]!,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              Text(
                getSmartTip(),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        /// 🔘 CONTROLS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            ElevatedButton.icon(
              onPressed: prevStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back"),
            ),

            ElevatedButton.icon(
              onPressed: nextStep,
              icon: const Icon(Icons.arrow_forward),
              label: const Text("Next"),
            ),

          ],
        ),

        const SizedBox(height: 10),

        /// 🔙 EXIT BUTTON
        TextButton(
          onPressed: () {
            setState(() {
              selectedPlace = "";
              currentStep = 0;
            });
          },
          child: const Text("⬅ Back to Menu"),
        ),

        const SizedBox(height: 10),
      ],
    );
  }
}