import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/services/location_service.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_slideController),
                  child: Column(
                    children: [
                      // Header with back button
                      _buildHeader(isSmallScreen),
                      
                      // Title section
                      _buildTitleSection(isSmallScreen),
                      
                      // Options section
                      Expanded(
                        child: _buildOptionsSection(weatherProvider, isSmallScreen),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          Container(
            height: isSmallScreen ? 44 : 52,
            width: isSmallScreen ? 44 : 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white.withOpacity(0.9),
                size: isSmallScreen ? 20 : 24,
              ),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.deepOrange.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.wb_sunny,
              color: Colors.orange,
              size: isSmallScreen ? 40 : 48,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'Choose Your Weather Experience',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Select how you\'d like to explore weather information',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(WeatherProvider weatherProvider, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          _buildOptionCard(
            context,
            Icons.search,
            'Search City',
            'Find weather for any city worldwide',
            Colors.blue,
            () => _navigateToSearchView(weatherProvider, isSmallScreen),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            Icons.my_location,
            'Current Location',
            LocationService.isLiveLocationAvailable 
                ? 'Get weather for your exact location'
                : 'Live location coming soon',
            LocationService.isLiveLocationAvailable ? Colors.green : Colors.grey,
            () => _handleCurrentLocation(weatherProvider),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            Icons.location_city,
            'Popular Cities',
            'Quick access to major cities',
            Colors.purple,
            () => _showPopularCities(context, weatherProvider, isSmallScreen),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            Icons.settings,
            'App Settings',
            'Customize your weather experience',
            Colors.orange,
            () => _showAppSettings(context, weatherProvider, isSmallScreen),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context,
            Icons.help_outline,
            'Help & Tips',
            'Learn how to use the app effectively',
            Colors.teal,
            () => _showHelpAndTips(context, isSmallScreen),
            isSmallScreen,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                  border: Border.all(color: color.withOpacity(0.4)),
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
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: isSmallScreen ? 16 : 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSearchView(WeatherProvider provider, bool isSmallScreen) {
    Navigator.pop(context);
    // Focus on search bar after navigation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        FocusScope.of(context).requestFocus(FocusNode());
      }
    });
  }

  void _handleCurrentLocation(WeatherProvider provider) async {
    if (!LocationService.isLiveLocationAvailable) {
      _showComingSoonDialog();
      return;
    }
    
    Navigator.pop(context);
    if (provider.locationPermissionGranted) {
      await provider.fetchWeatherByLocation();
    } else {
      await _requestLocationPermission(provider);
    }
  }

  Future<void> _requestLocationPermission(WeatherProvider provider) async {
    try {
      final granted = await LocationService.requestLocationPermission();
      if (granted) {
        provider.setLocationPermission(true);
        await provider.fetchWeatherByLocation();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission denied: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Text('Coming Soon!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live location feature is not available yet.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Text('We\'re working hard to bring you real-time location-based weather updates. For now, you can search for any city to get weather information.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it!', style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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
}
