import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/location_service.dart';

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  // IMPORTANT: You will need a free API key from GeoDB Cities on RapidAPI for this to work.
  // Replace 'YOUR_GEODB_API_KEY' with your actual key.
  final String _geoDbApiKey = 'YOUR_GEODB_API_KEY';

  WeatherService(this.apiKey);

  /// Fetches weather data for a given city name from the OpenWeatherMap API.
  Future<Weather?> getWeather(String cityName) async {
    final url = Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Weather.fromJson(data);
      } else {
        print("Error fetching weather data. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('City not found or API error.');
      }
    } catch (e) {
      print("An error occurred in getWeather: $e");
      throw Exception('Failed to connect to the weather service. Please check your internet connection.');
    }
  }

  /// Fetches city suggestions from the GeoDB Cities API.
  Future<List<String>> getCitySuggestions(String query) async {
    if (_geoDbApiKey == 'YOUR_GEODB_API_KEY' || _geoDbApiKey.isEmpty) {
      print("GeoDB API key is not set. Skipping suggestions.");
      return []; // Return empty list if API key is not set
    }

    if (query.isEmpty) {
      return [];
    }

    final url = Uri.parse('https://wft-geo-db.p.rapidapi.com/v1/geo/cities?minPopulation=10000&namePrefix=$query');

    try {
      final response = await http.get(url, headers: {
        'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
        'x-rapidapi-key': _geoDbApiKey,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cities = data['data'];
        return cities.map<String>((city) => "${city['city']}, ${city['countryCode']}").toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching city suggestions: $e");
      return [];
    }
  }

  /// Determines the current city of the device using geolocation.
  Future<String> getCurrentCity() async {
    try {
      // Check if live location is available
      if (!LocationService.isLiveLocationAvailable) {
        throw Exception('Live location is not available yet. Coming soon!');
      }
      
      final cityName = await LocationService.getCurrentCity();
      return cityName ?? "";
    } catch (e) {
      print("An error occurred in getCurrentCity: $e");
      rethrow;
    }
  }
}
