import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/screens/get_started_screen.dart'; // Added import for GetStartedScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
      _checkLocationPermission();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final provider = context.read<WeatherProvider>();
    final hasPermission = await LocationService.checkLocationPermission();
    provider.setLocationPermission(hasPermission);
    
    if (hasPermission) {
      await provider.fetchWeatherByLocation();
    }
  }

  Future<void> _requestLocationPermission() async {
    final granted = await LocationService.requestLocationPermission();
    if (granted) {
      final provider = context.read<WeatherProvider>();
      provider.setLocationPermission(true);
      await provider.fetchWeatherByLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final weather = weatherProvider.weather;
        final isLoading = weatherProvider.isLoading;
        final errorMessage = weatherProvider.errorMessage;
        final isDarkMode = weatherProvider.isDarkMode;
        final isCelsius = weatherProvider.isCelsius;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: _getBackgroundGradient(weather?.mainCondition, isDarkMode),
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: weatherProvider.refreshWeather,
                color: Colors.white,
                backgroundColor: Colors.black26,
                                  child: weather == null && !isLoading && errorMessage == null
                      ? FadeTransition(
                          opacity: _fadeController,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(_slideController),
                            child: Container(
                              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 16.0 : 24.0,
                              ),
                              child: Column(
                                children: [
                                  const Spacer(),
                                  _buildWelcomeCard(isSmallScreen),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16.0 : 24.0,
                            vertical: 16.0,
                          ),
                          child: FadeTransition(
                            opacity: _fadeController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(_slideController),
                              child: Column(
                                children: [
                                  // Top section with search and theme toggles (only show when weather data is available)
                                  if (weather != null) ...[
                                    _buildTopSection(weatherProvider, isSmallScreen),
                                    const SizedBox(height: 24),
                                  ],
                                  
                                  if (isLoading) _buildLoadingCard(isSmallScreen),
                                  if (errorMessage != null) _buildErrorCard(errorMessage, weatherProvider, isSmallScreen),
                                  if (weather != null && !isLoading) ...[
                                    // Current weather section
                                    _buildCurrentWeatherSection(weather, isCelsius, isSmallScreen),
                                    const SizedBox(height: 24),
                                    
                                    // Quick stats row
                                    _buildQuickStatsRow(weather, isCelsius, isSmallScreen),
                                    const SizedBox(height: 24),
                                    
                                    // Sunrise & Sunset card
                                    _buildSunriseSunsetCard(weather, isSmallScreen),
                                    const SizedBox(height: 24),
                                    
                                    // Weather details grid
                                    _buildWeatherDetailsGrid(weather, isSmallScreen),
                                    const SizedBox(height: 24),
                                    
                                    // Weather tip card
                                    _buildWeatherTipCard(weather, isSmallScreen),
                                    const SizedBox(height: 24),
                                    
                                    // Last updated
                                    _buildLastUpdatedCard(weather, isSmallScreen),
                                    const SizedBox(height: 30),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 28 : 32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern app icon with gradient background
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.deepOrange.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 24 : 28),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.orange,
              size: isSmallScreen ? 52 : 60,
            ),
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Modern welcome text with gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, Colors.orange.shade200],
            ).createShader(bounds),
            child: Text(
              'Weather Forecast',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Your Personal Weather Companion',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 24 : 28),
          
          // Modern introduction text
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              'Discover real-time weather updates, detailed forecasts, and personalized insights to help you plan your day perfectly.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isSmallScreen ? 28 : 32),
          
          // Modern Get Started button with gradient
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.9),
                  Colors.deepOrange.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                _showGetStartedModal();
              },
              icon: Icon(
                Icons.rocket_launch,
                size: isSmallScreen ? 22 : 26,
              ),
              label: Text(
                'Get Started',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 18 : 22,
                  horizontal: 28,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlight(IconData icon, String title, String description, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }



  void _navigateToSearchView(WeatherProvider provider, bool isSmallScreen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header with back button and title
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: isSmallScreen ? 24 : 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Search Weather',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
                child: Column(
                  children: [
                    // Enhanced search bar
                    Container(
                      height: isSmallScreen ? 56 : 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter city name...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: isSmallScreen ? 16 : 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 20 : 24,
                            vertical: isSmallScreen ? 16 : 20,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.8),
                            size: isSmallScreen ? 24 : 28,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                provider.fetchWeatherByCity(_searchController.text);
                                _searchController.clear();
                                Navigator.pop(context);
                              }
                            },
                            icon: Icon(
                              Icons.send,
                              color: Colors.orange,
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            provider.fetchWeatherByCity(value);
                            _searchController.clear();
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Current location button
                    _buildQuickActionButton(
                      Icons.my_location,
                      'Use Current Location',
                      'Get weather for your exact position',
                      Colors.blue,
                      () async {
                        Navigator.pop(context);
                        if (provider.locationPermissionGranted) {
                          await provider.fetchWeatherByLocation();
                        } else {
                          await _requestLocationPermission();
                        }
                      },
                      isSmallScreen,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Popular cities section
                    Text(
                      'Popular Cities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Popular cities grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        final cities = [
                          {'name': 'New York', 'country': 'USA'},
                          {'name': 'London', 'country': 'UK'},
                          {'name': 'Tokyo', 'country': 'Japan'},
                          {'name': 'Paris', 'country': 'France'},
                          {'name': 'Mumbai', 'country': 'India'},
                          {'name': 'Dubai', 'country': 'UAE'},
                        ];
                        final city = cities[index];
                        
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            provider.fetchWeatherByCity(city['name'] as String);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: Colors.blue,
                                  size: isSmallScreen ? 24 : 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  city['name'] as String,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  city['country'] as String,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: isSmallScreen ? 10 : 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            SizedBox(width: isSmallScreen ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: isSmallScreen ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showGetStartedModal() {
    Navigator.pushNamed(context, '/menu');
  }

  Widget _buildOptionCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: isSmallScreen ? 24 : 28,
              ),
            ),
            SizedBox(width: isSmallScreen ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: isSmallScreen ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showPopularCities(BuildContext context, WeatherProvider provider, bool isSmallScreen) {
    final popularCities = [
      {'name': 'New York', 'country': 'USA', 'icon': Icons.location_city},
      {'name': 'London', 'country': 'UK', 'icon': Icons.location_city},
      {'name': 'Tokyo', 'country': 'Japan', 'icon': Icons.location_city},
      {'name': 'Paris', 'country': 'France', 'icon': Icons.location_city},
      {'name': 'Sydney', 'country': 'Australia', 'icon': Icons.location_city},
      {'name': 'Mumbai', 'country': 'India', 'icon': Icons.location_city},
      {'name': 'Dubai', 'country': 'UAE', 'icon': Icons.location_city},
      {'name': 'Singapore', 'country': 'Singapore', 'icon': Icons.location_city},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              child: Text(
                'Popular Cities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Cities grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: popularCities.length,
                itemBuilder: (context, index) {
                  final city = popularCities[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      provider.fetchWeatherByCity(city['name'] as String);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            city['icon'] as IconData,
                            color: Colors.blue,
                            size: isSmallScreen ? 24 : 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            city['name'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            city['country'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppSettings(BuildContext context, WeatherProvider provider, bool isSmallScreen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              child: Text(
                'App Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Settings options
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                children: [
                  _buildSettingOption(
                    Icons.dark_mode,
                    'Theme',
                    provider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                    () => provider.toggleTheme(),
                    isSmallScreen,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingOption(
                    Icons.thermostat,
                    'Temperature Unit',
                    provider.isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
                    () => provider.toggleTemperatureUnit(),
                    isSmallScreen,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingOption(
                    Icons.notifications,
                    'Notifications',
                    'Weather alerts & updates',
                    () {
                      // TODO: Implement notifications
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications coming soon!')),
                      );
                    },
                    isSmallScreen,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingOption(
                    Icons.language,
                    'Language',
                    'English',
                    () {
                      // TODO: Implement language selection
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Language selection coming soon!')),
                      );
                    },
                    isSmallScreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(width: isSmallScreen ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: isSmallScreen ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpAndTips(BuildContext context, bool isSmallScreen) {
    final tips = [
      {
        'icon': Icons.search,
        'title': 'Search Cities',
        'description': 'Type any city name in the search bar to get instant weather updates.',
        'color': Colors.blue,
      },
      {
        'icon': Icons.my_location,
        'title': 'Current Location',
        'description': 'Tap the location button to get weather for your exact position.',
        'color': Colors.green,
      },
      {
        'icon': Icons.dark_mode,
        'title': 'Theme Toggle',
        'description': 'Switch between light and dark themes using the theme button.',
        'color': Colors.purple,
      },
      {
        'icon': Icons.thermostat,
        'title': 'Temperature Units',
        'description': 'Toggle between Celsius and Fahrenheit using the unit button.',
        'color': Colors.orange,
      },
      {
        'icon': Icons.refresh,
        'title': 'Pull to Refresh',
        'description': 'Pull down on the screen to refresh weather data.',
        'color': Colors.teal,
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.grey[900]!.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              child: Text(
                'Help & Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Tips list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      color: (tip['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: (tip['color'] as Color).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: (tip['color'] as Color).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            tip['icon'] as IconData,
                            color: tip['color'] as Color,
                            size: isSmallScreen ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 16 : 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['title'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tip['description'] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildTopSection(WeatherProvider provider, bool isSmallScreen) {
    return Row(
      children: [
        // Back button (only show when weather data is available)
        if (provider.weather != null)
          Container(
            height: isSmallScreen ? 48 : 56,
            width: isSmallScreen ? 48 : 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white.withOpacity(0.8),
                size: isSmallScreen ? 20 : 24,
              ),
              onPressed: () => _goBackToWelcome(provider),
              tooltip: 'Back to welcome',
            ),
          ),
        if (provider.weather != null) const SizedBox(width: 12),
        
        // Search bar
        Expanded(
          child: Container(
            height: isSmallScreen ? 48 : 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search for a city...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 20,
                  vertical: isSmallScreen ? 12 : 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.8),
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  provider.fetchWeatherByCity(value);
                  _searchController.clear();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Location button
        Container(
          height: isSmallScreen ? 48 : 56,
          width: isSmallScreen ? 48 : 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(
              Icons.my_location,
              color: Colors.white.withOpacity(0.8),
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: provider.locationPermissionGranted
                ? provider.fetchWeatherByLocation
                : _requestLocationPermission,
            tooltip: 'Get current location',
          ),
        ),
        const SizedBox(width: 12),
        
        // Theme toggle
        Container(
          height: isSmallScreen ? 48 : 56,
          width: isSmallScreen ? 48 : 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(
              provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white.withOpacity(0.8),
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: provider.toggleTheme,
            tooltip: 'Toggle theme',
          ),
        ),
        const SizedBox(width: 8),
        
        // Temperature unit toggle
        Container(
          height: isSmallScreen ? 48 : 56,
          width: isSmallScreen ? 48 : 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(
              provider.isCelsius ? Icons.thermostat : Icons.thermostat_outlined,
              color: Colors.white.withOpacity(0.8),
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: provider.toggleTemperatureUnit,
            tooltip: 'Toggle temperature unit',
          ),
        ),
      ],
    );
  }

  void _goBackToWelcome(WeatherProvider provider) {
    // Clear weather data to show welcome screen
    provider.clearWeather();
  }

  Widget _buildLoadingCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 32 : 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: isSmallScreen ? 20 : 24),
          Text(
            'Loading weather data...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage, WeatherProvider provider, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: isSmallScreen ? 40 : 48,
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Unable to fetch weather',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => provider.refreshWeather(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => LocationService.openAppSettings(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherSection(Weather weather, bool isCelsius, bool isSmallScreen) {
    final provider = context.read<WeatherProvider>();
    final displayTemp = provider.getDisplayTemperature(weather.temperature);
    final unit = provider.getTemperatureUnit();

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // City name and date
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 24 : 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateTime.now().day} ${_getMonthName(DateTime.now().month)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Weather condition icon
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                ),
                child: Icon(
                  _getWeatherIcon(weather.mainCondition),
                  color: Colors.white,
                  size: isSmallScreen ? 32 : 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Temperature and condition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${displayTemp.round()}$unit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 48 : 56,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  Text(
                    weather.mainCondition ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Weather animation (optional)
              if (weather.mainCondition != null)
                SizedBox(
                  width: isSmallScreen ? 60 : 80,
                  height: isSmallScreen ? 60 : 80,
                  child: Lottie.asset(
                    _getWeatherAnimation(weather.mainCondition),
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(Weather weather, bool isCelsius, bool isSmallScreen) {
    final provider = context.read<WeatherProvider>();
    final displayFeelsLike = provider.getDisplayTemperature(weather.feelsLike);
    final unit = provider.getTemperatureUnit();

    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            Icons.thermostat,
            'Feels Like',
            '${displayFeelsLike.round()}$unit',
            Colors.orange,
            isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            Icons.water_drop,
            'Humidity',
            '${weather.humidity}%',
            Colors.blue,
            isSmallScreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            Icons.air,
            'Wind',
            '${weather.windSpeed.toStringAsFixed(1)} km/h',
            Colors.green,
            isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(IconData icon, String label, String value, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunsetCard(Weather weather, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sunrise
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                  ),
                  child: Icon(
                    Icons.wb_sunny,
                    color: Colors.orange,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sunrise',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.sunrise != null 
                      ? _formatTime(weather.sunrise!)
                      : 'N/A',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 60,
            width: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          
          // Sunset
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
                  ),
                  child: Icon(
                    Icons.nights_stay,
                    color: Colors.purple,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sunset',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.sunset != null 
                      ? _formatTime(weather.sunset!)
                      : 'N/A',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsGrid(Weather weather, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(
                Icons.grid_view,
                color: Colors.white.withOpacity(0.8),
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Weather Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 2-column grid layout with proper overflow handling
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: isSmallScreen ? 12 : 16,
            mainAxisSpacing: isSmallScreen ? 12 : 16,
            childAspectRatio: isSmallScreen ? 1.0 : 1.1, // Adjusted to prevent overflow
            children: [
              _buildDetailCard(
                Icons.water_drop,
                'Humidity',
                '${weather.humidity}%',
                weather.getHumidityLevel(),
                Colors.blue,
                isSmallScreen,
              ),
              _buildDetailCard(
                Icons.air,
                'Wind Speed',
                '${weather.windSpeed.toStringAsFixed(1)} km/h',
                weather.getWindCategory(),
                Colors.green,
                isSmallScreen,
              ),
              _buildDetailCard(
                Icons.wb_sunny,
                'UV Index',
                '${weather.uvIndex.toStringAsFixed(1)}',
                'Moderate',
                Colors.yellow,
                isSmallScreen,
              ),
              _buildDetailCard(
                Icons.air,
                'Air Quality',
                weather.airQuality,
                'Good',
                Colors.purple,
                isSmallScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value, String subtitle, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12), // Reduced padding to prevent overflow
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 10), // Reduced padding
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24), // Smaller icon
          ),
          SizedBox(height: isSmallScreen ? 6 : 8), // Reduced spacing
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 9 : 11, // Smaller font
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2), // Minimal spacing
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 14 : 16, // Smaller font
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1), // Minimal spacing
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isSmallScreen ? 7 : 9, // Smaller font
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherTipCard(Weather weather, bool isSmallScreen) {
    final condition = weather.mainCondition?.toLowerCase() ?? '';
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
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tipColor.withOpacity(0.2),
            tipColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(color: tipColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: tipColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
            decoration: BoxDecoration(
              color: tipColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
            ),
            child: Icon(tipIcon, color: tipColor, size: isSmallScreen ? 24 : 28),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather Tip',
                  style: TextStyle(
                    color: tipColor,
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedCard(Weather weather, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            color: Colors.white.withOpacity(0.7),
            size: isSmallScreen ? 18 : 20,
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Text(
            'Last updated: ${weather.getFormattedLastUpdated()}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getBackgroundGradient(String? mainCondition, bool isDarkMode) {
    if (isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
      );
    }

    if (mainCondition == null) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E9EAB), Color(0xFFEEF2F3)],
        );
      case 'rain':
      case 'drizzle':
      case 'shower rain':
      case 'thunderstorm':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
        );
      case 'snow':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE6DADA), Color(0xFF274046)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
        );
    }
  }

  IconData _getWeatherIcon(String? mainCondition) {
    if (mainCondition == null) return Icons.wb_sunny;
    
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
      case 'shower rain':
      case 'thunderstorm':
        return Icons.umbrella;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_sunny;
    }
  }

  String _getWeatherAnimation(String? mainCondition) {
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
      case 'thunderstorm':
        return 'assets/rain.json';
      case 'snow':
        return 'assets/snowfall.json';
      default:
        return 'assets/sunny.json';
    }
  }

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
