import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import 'weather_icon_widget.dart';

/// Displays one day row in the 7-day forecast with day name,
/// weather icon, condition, and min/max temperature range bar.
class DailyForecastTile extends StatelessWidget {
  final DailyForecastItem item;
  final bool isToday;
  final bool useFahrenheit;
  final double weekMinC;
  final double weekMaxC;

  const DailyForecastTile({
    super.key,
    required this.item,
    required this.isToday,
    required this.useFahrenheit,
    required this.weekMinC,
    required this.weekMaxC,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = isToday ? 'Today' : DateFormat('EEE').format(item.date);
    final minLabel =
        TemperatureFormatter.formatCompact(item.minTempC, useFahrenheit);
    final maxLabel =
        TemperatureFormatter.formatCompact(item.maxTempC, useFahrenheit);

    final span = (weekMaxC - weekMinC).clamp(1.0, 60.0);
    final startRatio = ((item.minTempC - weekMinC) / span).clamp(0.0, 0.85);
    final widthRatio =
        ((item.maxTempC - item.minTempC) / span).clamp(0.12, 1.0 - startRatio);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Text(
              dayLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          WeatherIconWidget(
            iconCode: item.iconCode,
            size: 34,
            animate: false,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              item.condition,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              minLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fullW = constraints.maxWidth;
                return Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: fullW * startRatio,
                        width: fullW * widthRatio,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF38BDF8),
                                Color(0xFFA78BFA),
                                Color(0xFFFBBF24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              maxLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
