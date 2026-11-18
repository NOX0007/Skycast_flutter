/// Data models for SkyCast weather readings and forecasts.
/// All temperatures are stored internally in Celsius (°C) and converted
/// to Fahrenheit (°F) at display time when requested in Settings.

class CurrentWeather {
  final String cityName;
  final String countryCode;
  final double temperatureC;
  final double feelsLikeC;
  final double tempMinC;
  final double tempMaxC;
  final String condition;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeedMs;
  final int pressureHpa;
  final int visibilityMeters;
  final int cloudPercentage;
  final double? uvIndex; // Nullable: OWM 2.5 free endpoint does not return UV
  final DateTime dateTime;
  final DateTime sunrise;
  final DateTime sunset;
  final int timezoneOffsetSeconds;

  const CurrentWeather({
    required this.cityName,
    required this.countryCode,
    required this.temperatureC,
    required this.feelsLikeC,
    required this.tempMinC,
    required this.tempMaxC,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeedMs,
    required this.pressureHpa,
    required this.visibilityMeters,
    required this.cloudPercentage,
    this.uvIndex,
    required this.dateTime,
    required this.sunrise,
    required this.sunset,
    required this.timezoneOffsetSeconds,
  });

  /// Parses JSON returned by https://api.openweathermap.org/data/2.5/weather
  /// when requested with `units=metric`.
  factory CurrentWeather.fromOpenWeatherJson(Map<String, dynamic> json) {
    final weatherList = (json['weather'] as List<dynamic>? ?? []);
    final primaryWeather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};

    final main = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};

    final offset = (json['timezone'] as num?)?.toInt() ?? 0;

    return CurrentWeather(
      cityName: (json['name'] as String?) ?? 'Unknown City',
      countryCode: (sys['country'] as String?) ?? '',
      temperatureC: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLikeC: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMinC: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMaxC: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      condition: (primaryWeather['main'] as String?) ?? 'Clear',
      description: _capitalizeWords(
        (primaryWeather['description'] as String?) ?? 'Clear sky',
      ),
      iconCode: (primaryWeather['icon'] as String?) ?? '01d',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeedMs: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      pressureHpa: (main['pressure'] as num?)?.toInt() ?? 1013,
      visibilityMeters: (json['visibility'] as num?)?.toInt() ?? 10000,
      cloudPercentage: (clouds['all'] as num?)?.toInt() ?? 0,
      uvIndex: null, // Not included in OpenWeatherMap 2.5 /weather
      dateTime: _fromUnixWithOffset(
        (json['dt'] as num?)?.toInt() ?? 0,
        offset,
      ),
      sunrise: _fromUnixWithOffset(
        (sys['sunrise'] as num?)?.toInt() ?? 0,
        offset,
      ),
      sunset: _fromUnixWithOffset(
        (sys['sunset'] as num?)?.toInt() ?? 0,
        offset,
      ),
      timezoneOffsetSeconds: offset,
    );
  }

  static DateTime _fromUnixWithOffset(int unixSeconds, int offsetSeconds) {
    return DateTime.fromMillisecondsSinceEpoch(
      (unixSeconds + offsetSeconds) * 1000,
      isUtc: true,
    );
  }

  static String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class HourlyForecastItem {
  final DateTime dateTime;
  final double temperatureC;
  final String condition;
  final String iconCode;
  final int popPercent; // Probability of precipitation (0-100)

  const HourlyForecastItem({
    required this.dateTime,
    required this.temperatureC,
    required this.condition,
    required this.iconCode,
    required this.popPercent,
  });

  factory HourlyForecastItem.fromOpenWeatherJson(
    Map<String, dynamic> json,
    int timezoneOffsetSeconds,
  ) {
    final weatherList = (json['weather'] as List<dynamic>? ?? []);
    final primaryWeather = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final dtUnix = (json['dt'] as num?)?.toInt() ?? 0;

    return HourlyForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (dtUnix + timezoneOffsetSeconds) * 1000,
        isUtc: true,
      ),
      temperatureC: (main['temp'] as num?)?.toDouble() ?? 0.0,
      condition: (primaryWeather['main'] as String?) ?? 'Clear',
      iconCode: (primaryWeather['icon'] as String?) ?? '01d',
      popPercent: (((json['pop'] as num?)?.toDouble() ?? 0.0) * 100).round(),
    );
  }
}

class DailyForecastItem {
  final DateTime date;
  final String condition;
  final String iconCode;
  final double minTempC;
  final double maxTempC;

  const DailyForecastItem({
    required this.date,
    required this.condition,
    required this.iconCode,
    required this.minTempC,
    required this.maxTempC,
  });
}

/// Complete weather response bundle passed to the UI.
class WeatherBundle {
  final CurrentWeather current;
  final List<HourlyForecastItem> hourly;
  final List<DailyForecastItem> daily;
  final bool isDemoData;
  final String? setupNotice;

  const WeatherBundle({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.isDemoData,
    this.setupNotice,
  });
}

/// Helper for unit conversion and formatting.
class TemperatureFormatter {
  TemperatureFormatter._();

  static double convert(double celsius, bool useFahrenheit) {
    return useFahrenheit ? (celsius * 9 / 5) + 32 : celsius;
  }

  static String format(double celsius, bool useFahrenheit) {
    final value = convert(celsius, useFahrenheit).round();
    final unit = useFahrenheit ? '°F' : '°C';
    return '$value$unit';
  }

  static String formatCompact(double celsius, bool useFahrenheit) {
    final value = convert(celsius, useFahrenheit).round();
    return '$value°';
  }
}
