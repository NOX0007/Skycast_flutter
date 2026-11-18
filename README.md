# SkyCast – Weather Forecast App (Flutter & Dart)

A modern, beginner-friendly Material Design 3 weather forecast application built with Flutter, Dart, OpenWeatherMap API, SharedPreferences, and Geolocator.

## 1. Project Folder Structure

```text
skycast_flutter/
├── pubspec.yaml
├── README.md
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml
└── lib/
    ├── main.dart
    ├── config/
    │   └── api_config.dart
    ├── models/
    │   └── weather_model.dart
    ├── services/
    │   ├── weather_service.dart
    │   ├── location_service.dart
    │   └── preferences_service.dart
    ├── widgets/
    │   ├── glass_card.dart
    │   ├── weather_icon_widget.dart
    │   ├── detail_metric_card.dart
    │   ├── hourly_forecast_list.dart
    │   └── daily_forecast_tile.dart
    └── screens/
        ├── home_screen.dart
        ├── forecast_screen.dart
        └── settings_screen.dart
```

## 2. Adding Your OpenWeatherMap API Key

1. Create a free account at https://openweathermap.org/api.
2. Open your OpenWeatherMap account menu -> **My API Keys** and copy your key.
   *(Note: Newly created OpenWeatherMap keys can take 10–30 minutes to activate.)*
3. Open `lib/config/api_config.dart` and replace `'YOUR_OPENWEATHERMAP_API_KEY'`:
   ```dart
   static const String openWeatherApiKey = 'YOUR_REAL_API_KEY_HERE';
   ```
4. If no key is provided, SkyCast runs safely in **Demo Mode** and clearly labels all forecasts as **Demo Data**.

## 3. Running in VS Code or Android Studio

1. Ensure Flutter SDK is installed (`flutter doctor`).
2. Create a fresh Flutter project wrapper or copy `lib/`, `pubspec.yaml`, and `AndroidManifest.xml` into your project:
   ```bash
   flutter create skycast_weather
   ```
   Replace `pubspec.yaml`, `lib/`, and `android/app/src/main/AndroidManifest.xml` with the files from `skycast_flutter/`.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Connect an Android emulator or physical Android device (with USB Debugging enabled).
5. Run the app:
   - **VS Code**: Open the folder, select your device in the bottom-right status bar, and press `F5` (or run `flutter run` in the integrated terminal).
   - **Android Studio**: Open the folder, select your emulator/device in the top toolbar, and click the green **Run** triangle.

## 4. Building the Release APK

Run the following command from the root of your Flutter project:

```bash
flutter build apk --release
```

Your installable release APK will be generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```
