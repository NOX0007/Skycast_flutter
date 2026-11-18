import 'package:shared_preferences/shared_preferences.dart';

/// Persists user preferences locally using SharedPreferences:
/// - Last searched city
/// - Recent city search history
/// - Temperature unit preference (Celsius vs Fahrenheit)
class PreferencesService {
  static const String _lastCityKey = 'skycast_last_city';
  static const String _recentCitiesKey = 'skycast_recent_cities';
  static const String _useFahrenheitKey = 'skycast_use_fahrenheit';

  static const String defaultCity = 'New Delhi';

  Future<String> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityKey) ?? defaultCity;
  }

  Future<void> saveLastCity(String city) async {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityKey, cleanCity);

    // Maintain a deduplicated list of up to 6 recent cities
    final existing = prefs.getStringList(_recentCitiesKey) ?? [];
    final updated = [
      cleanCity,
      ...existing.where((c) => c.toLowerCase() != cleanCity.toLowerCase()),
    ].take(6).toList();

    await prefs.setStringList(_recentCitiesKey, updated);
  }

  Future<List<String>> getRecentCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentCitiesKey) ?? [];
  }

  Future<void> clearRecentCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentCitiesKey);
  }

  Future<bool> getUseFahrenheit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useFahrenheitKey) ?? false;
  }

  Future<void> setUseFahrenheit(bool useFahrenheit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useFahrenheitKey, useFahrenheit);
  }
}
