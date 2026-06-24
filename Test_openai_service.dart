import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String _apiKey = 'GEMINI_API_KEY'; // keep your real key

  Future<Map<String, dynamic>> categorize(String text) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Categorize this text into exactly one of: task, idea, worry, reminder. Also suggest one short action. Respond ONLY with valid JSON like this: {"category": "task", "suggested_action": "Schedule a time to do this"}. No extra text, no markdown. Text: $text'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 100,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['candidates'][0]['content']['parts'][0]['text'] as String;
        final clean =
            content.replaceAll('```json', '').replaceAll('```', '').trim();
        return jsonDecode(clean);
      } else {
        print('Gemini error: ${response.statusCode} ${response.body}');
        return {'category': 'uncategorized', 'suggested_action': ''};
      }
    } catch (e) {
      print('Categorize error: $e');
      return {'category': 'uncategorized', 'suggested_action': ''};
    }
  }
}
