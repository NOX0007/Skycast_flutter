import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'glass_card.dart';
import 'weather_icon_widget.dart';

/// Horizontally scrollable 24-hour forecast strip.
class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecastItem> items;
  final bool useFahrenheit;

  const HourlyForecastList({
    super.key,
    required this.items,
    required this.useFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const GlassCard(
        child: Text(
          'Hourly forecast data is unavailable for this location.',
          style: TextStyle(color: Color(0xFFCBD5E1)),
        ),
      );
    }

    return SizedBox(
      height: 146,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final timeLabel = DateFormat('h a').format(item.dateTime);
          final tempLabel = TemperatureFormatter.formatCompact(
            item.temperatureC,
            useFahrenheit,
          );

          return SizedBox(
            width: 88,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              borderRadius: 22,
              tintColor: index == 0
                  ? const Color.fromRGBO(56, 189, 248, 0.16)
                  : const Color.fromRGBO(255, 255, 255, 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    index == 0 ? 'Next' : timeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          index == 0 ? FontWeight.w700 : FontWeight.w500,
                      color: index == 0
                          ? const Color(0xFFBAE6FD)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  WeatherIconWidget(
                    iconCode: item.iconCode,
                    size: 40,
                    animate: false,
                  ),
                  Text(
                    tempLabel,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (item.popPercent > 0)
                    Text(
                      '${item.popPercent}% rain',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF93C5FD),
                      ),
                    )
                  else
                    Text(
                      item.condition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
