import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:one_day/core/config/app_config.dart';
import 'package:one_day/features/challenge/domain/repositories/verification_repository.dart';

class HFVerificationRepository implements VerificationRepository {
  @override
  Future<bool> verifyChallengeCompletion({
    required String challengeDescription,
    required File image,
  }) async {
    final token = AppConfig.hfApiKey;
    final model = AppConfig.hfModel;

    if (token.isEmpty) {
      print('DEBUG: Hugging Face API Key is empty!');
      throw Exception(
        'Hugging Face API key is not configured. '
        'Please add HF_API_KEY to your .env file.',
      );
    }

    print('DEBUG: Starting HF verification for challenge: $challengeDescription');
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final response = await http.post(
        Uri.parse('https://router.huggingface.co/hf-inference/models/$model'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        print('DEBUG: HF response: $results');
        
        // ViT returns [{"label": "...", "score": 0.9}]
        // We check if any of the labels conceptually match the challenge description
        final descriptionWords = challengeDescription.toLowerCase().split(' ');
        
        for (var result in results) {
          final String label = result['label'].toString().toLowerCase();
          for (var word in descriptionWords) {
            if (word.length > 3 && label.contains(word)) {
              return true; // Found a matching keyword in the AI's image labels!
            }
          }
        }
        return false;
      } else {
        print('DEBUG: HF API error: ${response.statusCode} - ${response.body}');
        throw Exception('HF API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Unexpected HF error: $e');
      throw Exception(e.toString());
    }
  }
}
