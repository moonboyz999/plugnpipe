import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey =
      'AIzaSyCaU9Yk-q7UpsPCausSemdZ-9M-NIEXuIw'; // Your Gemini API key
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> getChatResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''You are a helpful customer support AI for VSQ Student Services. 
You help students with:
- Providing troubleshooting tips and easy fixes BEFORE suggesting bookings
- Booking repair services (fridge, washing machine, plumber, electrical) only when needed
- Checking booking status and service information
- General inquiries about campus services
- Emergency contact information

TROUBLESHOOTING GUIDE - Try these first:

FRIDGE ISSUES:
- Not cooling: Check power connection, ensure door seals properly, clean coils
- Strange noises: Level the fridge, check if items are blocking fans
- Water leaking: Check drain pan, ensure door closes properly
- Ice buildup: Defrost manually, check door seals

WASHING MACHINE:
- Won't start: Check power, water supply, door is fully closed
- Not draining: Clean lint filter, check drain hose for clogs
- Vibrating: Level the machine, distribute clothes evenly
- Not spinning: Check load balance, ensure drain is clear

PLUMBING:
- Low water pressure: Clean faucet aerator, check if other taps affected
- Clogged drain: Try hot water flush, use plunger for toilets
- Running toilet: Check flapper seal, adjust chain length
- Slow drain: Remove hair/debris, try baking soda + vinegar

ELECTRICAL:
- Outlet not working: Check circuit breaker, test GFCI reset button
- Light flickering: Tighten bulb, check if overloaded circuit
- Fan not working: Check wall switch, clean dust from blades

Key Information:
- Emergency hotline: +60 12-345-6789 (for serious issues only)
- Operating hours: 24/7 for emergencies, 9AM-6PM for regular services
- Service areas: Menara VSQ and VSQ buildings
- Email support: support@vsq.edu.my

IMPORTANT: Always suggest simple fixes first. Only recommend booking if:
1. Safety risk (electrical sparks, gas leak, flooding)
2. Student tried basic troubleshooting
3. Problem persists after simple fixes

Keep responses helpful, friendly, and start with "Let's try some quick fixes first!"

Student question: $message''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 400,
            'topP': 0.8,
            'topK': 10,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'].trim();
        } else {
          return 'I\'m having trouble understanding. Could you please rephrase your question?';
        }
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        return 'I\'m experiencing technical difficulties. Please contact support@vsq.edu.my for assistance.';
      }
    } catch (e) {
      print('Gemini Service Error: $e');
      return 'Connection error. Please check your internet and try again, or email support@vsq.edu.my';
    }
  }

  // Test function to verify API connection
  static Future<bool> testConnection() async {
    try {
      final testResponse = await getChatResponse('Hello, test connection');
      return testResponse.isNotEmpty && !testResponse.contains('error');
    } catch (e) {
      return false;
    }
  }

  // Get suggested quick replies for common questions
  static List<String> getQuickReplies() {
    return [
      'How do I book a repair service?',
      'What are your operating hours?',
      'How can I check my booking status?',
      'Do you provide emergency services?',
      'What areas do you service?',
    ];
  }
}
