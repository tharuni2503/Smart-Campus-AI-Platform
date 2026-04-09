import 'package:flutter/material.dart';
import 'groq_service.dart';

class CareerPage extends StatefulWidget {
  const CareerPage({Key? key}) : super(key: key);

  @override
  State<CareerPage> createState() => _CareerPageState();
}

class _CareerPageState extends State<CareerPage> {

  final TextEditingController skillCtrl = TextEditingController();

  String result = "";
  bool loading = false;

  Future<void> generateAdvice() async {

    String skills = skillCtrl.text.trim();

    if(skills.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your skills")),
      );
      return;
    }

    setState(() {
      loading = true;
      result = "";
    });

    String prompt = """
You are an AI Career & Placement Assistant for university students.

Analyze the student's skills and suggest a career development plan in short.

Student Skills:
$skills

Provide the response in this format:

Career Paths
• ...

Skills To Improve
• ...

Internship Opportunities
• ...

Project Ideas
• ...

Recommended Certifications
• ...

Resume Improvement Tips
• ...

Mock Interview Questions
• ...   

Rules:
- Return ONLY titles
- No explanation
- One role per line

Example output:

Data Analyst
Data Scientist
Machine Learning Engineer
Backend Developer
AI Engineer
""";

    String reply = await GroqService.askAI(prompt);

    setState(() {
      result = reply;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        title: const Text("Career & Placement Assistant"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: skillCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Enter your skills (Python, AI, Flutter, Data Science...)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height:20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: generateAdvice,
                child: const Text("Generate Career Plan"),
              ),
            ),

            const SizedBox(height:20),

            if(loading)
              const CircularProgressIndicator(),

            const SizedBox(height:10),

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    result,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}