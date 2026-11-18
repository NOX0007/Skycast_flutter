/// OpenWeatherMap API Configuration for SkyCast.
///
/// HOW TO ADD YOUR API KEY:
/// 1. Sign up for a free account at https://openweathermap.org/api
/// 2. Go to "My API Keys" in your OpenWeatherMap dashboard and copy your key.
/// 3. Replace 'YOUR_OPENWEATHERMAP_API_KEY' below with your real key.
///    Example: static const String openWeatherApiKey = 'a1b2c3d4e5f6...';
///
/// NOTE: While the key remains 'YOUR_OPENWEATHERMAP_API_KEY' or empty,
/// SkyCast automatically runs in Demo Mode and clearly labels all readings
/// as "Demo Data".
class ApiConfig {
  ApiConfig._();

  static const String openWeatherApiKey = '70a61f5f63fb51b003092ab745178a05';

  static const String currentWeatherUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static const String fiveDayForecastUrl =
      'https://api.openweathermap.org/data/2.5/forecast';

  /// Returns true when the developer has supplied a real OpenWeatherMap key.
  static bool get hasValidApiKey {
    final trimmed = openWeatherApiKey.trim();
    return trimmed.isNotEmpty && trimmed != 'YOUR_OPENWEATHERMAP_API_KEY';
  }
}
