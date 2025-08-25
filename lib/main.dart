import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/screens/splash_screen.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/screens/get_started_screen.dart';
import 'package:weather_app/screens/menu_screen.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/screens/current_location_screen.dart';
import 'package:weather_app/screens/popular_cities_screen.dart';
import 'package:weather_app/screens/settings_screen.dart';
import 'package:weather_app/screens/help_screen.dart';
import 'package:weather_app/screens/not_found_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2),
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2),
            brightness: Brightness.dark,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/get-started': (context) => const GetStartedScreen(),
          '/menu': (context) => const MenuScreen(),
          '/search': (context) => const SearchScreen(),
          '/current-location': (context) => const CurrentLocationScreen(),
          '/popular-cities': (context) => const PopularCitiesScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/help': (context) => const HelpScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const NotFoundScreen(),
          );
        },
      ),
    );
  }
}
