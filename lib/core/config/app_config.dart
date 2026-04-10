import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide configuration constants.
///
/// Values are loaded from the project's .env file via flutter_dotenv.
class AppConfig {
  AppConfig._();

  /// Primary Gemini API key
  static String get geminiApiKey => dotenv.get('GEMINI_API_KEY', fallback: '');

  /// Fallback key used when the primary hits a quota / 429 error
  static String get geminiApiKey2 => dotenv.get('GEMINI_API_KEY_2', fallback: '');

  /// The Gemini model to use for verification
  static const String geminiModel = 'gemini-2.5-flash';
}
