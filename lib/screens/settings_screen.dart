import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../widgets/glass_card.dart';

/// Settings Screen:
/// - Toggle Celsius (°C) and Fahrenheit (°F) persisted in SharedPreferences
/// - View OpenWeatherMap API configuration status
/// - Clear recently searched cities
/// - About SkyCast app section
class SettingsScreen extends StatelessWidget {
  final bool useFahrenheit;
  final ValueChanged<bool> onUnitChanged;
  final VoidCallback onClearHistory;
  final int recentCityCount;

  const SettingsScreen({
    super.key,
    required this.useFahrenheit,
    required this.onUnitChanged,
    required this.onClearHistory,
    required this.recentCityCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasKey = ApiConfig.hasValidApiKey;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Temperature Unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose how temperatures are displayed across dashboards and forecasts.',
                style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
              ),
              const SizedBox(height: 14),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Celsius (°C)'),
                    icon: Icon(Icons.thermostat_rounded),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Fahrenheit (°F)'),
                    icon: Icon(Icons.device_thermostat_rounded),
                  ),
                ],
                selected: {useFahrenheit},
                onSelectionChanged: (selection) {
                  onUnitChanged(selection.first);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected)
                        ? const Color(0xFF0F172A)
                        : Colors.white;
                  }),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected)
                        ? const Color(0xFF7DD3FC)
                        : const Color.fromRGBO(255, 255, 255, 0.08);
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OpenWeatherMap API Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    hasKey ? Icons.check_circle_rounded : Icons.science_rounded,
                    color: hasKey
                        ? const Color(0xFF34D399)
                        : const Color(0xFFFCD34D),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasKey
                          ? 'Live API Key Configured'
                          : 'Demo Mode Active (API Key Missing)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                hasKey
                    ? 'Fetching real-time weather from api.openweathermap.org/data/2.5.'
                    : 'Open lib/config/api_config.dart and replace YOUR_OPENWEATHERMAP_API_KEY with your OpenWeatherMap API key.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFCBD5E1),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent City History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$recentCityCount saved cities stored on device',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: recentCityCount > 0 ? onClearHistory : null,
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Color(0xFF7DD3FC)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const GlassCard(
          padding: EdgeInsets.all(18),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About SkyCast',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'SkyCast – Weather Forecast App (v1.0.0)\n'
                'Built with Flutter, Material Design 3, OpenWeatherMap API, '
                'SharedPreferences, and Geolocator.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFCBD5E1),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
