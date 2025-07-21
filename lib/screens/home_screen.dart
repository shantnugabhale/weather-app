import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _weatherService = WeatherService('72a9ba3f40e7af40008ad23cc2dd18d9');
  final _searchController = TextEditingController();
  Weather? _weather;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation Controllers
  late final AnimationController _bgController;
  late final AnimationController _textController;
  late final Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    );

    _fetchWeatherForCurrentCity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bgController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeatherForCurrentCity() async {
    await _fetchWeather();
  }

  Future<void> _fetchWeather([String? cityName]) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String cityToFetch;
      if (cityName != null && cityName.isNotEmpty) {
        cityToFetch = cityName;
      } else {
        cityToFetch = await _weatherService.getCurrentCity();
      }

      if (cityToFetch.isEmpty) {
        throw Exception("Could not determine your city. Please enable location services or use the search bar.");
      }

      final weather = await _weatherService.getWeather(cityToFetch);
      if (weather == null) {
        throw Exception("Could not fetch weather data for $cityToFetch. The city may not be supported or there might be a network issue.");
      }

      if (mounted) {
        setState(() {
          _weather = weather;
          _textController.forward(from: 0.0);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/rain.json';
      case 'snow':
        return 'assets/snowfall.json';
      default:
        return 'assets/sunny.json';
    }
  }

  LinearGradient getBackgroundGradient(String? mainCondition) {
    if (mainCondition == null) {
      return const LinearGradient(
        colors: [Color(0xff4A90E2), Color(0xff50E3C2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return const LinearGradient(
          colors: [Color(0xff8E9EAB), Color(0xffEEF2F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'rain':
      case 'drizzle':
      case 'shower rain':
      case 'thunderstorm':
        return const LinearGradient(
          colors: [Color(0xff2C3E50), Color(0xff4CA1AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'snow':
        return const LinearGradient(
          colors: [Color(0xffE6DADA), Color(0xff274046)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xff4A90E2), Color(0xff50E3C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(seconds: 1),
        decoration: BoxDecoration(
          gradient: getBackgroundGradient(_weather?.mainCondition),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchbar(),
                const SizedBox(height: 20),
                Expanded(child: _buildUIContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedTextKit(
      animatedTexts: [
        WavyAnimatedText(
          'Weather App',
          textStyle: const TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 7.0,
                color: Colors.black45,
                offset: Offset(0, 3),
              ),
            ],
          ),
          speed: const Duration(milliseconds: 200),
        ),
      ],
      isRepeatingAnimation: false,
    );
  }

  Widget _buildSearchbar() {
    return TextField(
      controller: _searchController,
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          _fetchWeather(value);
          _searchController.clear();
        }
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search for a city...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        suffixIcon: IconButton(
          icon: const Icon(Icons.my_location, color: Colors.white70),
          onPressed: _fetchWeatherForCurrentCity,
          tooltip: 'Get current location',
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildUIContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return FadeTransition(
      opacity: _textAnimation,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(getWeatherAnimation(_weather?.mainCondition), height: 200),
            Text(
              _weather?.cityName ?? "Unknown City",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_weather?.temperature.round() ?? 0}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w200,
              ),
            ),
            Text(
              _weather?.mainCondition ?? "Unknown",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildDetailsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildDetailItem(Icons.thermostat, "Feels Like", '${_weather?.feelsLike.round() ?? 0}°'),
        _buildDetailItem(Icons.water_drop_outlined, "Humidity", '${_weather?.humidity ?? 0}%'),
        _buildDetailItem(Icons.air, "Wind Speed", '${_weather?.windSpeed ?? 0} km/h'),
        _buildDetailItem(Icons.visibility, "Condition", _weather?.mainCondition ?? 'N/A'),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.amber, size: 60),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _fetchWeatherForCurrentCity,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              foregroundColor: Colors.white,
            ),
            child: const Text("Try Again"),
          )
        ],
      ),
    );
  }
}
