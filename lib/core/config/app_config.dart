import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide configuration constants.
///
/// Values are loaded from the project's .env file via flutter_dotenv.
class AppConfig {
  AppConfig._();

  /// Hugging Face API key
  static String get hfApiKey => dotenv.get('HF_API_KEY', fallback: '');

  /// The Hugging Face model to use for verification
  static const String hfModel = 'google/vit-base-patch16-224';  // Confirmed ACTIVE on Free Tier
}
