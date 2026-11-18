import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/weather_model.dart';

/// Custom exception for weather API failures (e.g., invalid city name, offline).
class WeatherApiException implements Exception {
  final String message;
  const WeatherApiException(this.message);

  @override
  String toString() => message;
}

/// Fetches live weather from OpenWeatherMap when an API key is configured,
/// or serves clearly labeled Demo Data when the key is missing.
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch current weather + forecast by city name.
  Future<WeatherBundle> fetchByCity(String city) async {
    final query = city.trim();
    if (query.isEmpty) {
      throw const WeatherApiException('Please enter a city name to search.');
    }

    if (!ApiConfig.hasValidApiKey) {
      return _buildDemoWeatherForCity(query);
    }

    final currentUri = Uri.parse(
      '${ApiConfig.currentWeatherUrl}?q=${Uri.encodeComponent(query)}&appid=${ApiConfig.openWeatherApiKey}&units=metric',
    );
    final forecastUri = Uri.parse(
      '${ApiConfig.fiveDayForecastUrl}?q=${Uri.encodeComponent(query)}&appid=${ApiConfig.openWeatherApiKey}&units=metric',
    );

    return _fetchFromOpenWeather(currentUri, forecastUri);
  }

  /// Fetch current weather + forecast by GPS latitude & longitude.
  Future<WeatherBundle> fetchByCoordinates(double lat, double lon) async {
    if (!ApiConfig.hasValidApiKey) {
      return _buildDemoWeatherForCity(
        'Current Location',
        notice:
            'OpenWeatherMap API key is not configured in lib/config/api_config.dart. Showing Demo Data for your GPS check.',
      );
    }

    final currentUri = Uri.parse(
      '${ApiConfig.currentWeatherUrl}?lat=$lat&lon=$lon&appid=${ApiConfig.openWeatherApiKey}&units=metric',
    );
    final forecastUri = Uri.parse(
      '${ApiConfig.fiveDayForecastUrl}?lat=$lat&lon=$lon&appid=${ApiConfig.openWeatherApiKey}&units=metric',
    );

    return _fetchFromOpenWeather(currentUri, forecastUri);
  }

  Future<WeatherBundle> _fetchFromOpenWeather(
    Uri currentUri,
    Uri forecastUri,
  ) async {
    try {
      final responses = await Future.wait([
        _client.get(currentUri).timeout(const Duration(seconds: 12)),
        _client.get(forecastUri).timeout(const Duration(seconds: 12)),
      ]);

      final currentRes = responses[0];
      final forecastRes = responses[1];

      if (currentRes.statusCode == 404) {
        throw const WeatherApiException(
          'City not found. Please check the spelling and try again.',
        );
      }
      if (currentRes.statusCode == 401) {
        throw const WeatherApiException(
          'Invalid OpenWeatherMap API key. Please verify lib/config/api_config.dart.',
        );
      }
      if (currentRes.statusCode != 200 || forecastRes.statusCode != 200) {
        throw WeatherApiException(
          'Weather service returned status ${currentRes.statusCode}. Please try again shortly.',
        );
      }

      final currentJson =
          jsonDecode(currentRes.body) as Map<String, dynamic>;
      final forecastJson =
          jsonDecode(forecastRes.body) as Map<String, dynamic>;

      final current = CurrentWeather.fromOpenWeatherJson(currentJson);
      final rawList = (forecastJson['list'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      // First 8 slots (3-hour steps) represent the upcoming 24 hours
      final hourly = rawList
          .take(8)
          .map(
            (item) => HourlyForecastItem.fromOpenWeatherJson(
              item,
              current.timezoneOffsetSeconds,
            ),
          )
          .toList();

      // Group forecast intervals by calendar date for daily min/max summary
      final daily = _aggregateDailyForecast(
        rawList,
        current.timezoneOffsetSeconds,
      );

      return WeatherBundle(
        current: current,
        hourly: hourly,
        daily: daily,
        isDemoData: false,
      );
    } on WeatherApiException {
      rethrow;
    } catch (_) {
      throw const WeatherApiException(
        'Unable to reach OpenWeatherMap. Check your internet connection and retry.',
      );
    }
  }

  List<DailyForecastItem> _aggregateDailyForecast(
    List<Map<String, dynamic>> rawList,
    int offsetSeconds,
  ) {
    final Map<String, List<HourlyForecastItem>> grouped = {};
    for (final entry in rawList) {
      final item =
          HourlyForecastItem.fromOpenWeatherJson(entry, offsetSeconds);
      final key =
          '${item.dateTime.year}-${item.dateTime.month.toString().padLeft(2, '0')}-${item.dateTime.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final List<DailyForecastItem> days = [];
    for (final entries in grouped.values) {
      double minT = entries.first.temperatureC;
      double maxT = entries.first.temperatureC;
      for (final e in entries) {
        if (e.temperatureC < minT) minT = e.temperatureC;
        if (e.temperatureC > maxT) maxT = e.temperatureC;
      }
      // Pick midday entry when available for representative condition & icon
      final representative = entries[entries.length ~/ 2];
      days.add(
        DailyForecastItem(
          date: entries.first.dateTime,
          condition: representative.condition,
          iconCode: representative.iconCode,
          minTempC: minT,
          maxTempC: maxT,
        ),
      );
    }

    return days.take(7).toList();
  }

  /// Provides realistic, clearly labeled Demo Data when API key is missing.
  WeatherBundle _buildDemoWeatherForCity(
    String city, {
    String? notice,
  }) {
    final normalized = city.trim().toLowerCase();

    // Sample catalog for popular cities in Demo Mode
    final Map<String, _DemoPreset> presets = {
      'new delhi': const _DemoPreset(
        name: 'New Delhi',
        country: 'IN',
        tempC: 27,
        feelsLikeC: 28,
        minC: 19,
        maxC: 30,
        condition: 'Clear',
        description: 'Clear Sky',
        icon: '01d',
        humidity: 42,
        windMs: 3.4,
        pressure: 1014,
        visibility: 9000,
        clouds: 8,
        uv: 6.2,
      ),
      'london': const _DemoPreset(
        name: 'London',
        country: 'GB',
        tempC: 13,
        feelsLikeC: 11,
        minC: 9,
        maxC: 15,
        condition: 'Rain',
        description: 'Light Rain',
        icon: '10d',
        humidity: 78,
        windMs: 5.8,
        pressure: 1006,
        visibility: 7500,
        clouds: 84,
        uv: 1.8,
      ),
      'tokyo': const _DemoPreset(
        name: 'Tokyo',
        country: 'JP',
        tempC: 18,
        feelsLikeC: 17,
        minC: 14,
        maxC: 21,
        condition: 'Clouds',
        description: 'Scattered Clouds',
        icon: '03d',
        humidity: 56,
        windMs: 4.1,
        pressure: 1018,
        visibility: 10000,
        clouds: 40,
        uv: 4.1,
      ),
      'new york': const _DemoPreset(
        name: 'New York',
        country: 'US',
        tempC: 16,
        feelsLikeC: 15,
        minC: 11,
        maxC: 19,
        condition: 'Clouds',
        description: 'Few Clouds',
        icon: '02d',
        humidity: 51,
        windMs: 4.9,
        pressure: 1016,
        visibility: 10000,
        clouds: 25,
        uv: 3.5,
      ),
      'mumbai': const _DemoPreset(
        name: 'Mumbai',
        country: 'IN',
        tempC: 31,
        feelsLikeC: 34,
        minC: 26,
        maxC: 33,
        condition: 'Clouds',
        description: 'Partly Cloudy',
        icon: '02d',
        humidity: 71,
        windMs: 4.6,
        pressure: 1010,
        visibility: 8500,
        clouds: 35,
        uv: 7.4,
      ),
      'current location': const _DemoPreset(
        name: 'Bengaluru',
        country: 'IN',
        tempC: 24,
        feelsLikeC: 24,
        minC: 18,
        maxC: 27,
        condition: 'Clouds',
        description: 'Pleasant Breeze',
        icon: '02d',
        humidity: 58,
        windMs: 3.9,
        pressure: 1015,
        visibility: 10000,
        clouds: 30,
        uv: 5.5,
      ),
    };

    // Simulate realistic invalid city error in Demo Mode for nonsense queries
    if (normalized.contains('invalid') || normalized.length < 2) {
      throw const WeatherApiException(
        'City not found in Demo Mode. Try New Delhi, London, Tokyo, Mumbai, or New York.',
      );
    }

    final preset = presets[normalized] ??
        _DemoPreset(
          name: city
              .trim()
              .split(' ')
              .map((w) =>
                  w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
              .join(' '),
          country: 'DEMO',
          tempC: 22,
          feelsLikeC: 22,
          minC: 17,
          maxC: 25,
          condition: 'Clear',
          description: 'Sunny Intervals',
          icon: '01d',
          humidity: 52,
          windMs: 3.6,
          pressure: 1015,
          visibility: 10000,
          clouds: 15,
          uv: 4.8,
        );

    final now = DateTime.now();
    final hourly = List<HourlyForecastItem>.generate(8, (index) {
      final t = now.add(Duration(hours: (index + 1) * 3));
      final delta = [1.0, 2.0, 1.5, 0.0, -2.0, -3.5, -4.0, -2.5][index];
      return HourlyForecastItem(
        dateTime: t,
        temperatureC: preset.tempC + delta,
        condition: index >= 5 ? 'Clouds' : preset.condition,
        iconCode: (t.hour >= 19 || t.hour < 6) ? '01n' : preset.icon,
        popPercent: preset.condition == 'Rain' ? 65 : (index % 3 == 0 ? 15 : 5),
      );
    });

    final daily = List<DailyForecastItem>.generate(7, (index) {
      final day = now.add(Duration(days: index));
      final conditions = [
        preset.condition,
        'Clouds',
        'Clear',
        'Rain',
        'Clear',
        'Clouds',
        'Clear',
      ];
      final icons = [
        preset.icon,
        '03d',
        '01d',
        '10d',
        '01d',
        '02d',
        '01d',
      ];
      final offset = [0.0, -1.0, 1.5, -2.5, 0.5, 1.0, 2.0][index];
      return DailyForecastItem(
        date: day,
        condition: conditions[index],
        iconCode: icons[index],
        minTempC: preset.minC + offset,
        maxTempC: preset.maxC + offset,
      );
    });

    return WeatherBundle(
      current: CurrentWeather(
        cityName: preset.name,
        countryCode: preset.country,
        temperatureC: preset.tempC,
        feelsLikeC: preset.feelsLikeC,
        tempMinC: preset.minC,
        tempMaxC: preset.maxC,
        condition: preset.condition,
        description: preset.description,
        iconCode: preset.icon,
        humidity: preset.humidity,
        windSpeedMs: preset.windMs,
        pressureHpa: preset.pressure,
        visibilityMeters: preset.visibility,
        cloudPercentage: preset.clouds,
        uvIndex: preset.uv,
        dateTime: now,
        sunrise: DateTime(now.year, now.month, now.day, 6, 18),
        sunset: DateTime(now.year, now.month, now.day, 18, 24),
        timezoneOffsetSeconds: 0,
      ),
      hourly: hourly,
      daily: daily,
      isDemoData: true,
      setupNotice: notice ??
          'Demo Data: Add your OpenWeatherMap API key in lib/config/api_config.dart to load live weather.',
    );
  }
}

class _DemoPreset {
  final String name;
  final String country;
  final double tempC;
  final double feelsLikeC;
  final double minC;
  final double maxC;
  final String condition;
  final String description;
  final String icon;
  final int humidity;
  final double windMs;
  final int pressure;
  final int visibility;
  final int clouds;
  final double uv;

  const _DemoPreset({
    required this.name,
    required this.country,
    required this.tempC,
    required this.feelsLikeC,
    required this.minC,
    required this.maxC,
    required this.condition,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windMs,
    required this.pressure,
    required this.visibility,
    required this.clouds,
    required this.uv,
  });
}
