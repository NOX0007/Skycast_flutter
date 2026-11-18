import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../widgets/detail_metric_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/weather_icon_widget.dart';

/// Main Weather Dashboard Screen showing:
/// - Search bar + GPS location button + recent cities
/// - Current weather hero card (city, temp, feels like, high/low, date/time, sunrise/sunset)
/// - 6 weather detail cards (Humidity, Wind, Pressure, Visibility, UV Index, Clouds)
/// - Upcoming 24-hour preview strip
class HomeScreen extends StatefulWidget {
  final WeatherBundle? weather;
  final bool isLoading;
  final String? errorMessage;
  final bool useFahrenheit;
  final List<String> recentCities;
  final Future<void> Function(String city) onSearchCity;
  final Future<void> Function() onUseCurrentLocation;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenForecastTab;

  const HomeScreen({
    super.key,
    required this.weather,
    required this.isLoading,
    required this.errorMessage,
    required this.useFahrenheit,
    required this.recentCities,
    required this.onSearchCity,
    required this.onUseCurrentLocation,
    required this.onRefresh,
    required this.onOpenForecastTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onSearchCity(query);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: const Color(0xFF7DD3FC),
      backgroundColor: const Color(0xFF172554),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _buildSearchRow(),
          if (widget.recentCities.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildRecentCitiesRow(),
          ],
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 14),
            _buildErrorCard(widget.errorMessage!),
          ],
          if (widget.isLoading && widget.weather == null) ...[
            const SizedBox(height: 40),
            _buildLoadingState(),
          ] else if (widget.weather != null) ...[
            if (widget.weather!.isDemoData) ...[
              const SizedBox(height: 14),
              _buildDemoNoticeBanner(widget.weather!.setupNotice),
            ],
            const SizedBox(height: 16),
            _buildHeroWeatherCard(widget.weather!.current),
            const SizedBox(height: 20),
            _buildSectionTitle(
              'Today\'s Forecast',
              actionLabel: '7-Day View',
              onAction: widget.onOpenForecastTab,
            ),
            const SizedBox(height: 10),
            HourlyForecastList(
              items: widget.weather!.hourly,
              useFahrenheit: widget.useFahrenheit,
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Weather Details'),
            const SizedBox(height: 10),
            _buildDetailsGrid(widget.weather!.current),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            borderRadius: 18,
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submitSearch(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Search city (e.g. London, Tokyo)',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _submitSearch,
                  tooltip: 'Search city',
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF7DD3FC),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Use current GPS location',
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onUseCurrentLocation,
            borderRadius: BorderRadius.circular(18),
            child: const GlassCard(
              padding: EdgeInsets.all(15),
              borderRadius: 18,
              child: Icon(
                Icons.my_location_rounded,
                color: Color(0xFF7DD3FC),
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCitiesRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.recentCities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = widget.recentCities[index];
          return ActionChip(
            onPressed: () {
              _searchController.text = city;
              widget.onSearchCity(city);
            },
            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.10),
            side: const BorderSide(
              color: Color.fromRGBO(255, 255, 255, 0.16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            avatar: const Icon(
              Icons.history_rounded,
              size: 15,
              color: Color(0xFF7DD3FC),
            ),
            label: Text(
              city,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemoNoticeBanner(String? notice) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 18,
      tintColor: const Color.fromRGBO(245, 158, 11, 0.14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFCD34D),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo Data Mode',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notice ??
                      'Add your OpenWeatherMap API key in lib/config/api_config.dart for live readings.',
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      tintColor: const Color.fromRGBO(239, 68, 68, 0.18),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFCA5A5),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFEE2E2),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: Color(0xFF7DD3FC)),
          SizedBox(height: 14),
          Text(
            'Fetching atmospheric conditions...',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroWeatherCard(CurrentWeather current) {
    final formattedDate =
        DateFormat('EEEE, MMM d · h:mm a').format(current.dateTime);
    final sunriseTime = DateFormat('h:mm a').format(current.sunrise);
    final sunsetTime = DateFormat('h:mm a').format(current.sunset);

    final mainTemp =
        TemperatureFormatter.format(current.temperatureC, widget.useFahrenheit);
    final feelsLike =
        TemperatureFormatter.format(current.feelsLikeC, widget.useFahrenheit);
    final highTemp =
        TemperatureFormatter.formatCompact(current.tempMaxC, widget.useFahrenheit);
    final lowTemp =
        TemperatureFormatter.formatCompact(current.tempMinC, widget.useFahrenheit);

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.countryCode.isNotEmpty
                          ? '${current.cityName}, ${current.countryCode}'
                          : current.cityName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7DD3FC),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mainTemp,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    current.description,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBAE6FD),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feels like $feelsLike · H: $highTemp  L: $lowTemp',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ],
              ),
              WeatherIconWidget(
                iconCode: current.iconCode,
                size: 88,
                animate: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color.fromRGBO(255, 255, 255, 0.14), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SunTimeItem(
                icon: Icons.wb_twilight_rounded,
                label: 'Sunrise',
                time: sunriseTime,
                color: const Color(0xFFFCD34D),
              ),
              _SunTimeItem(
                icon: Icons.nights_stay_rounded,
                label: 'Sunset',
                time: sunsetTime,
                color: const Color(0xFFC4B5FD),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid(CurrentWeather current) {
    final visibilityKm = (current.visibilityMeters / 1000).toStringAsFixed(1);
    final windKmh = (current.windSpeedMs * 3.6).toStringAsFixed(1);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.38,
      children: [
        DetailMetricCard(
          icon: Icons.water_drop_rounded,
          label: 'Humidity',
          value: '${current.humidity}%',
          subtitle: current.humidity > 70 ? 'Humid air' : 'Comfortable',
          accentColor: const Color(0xFF38BDF8),
        ),
        DetailMetricCard(
          icon: Icons.air_rounded,
          label: 'Wind Speed',
          value: '$windKmh km/h',
          subtitle: '${current.windSpeedMs.toStringAsFixed(1)} m/s breeze',
          accentColor: const Color(0xFF93C5FD),
        ),
        DetailMetricCard(
          icon: Icons.speed_rounded,
          label: 'Pressure',
          value: '${current.pressureHpa} hPa',
          subtitle: current.pressureHpa >= 1013 ? 'High / Stable' : 'Low system',
          accentColor: const Color(0xFFC4B5FD),
        ),
        DetailMetricCard(
          icon: Icons.visibility_rounded,
          label: 'Visibility',
          value: '$visibilityKm km',
          subtitle: current.visibilityMeters >= 8000 ? 'Clear view' : 'Reduced',
          accentColor: const Color(0xFFA5F3FC),
        ),
        DetailMetricCard(
          icon: Icons.wb_sunny_outlined,
          label: 'UV Index',
          value: current.uvIndex != null
              ? current.uvIndex!.toStringAsFixed(1)
              : 'N/A',
          subtitle: current.uvIndex == null
              ? 'Not in OWM 2.5'
              : (current.uvIndex! >= 6 ? 'High exposure' : 'Low–Moderate'),
          accentColor: const Color(0xFFFCD34D),
        ),
        DetailMetricCard(
          icon: Icons.cloud_queue_rounded,
          label: 'Cloud Cover',
          value: '${current.cloudPercentage}%',
          subtitle: current.cloudPercentage > 60 ? 'Overcast' : 'Mostly open',
          accentColor: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Color(0xFF7DD3FC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _SunTimeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;
  final Color color;

  const _SunTimeItem({
    required this.icon,
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
