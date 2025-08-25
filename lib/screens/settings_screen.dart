import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
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
                      
                      // Settings section
                      Expanded(
                        child: _buildSettingsSection(weatherProvider, isSmallScreen),
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
              'App Settings',
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
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.3),
                  Colors.deepOrange.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.settings,
              color: Colors.orange,
              size: isSmallScreen ? 32 : 40,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Customize Your Experience',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Adjust app settings to your preferences',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(WeatherProvider weatherProvider, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          _buildSettingCard(
            Icons.dark_mode,
            'Theme',
            weatherProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
            Colors.purple,
            () => weatherProvider.toggleTheme(),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            Icons.thermostat,
            'Temperature Unit',
            weatherProvider.isCelsius ? 'Celsius (°C)' : 'Fahrenheit (°F)',
            Colors.blue,
            () => weatherProvider.toggleTemperatureUnit(),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            Icons.notifications,
            'Notifications',
            'Weather alerts & updates',
            Colors.green,
            () => _showComingSoonSnackBar('Notifications'),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            Icons.language,
            'Language',
            'English',
            Colors.teal,
            () => _showComingSoonSnackBar('Language selection'),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            Icons.refresh,
            'Auto Refresh',
            'Every 30 minutes',
            Colors.orange,
            () => _showComingSoonSnackBar('Auto refresh settings'),
            isSmallScreen,
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            Icons.info_outline,
            'About',
            'App version & information',
            Colors.indigo,
            () => _showAboutDialog(isSmallScreen),
            isSmallScreen,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    IconData icon,
    String title,
    String subtitle,
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
                      subtitle,
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

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.orange.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAboutDialog(bool isSmallScreen) {
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
              Icon(Icons.info, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              Text('About Weather App', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version: 1.0.0', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('A beautiful weather app with real-time weather information for cities worldwide.', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
              const SizedBox(height: 12),
              Text('Features:', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('• Search any city worldwide\n• Beautiful weather animations\n• Dark/Light theme support\n• Temperature unit toggle\n• Responsive design', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
