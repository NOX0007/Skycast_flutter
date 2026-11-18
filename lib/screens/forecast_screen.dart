import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../widgets/daily_forecast_tile.dart';
import '../widgets/glass_card.dart';
import '../widgets/hourly_forecast_list.dart';

/// Dedicated Forecast Screen displaying:
/// - 24-hour horizontally scrollable forecast
/// - Multi-day / 7-day forecast with min/max temperature range bars
class ForecastScreen extends StatelessWidget {
  final WeatherBundle? weather;
  final bool isLoading;
  final bool useFahrenheit;

  const ForecastScreen({
    super.key,
    required this.weather,
    required this.isLoading,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && weather == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7DD3FC)),
      );
    }

    if (weather == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Search for a city on the Weather tab to view its hourly and weekly forecast.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 15),
          ),
        ),
      );
    }

    final daily = weather!.daily;
    double weekMin = 0;
    double weekMax = 30;
    if (daily.isNotEmpty) {
      weekMin = daily.map((d) => d.minTempC).reduce((a, b) => a < b ? a : b);
      weekMax = daily.map((d) => d.maxTempC).reduce((a, b) => a > b ? a : b);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather!.current.cityName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weather!.isDemoData
                      ? 'Demo Data · Sample 24h & 7-Day Forecast'
                      : 'Live OpenWeatherMap Forecast',
                  style: TextStyle(
                    fontSize: 12,
                    color: weather!.isDemoData
                        ? const Color(0xFFFCD34D)
                        : const Color(0xFF7DD3FC),
                  ),
                ),
              ],
            ),
            Text(
              TemperatureFormatter.format(
                weather!.current.temperatureC,
                useFahrenheit,
              ),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Next 24 Hours',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        HourlyForecastList(
          items: weather!.hourly,
          useFahrenheit: useFahrenheit,
        ),
        const SizedBox(height: 24),
        Text(
          weather!.isDemoData ? '7-Day Forecast' : 'Extended Daily Forecast',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          borderRadius: 24,
          child: Column(
            children: List.generate(daily.length, (index) {
              return Column(
                children: [
                  DailyForecastTile(
                    item: daily[index],
                    isToday: index == 0,
                    useFahrenheit: useFahrenheit,
                    weekMinC: weekMin,
                    weekMaxC: weekMax,
                  ),
                  if (index < daily.length - 1)
                    const Divider(
                      color: Color.fromRGBO(255, 255, 255, 0.10),
                      height: 1,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
