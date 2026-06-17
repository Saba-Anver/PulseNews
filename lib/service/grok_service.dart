import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getDailyBriefing(
  List<String> titles,
  List<String> descriptions,
) async {
  try {
    final stories = List.generate(
      titles.length,
      (i) => "${titles[i]}: ${descriptions[i]}",
    );
    final prompt =
        """Write a daily news briefing based on these top stories. Format it with a short heading for each point followed by one sentence. Keep it concise and neutral. No introduction, no sign-off, just the briefing points.

Today's stories:
${stories.join('\n')}

Daily Briefing:""";
    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${dotenv.env['GROQ_API_KEY'] ?? ''}",
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {"role": "user", "content": prompt},
        ],
      }),
    );
    print("GROQ RESPONSE: ${response.body}");
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } catch (e) {
    print("GROQ ERROR: $e");
    return "Failed to load briefing.";
  }
}

Future<String> getArticleSummary(String title, String description) async {
  try {
    final prompt =
        "Based on this news headline and description, write a concise 3-4 sentence summary of what this story is likely about:\n\nTitle: $title\nDescription: $description";

    final response = await http.post(
      Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${dotenv.env['GROQ_API_KEY'] ?? ''}",
      },
      body: jsonEncode({
        "model": "llama-3.1-8b-instant",
        "messages": [
          {"role": "user", "content": prompt},
        ],
      }),
    );
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } catch (e) {
    print("GROQ ERROR: $e");
    return "Failed to load summary.";
  }
}
