import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String baseUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent';
  // Temporary mock quotes for testing
  static final List<String> _mockQuotes = [
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "The only way to do great work is to love what you do.",
    "Believe you can and you're halfway there.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "Everything you've ever wanted is on the other side of fear."
  ];

  static Future<String> fetchQuote(String query) async {
    try {
      // Test with actual API call
      final client = http.Client();
      try {
        print('Starting API request...');
        final Uri uri = Uri.parse('$baseUrl?key=$apiKey');
        
        final request = http.Request('POST', uri);
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode({
          "contents": [{
            "parts": [{
              "text": "Create an inspiring quote about $query. Keep it short and meaningful."
            }]
          }]
        });

        print('Sending request...');
        final streamedResponse = await client.send(request).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('Request timed out after 30 seconds');
            throw TimeoutException('Request timed out');
          },
        );

        final response = await http.Response.fromStream(streamedResponse);
        
        print('Response received:');
        print('Status code: ${response.statusCode}');
        print('Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data != null && 
              data["candidates"] != null && 
              data["candidates"].isNotEmpty &&
              data["candidates"][0]["content"] != null &&
              data["candidates"][0]["content"]["parts"] != null &&
              data["candidates"][0]["content"]["parts"].isNotEmpty) {
            String quote = data["candidates"][0]["content"]["parts"][0]["text"].toString().trim();
            if (quote.isEmpty) {
              return "Could not generate a quote. Please try again.";
            }
            return quote;
          }
        }
        // Fallback to mock quote if API fails
        print('API call failed, using mock quote');
        final random = Random();
        return _mockQuotes[random.nextInt(_mockQuotes.length)];
      } finally {
        client.close();
      }
    } catch (e) {
      print("Error: $e");
      // Fallback to mock quote on error
      final random = Random();
      return _mockQuotes[random.nextInt(_mockQuotes.length)];
    }
  }
}
