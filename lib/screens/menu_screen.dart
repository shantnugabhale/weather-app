import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/services/location_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

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
                      
                      // Menu options section
                      Expanded(
                        child: _buildMenuOptions(weatherProvider, isSmallScreen),
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
              'Weather Menu',
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
              Icons.menu,
              color: Colors.orange,
              size: isSmallScreen ? 40 : 48,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'Choose Your Option',
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

  Widget _buildMenuOptions(WeatherProvider weatherProvider, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          _buildMenuTile(
            context,
            Icons.search,
            'Search City',
            'Find weather for any city worldwide',
            Colors.blue,
            () => _navigateToSearch(),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
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
          _buildMenuTile(
            context,
            Icons.location_city,
            'Popular Cities',
            'Quick access to major cities worldwide',
            Colors.purple,
            () => _navigateToPopularCities(),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            context,
            Icons.settings,
            'App Settings',
            'Customize your weather experience',
            Colors.orange,
            () => _navigateToSettings(),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            context,
            Icons.help_outline,
            'Help & Tips',
            'Learn how to use the app effectively',
            Colors.teal,
            () => _navigateToHelp(),
            isSmallScreen,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
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
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isSmallScreen ? 24 : 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
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
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSmallScreen ? 28 : 32,
                ),
              ),
              SizedBox(width: isSmallScreen ? 20 : 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: isSmallScreen ? 18 : 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, '/search');
  }

  void _handleCurrentLocation(WeatherProvider provider) async {
    if (!LocationService.isLiveLocationAvailable) {
      _showComingSoonDialog();
      return;
    }
    
    Navigator.pushNamed(context, '/current-location');
  }

  void _navigateToPopularCities() {
    Navigator.pushNamed(context, '/popular-cities');
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToHelp() {
    Navigator.pushNamed(context, '/help');
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
}
