import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

void main() async {
  final apiKey = 'AIzaSyA8H7xSFPGHdliH9dklD6y7JS38EwZJks8';
  final modelsToTest = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
    'gemini-1.0-pro',
  ];

  for (final modelName in modelsToTest) {
    print('\n--- Testing Model: $modelName ---');
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([Content.text('Hello')]);
      print('SUCCESS: $modelName works! Response: ${response.text?.substring(0, 20)}...');
    } catch (e) {
      print('FAILED: $modelName - $e');
    }
  }
}
