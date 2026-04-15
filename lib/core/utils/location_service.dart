import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Provides the user's real location via GPS + reverse geocoding.
///
/// Usage: `getIt<LocationService>().currentCityName` – returns the city
/// name (e.g. "Bishoftu") or a fallback if location is unavailable.
class LocationService extends ChangeNotifier {
  String _cityName = '';
  String _countryName = '';
  bool _isLoading = true;

  String get cityName => _cityName.isNotEmpty ? _cityName : 'Your Area';
  String get countryName => _countryName;
  bool get isLoading => _isLoading;

  /// Fetches the user's current position and reverse-geocodes it.
  /// Call once at app start (after Supabase init).
  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Check & request permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          debugPrint('Location permission denied');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // 2. Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // 3. Reverse geocode to get city name
      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('LocationService error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _cityName = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea ?? '';
        _countryName = p.country ?? '';
        debugPrint('Location resolved: $_cityName, $_countryName');
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
  }
}
