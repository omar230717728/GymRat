import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class VisionService {
  // 1. Configuration
  static const String _apiKey = "AIzaSyANIc4961Bak1LGYfFuJ5R_3GcJqzLWAiE";


  // 2. The Main Function
  static Future<String?> scanMachine(ImageSource source) async {
    try {
      // Step A: Pick & Compress
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 70,
      );

      if (image == null) return null; // Case: User cancelled

      // Step B: Gemini API Call
      final File imageFile = File(image.path);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final Uri url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey',
      );

      print('--- GEMINI DEBUG ---');
      print('Using Key: ${_apiKey.substring(0, 5)}...');
      print('Sending request to Gemini 2.0 Flash...');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [{
            "parts": [
              {"text": "Analyze this image. If it shows gym equipment, return EXACTLY one of the following short names.\n\nValid Names: Ab Crunch, Assisted Pullup, Barbell, Cable Biceps, Cable Crossover, Cable Oblique Twist, Cable Upright Row, Captains Chair, Chest Supported Row, Decline Bench, Decline Chest Press, Dip Assist, Dumbbells, Flat Chest Press, Glute Drive, Hack Squat, Hip Abductor, Hip Adductor, Hyperextension Bench, Incline Bench, Incline Chest Press, Kettlebell, Lat Pulldown, Lateral Raise, Leg Extension, Leg Press, Lying Leg Curl, Multi Press, Overhead Triceps, Pec Deck, Preacher Curl, Rear Delt Fly, Roman Chair, Seated Leg Curl, Seated Row, Shoulder Press, Smith, Standing Calf Raise, Straight Arm Pulldown, T Bar Row, Triceps Pushdown, Wrist Curl\n\nStrict Rule: If the image is NOT one of these, return exactly \"NO_MATCH\"."},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }]
        }),
      ).timeout(const Duration(seconds: 15));

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      // Step C: Safety & Parsing
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Extract Text from Gemini Response
        if (jsonResponse['candidates'] != null && 
            (jsonResponse['candidates'] as List).isNotEmpty) {
          
          final candidate = jsonResponse['candidates'][0];
          final parts = candidate['content']['parts'] as List;
          if (parts.isNotEmpty) {
             String text = parts[0]['text'] ?? '';
             
             // Clean the text
             text = text.trim();
             // Remove trailing period if present
             if (text.endsWith('.')) {
               text = text.substring(0, text.length - 1);
             }

             print('GEMINI VISION: $text');
             
             if (text == 'NO_MATCH') return null;

             // Return the clean name directly
             return text;
          }
        }
      } else {
        debugPrint('VisionService API Error: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      // Crash-Proof Error Handling
      print('CRITICAL ERROR: $e');
      return null;
    }
  }
}
