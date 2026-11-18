import 'package:flutter/material.dart';
import 'models/weather_model.dart';
import 'screens/forecast_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/location_service.dart';
import 'services/preferences_service.dart';
import 'services/weather_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkyCastApp());
}

class SkyCastApp extends StatelessWidget {
  const SkyCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyCast – Weather Forecast App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF081124),
      ),
      home: const SkyCastShell(),
    );
  }
}

/// Root navigation shell managing the 3 main sections:
/// 1. Weather (Dashboard)
/// 2. Forecast (24-Hour & 7-Day)
/// 3. Settings (Units & About)
class SkyCastShell extends StatefulWidget {
  const SkyCastShell({super.key});

  @override
  State<SkyCastShell> createState() => _SkyCastShellState();
}

class _SkyCastShellState extends State<SkyCastShell> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  final PreferencesService _prefsService = PreferencesService();

  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _useFahrenheit = false;
  String? _errorMessage;
  String _activeCity = PreferencesService.defaultCity;
  List<String> _recentCities = [];
  WeatherBundle? _weather;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final savedUnit = await _prefsService.getUseFahrenheit();
    final savedCity = await _prefsService.getLastCity();
    final savedHistory = await _prefsService.getRecentCities();

    if (!mounted) return;
    setState(() {
      _useFahrenheit = savedUnit;
      _activeCity = savedCity;
      _recentCities = savedHistory;
    });

    await _loadCityWeather(savedCity);
  }

  Future<void> _loadCityWeather(String city) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _weatherService.fetchByCity(city);
      await _prefsService.saveLastCity(result.current.cityName);
      final updatedHistory = await _prefsService.getRecentCities();

      if (!mounted) return;
      setState(() {
        _weather = result;
        _activeCity = result.current.cityName;
        _recentCities = updatedHistory;
        _isLoading = false;
      });
    } on WeatherApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGpsWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final result = await _weatherService.fetchByCoordinates(
        position.latitude,
        position.longitude,
      );
      await _prefsService.saveLastCity(result.current.cityName);
      final updatedHistory = await _prefsService.getRecentCities();

      if (!mounted) return;
      setState(() {
        _weather = result;
        _activeCity = result.current.cityName;
        _recentCities = updatedHistory;
        _isLoading = false;
      });
    } on LocationException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } on WeatherApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUnit(bool useFahrenheit) async {
    await _prefsService.setUseFahrenheit(useFahrenheit);
    if (!mounted) return;
    setState(() {
      _useFahrenheit = useFahrenheit;
    });
  }

  Future<void> _clearHistory() async {
    await _prefsService.clearRecentCities();
    if (!mounted) return;
    setState(() {
      _recentCities = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        weather: _weather,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        useFahrenheit: _useFahrenheit,
        recentCities: _recentCities,
        onSearchCity: _loadCityWeather,
        onUseCurrentLocation: _loadGpsWeather,
        onRefresh: () => _loadCityWeather(_activeCity),
        onOpenForecastTab: () => setState(() => _selectedIndex = 1),
      ),
      ForecastScreen(
        weather: _weather,
        isLoading: _isLoading,
        useFahrenheit: _useFahrenheit,
      ),
      SettingsScreen(
        useFahrenheit: _useFahrenheit,
        onUnitChanged: _toggleUnit,
        onClearHistory: _clearHistory,
        recentCityCount: _recentCities.length,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071126), // Deep midnight blue
            Color(0xFF101C42), // Navy indigo
            Color(0xFF23194D), // Twilight purple
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'SkyCast',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          actions: [
            if (_weather != null && _weather!.isDemoData)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    'Demo Data',
                    style: TextStyle(
                      color: Color(0xFFFCD34D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          backgroundColor: const Color.fromRGBO(11, 18, 40, 0.92),
          indicatorColor: const Color.fromRGBO(56, 189, 248, 0.22),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny_rounded, color: Color(0xFF7DD3FC)),
              label: 'Weather',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_view_week_outlined),
              selectedIcon: Icon(Icons.calendar_view_week_rounded, color: Color(0xFF7DD3FC)),
              label: 'Forecast',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF7DD3FC)),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
