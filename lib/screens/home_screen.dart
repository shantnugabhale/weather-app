import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';
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

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _fetchWeatherForCurrentCity();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bgController.dispose();
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
          colors: [Color(0xff4A90E2), Color.fromARGB(255, 189, 221, 214)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await _fetchWeatherForCurrentCity();
        },
        color: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        child: AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getPrimaryGradientColor(),
                _getSecondaryGradientColor(),
                _getTertiaryGradientColor(),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      children: [
                        _buildEnhancedHeader(),
                        const SizedBox(height: 32),
                        _buildEnhancedSearchbar(),
                        const SizedBox(height: 32),
                        _buildCurrentWeatherCard(),
                        const SizedBox(height: 24),
                        _buildHourlyForecast(),
                        const SizedBox(height: 24),
                        _buildWeatherInsights(),
                        const SizedBox(height: 24),
                        _buildEnhancedDetailsGrid(),
                        const SizedBox(height: 30),
                        _buildWeatherTips(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPrimaryGradientColor() {
    final condition = _weather?.mainCondition?.toLowerCase() ?? '';
    if (condition.contains('rain')) return const Color.fromARGB(255, 23, 39, 84);
    if (condition.contains('snow')) return const Color.fromARGB(211, 80, 105, 188);
    if (condition.contains('clear')) return const Color.fromARGB(255, 216, 213, 16);
    if (condition.contains('cloud')) return const Color(0xFF374151);
    return const Color(0xFF1E40AF);
  }

  Color _getSecondaryGradientColor() {
    final condition = _weather?.mainCondition?.toLowerCase() ?? '';
    if (condition.contains('rain')) return const Color.fromARGB(255, 25, 53, 98);
    if (condition.contains('snow')) return const Color.fromARGB(255, 84, 153, 238);
    if (condition.contains('clear')) return const Color.fromARGB(255, 195, 218, 18);
    if (condition.contains('cloud')) return const Color(0xFF6B7280);
    return const Color(0xFF3B82F6);
  }

  Color _getTertiaryGradientColor() {
    final condition = _weather?.mainCondition?.toLowerCase() ?? '';
    if (condition.contains('rain')) return const Color.fromARGB(255, 32, 61, 93);
    if (condition.contains('snow')) return const Color.fromARGB(255, 85, 136, 199);
    if (condition.contains('clear')) return const Color.fromARGB(255, 163, 207, 43);
    if (condition.contains('cloud')) return const Color(0xFF9CA3AF);
    return const Color(0xFF93C5FD);
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText(
                  'Weather App',
                  textStyle: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.black26,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  speed: const Duration(milliseconds: 150),
                ),
              ],
              isRepeatingAnimation: false,
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: IconButton(
                  icon: Icon(
                    _getThemeIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _showThemeSelector,
                  tooltip: 'Change Theme',
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                  onPressed: () {
                    // Add settings functionality
                  },
                  tooltip: 'Settings',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSearchbar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _fetchWeather(value);
            _searchController.clear();
          }
        },
        onChanged: (value) {
          if (value.length > 2) {
            // You can implement city suggestions here
          }
        },
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search for a city...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 22),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.my_location, color: Colors.white, size: 22),
                  ),
                  onPressed: _fetchWeatherForCurrentCity,
                  tooltip: 'Get current location',
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.map, color: Colors.white, size: 22),
                  ),
                  onPressed: () {
                    _showWeatherMap();
                  },
                  tooltip: 'Weather Map',
                ),
              ),
            ],
          ),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weather?.cityName ?? "Unknown City",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_weather?.temperature.round() ?? 0}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    _weather?.mainCondition ?? "Unknown",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // FIX: Wraps each weather info chip in an Expanded widget to prevent horizontal overflow.
            children: [
              Expanded(
                child: _buildWeatherInfoChip(
                  Icons.thermostat,
                  'Feels Like',
                  '${_weather?.feelsLike.round() ?? 0}°',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildWeatherInfoChip(
                  Icons.water_drop,
                  'Humidity',
                  '${_weather?.humidity ?? 0}%',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildWeatherInfoChip(
                  Icons.air,
                  'Wind',
                  '${_weather?.windSpeed.toStringAsFixed(1) ?? 0} km/h',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfoChip(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4), // Added a small margin for spacing
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading weather data...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  IconData _getThemeIcon() {
    final condition = _weather?.mainCondition?.toLowerCase() ?? '';
    if (condition.contains('rain')) return Icons.umbrella;
    if (condition.contains('snow')) return Icons.ac_unit;
    if (condition.contains('clear')) return Icons.wb_sunny;
    if (condition.contains('cloud')) return Icons.cloud;
    return Icons.palette;
  }

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildThemeSelector(),
    );
  }

  Widget _buildThemeSelector() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Choose Weather Theme',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildThemeOption(Icons.wb_sunny, 'Sunny', Colors.orange),
                _buildThemeOption(Icons.cloud, 'Cloudy', Colors.grey),
                _buildThemeOption(Icons.umbrella, 'Rainy', Colors.blue),
                _buildThemeOption(Icons.ac_unit, 'Snowy', Colors.cyan),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildThemeOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showWeatherMap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWeatherMapSheet(),
    );
  }

  Widget _buildWeatherMapSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.map, color: const Color(0xFF1976D2), size: 24),
                const SizedBox(width: 12),
                Text(
                  'Weather Map',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE3F2FD),
                    Color(0xFFBBDEFB),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF64B5F6)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 80,
                      color: const Color(0xFF42A5F5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Interactive Weather Map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Coming Soon!',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        'View detailed weather patterns',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildCityAndTemp() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // City Name
          Expanded(
            child: Text(
              _weather?.cityName ?? "Unknown City",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Temperature and Condition
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_weather?.temperature.round() ?? 0}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -1,
                ),
              ),
              Text(
                _weather?.mainCondition ?? "Unknown",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF64B5F6).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Color(0xFF64B5F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 132,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 24,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                final hour = DateTime.now().add(Duration(hours: index));
                final temp = _weather?.temperature ?? 0;
                final hourlyTemp = temp + (index * 0.5) - 2; // Simulated hourly variation
                
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${hour.hour}:00',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getHourlyWeatherColor(index).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          _getHourlyWeatherIcon(index),
                          color: _getHourlyWeatherColor(index).withValues(alpha: 1.0),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${hourlyTemp.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getHourlyWeatherIcon(int hour) {
    if (hour >= 6 && hour <= 18) {
      return Icons.wb_sunny;
    } else {
      return Icons.nights_stay;
    }
  }

  Color _getHourlyWeatherColor(int hour) {
    if (hour >= 6 && hour <= 18) {
      return Colors.orange;
    } else {
      return Colors.indigo;
    }
  }

  Widget _buildWeatherTips() {
    final condition = _weather?.mainCondition?.toLowerCase() ?? '';
    String tip = '';
    IconData tipIcon = Icons.info_outline;
    Color tipColor = Colors.blue;

    if (condition.contains('rain')) {
      tip = 'Don\'t forget your umbrella! 🌂';
      tipIcon = Icons.umbrella;
      tipColor = Colors.blue;
    } else if (condition.contains('snow')) {
      tip = 'Bundle up, it\'s cold outside! ❄️';
      tipIcon = Icons.ac_unit;
      tipColor = Colors.cyan;
    } else if (condition.contains('clear')) {
      tip = 'Perfect weather for outdoor activities! ☀️';
      tipIcon = Icons.sports_soccer;
      tipColor = Colors.orange;
    } else if (condition.contains('cloud')) {
      tip = 'Light jacket weather! 🧥';
      tipIcon = Icons.cloud;
      tipColor = Colors.grey;
    } else {
      tip = 'Check the weather before heading out! 📱';
      tipIcon = Icons.tips_and_updates;
      tipColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tipColor.withValues(alpha: 0.25),
            tipColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: tipColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: tipColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tipColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: tipColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(tipIcon, color: tipColor, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Tip',
                  style: TextStyle(
                    color: tipColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.3,
      children: [
        _buildDetailItem(Icons.thermostat, "Feels Like", '${_weather?.feelsLike.round() ?? 0}°', Colors.orange),
        _buildDetailItem(Icons.water_drop_outlined, "Humidity", '${_weather?.humidity ?? 0}%', Colors.blue),
        _buildDetailItem(Icons.air, "Wind Speed", '${_weather?.windSpeed ?? 0} km/h', Colors.green),
        _buildDetailItem(Icons.visibility, "Condition", _weather?.mainCondition ?? 'N/A', Colors.purple),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withValues(alpha: 0.2),
            iconColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline, color: Colors.amber, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchWeatherForCurrentCity,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.purple.shade300,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weather Statistics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Temperature Range',
                  '${(_weather?.temperature ?? 0).round()}° - ${(_weather?.feelsLike ?? 0).round()}°',
                  Icons.thermostat,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Wind Category',
                  _getWindCategory(_weather?.windSpeed ?? 0),
                  Icons.air,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Humidity Level',
                  _getHumidityLevel(_weather?.humidity ?? 0),
                  Icons.water_drop,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'UV Index',
                  'Moderate',
                  Icons.wb_sunny,
                  Colors.yellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getWindCategory(double windSpeed) {
    if (windSpeed < 5) return 'Light';
    if (windSpeed < 15) return 'Moderate';
    if (windSpeed < 25) return 'Strong';
    return 'Very Strong';
  }

  String _getHumidityLevel(int humidity) {
    if (humidity < 30) return 'Low';
    if (humidity < 60) return 'Moderate';
    if (humidity < 80) return 'High';
    return 'Very High';
  }

  Widget _buildWeatherInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Color(0xFF8B5CF6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weather Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'UV Index',
                  'Moderate',
                  Icons.wb_sunny,
                  Colors.yellow,
                  'Protection needed',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightCard(
                  'Air Quality',
                  'Good',
                  Icons.air,
                  Colors.green,
                  'Fresh air',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDetailsGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.grid_view,
                  color: Color(0xFF10B981),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Detailed Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // FIX: Changed childAspectRatio to a smaller value to prevent vertical overflow on smaller screens.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.9,
            children: [
              _buildDetailItem(Icons.thermostat, "Feels Like", '${_weather?.feelsLike.round() ?? 0}°', Colors.orange),
              _buildDetailItem(Icons.water_drop_outlined, "Humidity", '${_weather?.humidity ?? 0}%', Colors.blue),
              _buildDetailItem(Icons.air, "Wind Speed", '${_weather?.windSpeed ?? 0} km/h', Colors.green),
              _buildDetailItem(Icons.visibility, "Condition", _weather?.mainCondition ?? 'N/A', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }
}