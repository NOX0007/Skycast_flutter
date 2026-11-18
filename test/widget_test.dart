import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skycast_weather/screens/home_screen.dart';

void main() {
  testWidgets('home screen displays loading state and searches for a city',
      (tester) async {
    String? searchedCity;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            weather: null,
            isLoading: true,
            errorMessage: null,
            useFahrenheit: false,
            recentCities: const [],
            onSearchCity: (city) async {
              searchedCity = city;
            },
            onUseCurrentLocation: () async {},
            onRefresh: () async {},
            onOpenForecastTab: () {},
          ),
        ),
      ),
    );

    expect(find.text('Fetching atmospheric conditions...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  Tokyo  ');
    await tester.tap(find.byTooltip('Search city'));
    await tester.pump();

    expect(searchedCity, 'Tokyo');
  });
}
