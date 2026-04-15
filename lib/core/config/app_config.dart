import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide configuration constants.
///
/// Values are loaded from the project's .env file via flutter_dotenv.
class AppConfig {
  AppConfig._();

  /// Hugging Face API key
  static String get hfApiKey => dotenv.get('HF_API_KEY', fallback: '');

  /// Probability that a challenge is verified when the AI can't confirm it.
  /// Set to 0.8 (80%) since the free HF ViT model is limited — real photos
  /// often don't produce matching ImageNet labels. Set to 0.0 when using
  /// a real API that can reliably caption images.
  static const double verificationBoostRate = 0.8;

  /// The Hugging Face model to use for image verification.
  /// ViT (google/vit-base-patch16-224) is the only image model currently
  /// supported on the free HF Inference API serverless endpoint.
  /// It returns ImageNet classification labels which we bridge to
  /// verification keywords via the concept mapping in imagenet_concepts.dart.
  static const String hfModel = 'google/vit-base-patch16-224';
}
