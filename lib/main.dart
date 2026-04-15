import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:one_day/app.dart';
import 'package:one_day/core/di/di.dart';
import 'package:one_day/core/utils/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: 'YOUR_SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: 'YOUR_SUPABASE_ANON_KEY'),
  );
  
  // Wire up dependency injection
  setupDependencies();
  
  // Fetch user's real location (non-blocking)
  getIt<LocationService>().fetchCurrentLocation();
  
  runApp(const OneDayApp());
}
