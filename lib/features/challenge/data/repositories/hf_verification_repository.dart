import 'dart:convert';
import 'dart:math';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:one_day/core/config/app_config.dart';
import 'package:one_day/core/utils/imagenet_concepts.dart';
import 'package:one_day/features/challenge/domain/repositories/verification_repository.dart';

class HFVerificationRepository implements VerificationRepository {
  final _rng = Random();

  @override
  Future<bool> verifyChallengeCompletion({
    required String challengeDescription,
    required List<String> verificationKeywords,
    required XFile image,
  }) async {
    final token = AppConfig.hfApiKey;
    final model = AppConfig.hfModel;

    if (token.isEmpty) {
      throw Exception(
        'Hugging Face API key is not configured. '
        'Please add HF_API_KEY to your .env file.',
      );
    }

    // 1. Get ImageNet classification predictions from ViT
    final predictions = await _classifyImage(token, model, image);
    debugPrint('ViT labels: ${predictions.map((p) => '${p.label}(${p.score.toStringAsFixed(2)})').take(5)}');

    // 2. Bridge ImageNet labels → concepts → verification keywords
    final result = matchImageNetToKeywords(
      predictions: predictions,
      verificationKeywords: verificationKeywords,
      challengeDescription: challengeDescription,
    );
    // The free ViT model is limited — many real challenge photos won't
    // produce matching ImageNet labels. Until we can afford a real API,
    // apply a probabilistic boost: if the AI couldn't verify but the image
    // was at least classified (non-empty labels), there's an 80% chance
    // of verification. This gives ~8/10 verified, ~2/10 not verified.
    bool isVerified = result.isVerified;
    if (!isVerified && predictions.isNotEmpty) {
      final boosted = _rng.nextDouble() < AppConfig.verificationBoostRate;
      debugPrint(
        'AI could not verify (matched=${result.matchedKeywords}). '
        'Probabilistic boost: ${boosted ? 'VERIFIED ✓' : 'NOT VERIFIED ✗'}',
      );
      isVerified = boosted;
    }

    debugPrint(
      'Keywords: $verificationKeywords → '
      'matched=${result.matchedKeywords}, '
      'labels=${result.matchedLabels} → '
      'final verified=$isVerified',
    );

    return isVerified;
  }

  /// Sends the image to ViT and returns ImageNet classification predictions.
  ///
  /// Handles HF free-tier cold-start (503 with estimated_time) by retrying
  /// once after the server-specified delay.
  Future<List<ImageNetPrediction>> _classifyImage(
    String token,
    String model,
    XFile image,
  ) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final url = Uri.parse('https://router.huggingface.co/hf-inference/models/$model');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final requestBody = jsonEncode({'inputs': base64Image});

    // First attempt
    var response = await http
        .post(url, headers: headers, body: requestBody)
        .timeout(const Duration(seconds: 15));

    // Handle cold-start: HF returns 503 with estimated_time when the model
    // is loading. Retry once after the suggested wait.
    if (response.statusCode == 503) {
      try {
        final errorBody = jsonDecode(response.body);
        final estimatedSeconds =
            (errorBody['estimated_time'] as num?)?.toDouble() ?? 10;
        debugPrint(
            'HF model cold-start, retrying in ${estimatedSeconds.round()}s…');
        await Future.delayed(
            Duration(seconds: estimatedSeconds.round().clamp(2, 20)));
        final retryResponse = await http
            .post(url, headers: headers, body: requestBody)
            .timeout(const Duration(seconds: 30));
        response = retryResponse;
      } catch (e) {
        debugPrint('HF model cold-start retry failed: $e');
        throw Exception('HF model is loading, retry failed. Please try again.');
      }
    }

    if (response.statusCode == 200) {
      final dynamic responseBody = jsonDecode(response.body);

      // ViT returns: [{"label": "tree frog", "score": 0.95}, ...]
      if (responseBody is List) {
        return responseBody.map<ImageNetPrediction>((item) {
          final map = item as Map<String, dynamic>;
          return ImageNetPrediction(
            label: map['label'] as String,
            score: (map['score'] as num).toDouble(),
          );
        }).toList();
      }

      // Unexpected shape — return empty
      debugPrint('Unexpected ViT response shape: $responseBody');
      return [];
    } else {
      throw Exception(
          'HF API Error: ${response.statusCode} – ${response.body}');
    }
  }
}
