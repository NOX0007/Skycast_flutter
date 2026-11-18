import 'package:geolocator/geolocator.dart';

/// Custom exception for readable GPS permission & availability errors.
class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

/// Handles checking location services, requesting runtime permissions,
/// and retrieving current GPS coordinates with Geolocator.
class LocationService {
  Future<Position> getCurrentPosition() async {
    // 1. Ensure device GPS/location services are turned on
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please enable GPS in your device settings or search for a city manually.',
      );
    }

    // 2. Check and request runtime permission cleanly
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permission was denied. You can still search any city using the search bar.',
        );
      }
    }

    // 3. Handle permanently denied permissions gracefully
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied. Please enable it from App Settings to use GPS weather.',
      );
    }

    // 4. Fetch current coordinates
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 12),
    );
  }
}
