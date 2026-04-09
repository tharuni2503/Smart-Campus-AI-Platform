import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {

  static Future<String> askAI(String prompt) async {

    final apiKey = dotenv.env['GROQ_API_KEY'];

    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey"
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {
            "role": "system",
            "content": "You are an AI assistant helping students learn."
          },
          {
            "role": "user",
            "content": prompt
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["choices"][0]["message"]["content"];
    } else {
      return "Error: ${data["error"]["message"]}";
    }
  }
}