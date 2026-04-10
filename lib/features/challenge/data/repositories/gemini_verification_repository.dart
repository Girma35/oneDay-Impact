import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:one_day/core/config/app_config.dart';
import 'package:one_day/features/challenge/domain/repositories/verification_repository.dart';

class GeminiVerificationRepository implements VerificationRepository {
  // Build a model for a given API key
  GenerativeModel _buildModel(String apiKey) => GenerativeModel(
        model: AppConfig.geminiModel,
        apiKey: apiKey,
      );

  @override
  Future<bool> verifyChallengeCompletion({
    required String challengeDescription,
    required File image,
  }) async {
    final primaryKey = AppConfig.geminiApiKey;
    final fallbackKey = AppConfig.geminiApiKey2;

    if (primaryKey.isEmpty) {
      print('DEBUG: Gemini API Key is empty!');
      throw Exception(
        'Gemini API key is not configured. '
        'Run the app with: flutter run --dart-define=GEMINI_API_KEY=<your_key>',
      );
    }

    print('DEBUG: Starting verification for challenge: $challengeDescription');
    final bytes = await image.readAsBytes();

    final prompt = [
      Content.multi([
        TextPart(
          'You are a community challenge verification assistant. '
          'The user is supposed to complete this challenge: "$challengeDescription". '
          'Look at the attached image. Does it provide clear evidence that '
          'the user has completed this challenge? '
          'Answer with only one word: "YES" or "NO".',
        ),
        DataPart('image/jpeg', bytes),
      ])
    ];

    // Try primary key first, fall back to secondary on quota / server errors
    final keysToTry = [
      primaryKey,
      if (fallbackKey.isNotEmpty) fallbackKey,
    ];

    Exception? lastError;
    for (int i = 0; i < keysToTry.length; i++) {
      final key = keysToTry[i];
      print('DEBUG: Attempting verification with key index $i');
      try {
        final model = _buildModel(key);
        final response = await model.generateContent(prompt);
        final text = response.text?.trim().toUpperCase() ?? '';
        print('DEBUG: Gemini response: $text');
        return text == 'YES';
      } on GenerativeAIException catch (e) {
        print('DEBUG: GenerativeAIException (attempt $i): ${e.message}');
        // 429 = quota exceeded — try next key
        if (e.message.contains('429') || e.message.contains('quota')) {
          lastError = e;
          continue;
        }
        // Other API errors — surface them
        rethrow;
      } catch (e) {
        print('DEBUG: Unexpected error (attempt $i): $e');
        lastError = Exception(e.toString());
        continue;
      }
    }

    throw lastError ??
        Exception('All Gemini API keys failed. Please check your quota.');
  }
}
