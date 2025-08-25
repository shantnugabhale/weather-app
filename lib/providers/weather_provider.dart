import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService('72a9ba3f40e7af40008ad23cc2dd18d9');
  
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCity = '';
  bool _isDarkMode = false;
  bool _isCelsius = true;
  bool _locationPermissionGranted = false;

  // Getters
  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;
  bool get isDarkMode => _isDarkMode;
  bool get isCelsius => _isCelsius;
  bool get locationPermissionGranted => _locationPermissionGranted;

  WeatherProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isCelsius = prefs.getBool('isCelsius') ?? true;
    _currentCity = prefs.getString('lastCity') ?? '';
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isCelsius', _isCelsius);
    if (_currentCity.isNotEmpty) {
      await prefs.setString('lastCity', _currentCity);
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _savePreferences();
    notifyListeners();
  }

  Future<void> toggleTemperatureUnit() async {
    _isCelsius = !_isCelsius;
    await _savePreferences();
    notifyListeners();
  }

  double getDisplayTemperature(double temperature) {
    if (_isCelsius) return temperature;
    return (temperature * 9 / 5) + 32;
  }

  String getTemperatureUnit() {
    return _isCelsius ? '°C' : '°F';
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    if (cityName.isEmpty) return;
    
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final weather = await _weatherService.getWeather(cityName);
      if (weather != null) {
        _weather = weather;
        _currentCity = cityName;
        await _savePreferences();
        _errorMessage = null;
      } else {
        _errorMessage = 'City not found. Please try again.';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWeatherByLocation() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final cityName = await _weatherService.getCurrentCity();
      if (cityName.isNotEmpty) {
        await fetchWeatherByCity(cityName);
        _locationPermissionGranted = true;
      } else {
        _errorMessage = 'Could not determine your location. Please enable location services.';
        _locationPermissionGranted = false;
      }
    } catch (e) {
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (errorMsg.contains('Coming soon')) {
        _errorMessage = 'Live location feature is coming soon!';
      } else {
        _errorMessage = errorMsg;
      }
      _locationPermissionGranted = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshWeather() async {
    if (_currentCity.isNotEmpty) {
      await fetchWeatherByCity(_currentCity);
    } else {
      await fetchWeatherByLocation();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setLocationPermission(bool granted) {
    _locationPermissionGranted = granted;
    notifyListeners();
  }

  void clearWeather() {
    _weather = null;
    _currentCity = '';
    _errorMessage = null;
    notifyListeners();
  }
}
