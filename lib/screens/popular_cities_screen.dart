import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';

class PopularCitiesScreen extends StatefulWidget {
  const PopularCitiesScreen({super.key});

  @override
  State<PopularCitiesScreen> createState() => _PopularCitiesScreenState();
}

class _PopularCitiesScreenState extends State<PopularCitiesScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allCities = [
    {'name': 'New York', 'country': 'USA', 'icon': Icons.location_city, 'color': Colors.blue},
    {'name': 'London', 'country': 'UK', 'icon': Icons.location_city, 'color': Colors.indigo},
    {'name': 'Tokyo', 'country': 'Japan', 'icon': Icons.location_city, 'color': Colors.red},
    {'name': 'Paris', 'country': 'France', 'icon': Icons.location_city, 'color': Colors.purple},
    {'name': 'Dubai', 'country': 'UAE', 'icon': Icons.location_city, 'color': Colors.orange},
    {'name': 'Singapore', 'country': 'Singapore', 'icon': Icons.location_city, 'color': Colors.red},
    {'name': 'Sydney', 'country': 'Australia', 'icon': Icons.location_city, 'color': Colors.blue},
    {'name': 'Los Angeles', 'country': 'USA', 'icon': Icons.location_city, 'color': Colors.orange},
    {'name': 'Toronto', 'country': 'Canada', 'icon': Icons.location_city, 'color': Colors.red},
    {'name': 'Mumbai', 'country': 'India', 'icon': Icons.location_city, 'color': Colors.orange},
    {'name': 'Delhi', 'country': 'India', 'icon': Icons.location_city, 'color': Colors.green},
    {'name': 'Hong Kong', 'country': 'China', 'icon': Icons.location_city, 'color': Colors.red},
    {'name': 'Berlin', 'country': 'Germany', 'icon': Icons.location_city, 'color': Colors.yellow},
    {'name': 'Madrid', 'country': 'Spain', 'icon': Icons.location_city, 'color': Colors.red},
    {'name': 'Rome', 'country': 'Italy', 'icon': Icons.location_city, 'color': Colors.green},
    {'name': 'Amsterdam', 'country': 'Netherlands', 'icon': Icons.location_city, 'color': Colors.orange},
    {'name': 'Vienna', 'country': 'Austria', 'icon': Icons.location_city, 'color': Colors.red},
    {'name': 'Stockholm', 'country': 'Sweden', 'icon': Icons.location_city, 'color': Colors.blue},
    {'name': 'Copenhagen', 'country': 'Denmark', 'icon': Icons.location_city, 'color': Colors.red},
    {'name': 'Oslo', 'country': 'Norway', 'icon': Icons.location_city, 'color': Colors.red},
  ];

  List<Map<String, dynamic>> get _filteredCities {
    if (_searchQuery.isEmpty) {
      return _allCities;
    }
    return _allCities.where((city) {
      final name = city['name'].toString().toLowerCase();
      final country = city['country'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || country.contains(query);
    }).toList();
  }

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
                      
                      // Search bar
                      _buildSearchBar(isSmallScreen),
                      
                      // Title section
                      _buildTitleSection(isSmallScreen),
                      
                      // Cities grid
                      Expanded(
                        child: _buildCitiesGrid(weatherProvider, isSmallScreen),
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
              'Popular Cities',
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

  Widget _buildSearchBar(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: Container(
        height: isSmallScreen ? 48 : 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search cities...',
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
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white.withOpacity(0.8),
                      size: isSmallScreen ? 20 : 24,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
        ),
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
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.location_city,
              color: Colors.purple,
              size: isSmallScreen ? 32 : 40,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Text(
            'Top Cities Worldwide',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any city to get weather information',
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

  Widget _buildCitiesGrid(WeatherProvider weatherProvider, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20),
      child: _filteredCities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    color: Colors.white.withOpacity(0.5),
                    size: isSmallScreen ? 48 : 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cities found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 2 : 3,
                crossAxisSpacing: isSmallScreen ? 12 : 16,
                mainAxisSpacing: isSmallScreen ? 12 : 16,
                childAspectRatio: isSmallScreen ? 0.85 : 0.9,
              ),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                return _buildCityCard(city, weatherProvider, isSmallScreen);
              },
            ),
    );
  }

  Widget _buildCityCard(Map<String, dynamic> city, WeatherProvider weatherProvider, bool isSmallScreen) {
    final color = city['color'] as Color;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          weatherProvider.fetchWeatherByCity(city['name'] as String);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
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
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
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
                    city['icon'] as IconData,
                    color: color,
                    size: isSmallScreen ? 24 : 32,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  city['name'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  city['country'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isSmallScreen ? 10 : 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
