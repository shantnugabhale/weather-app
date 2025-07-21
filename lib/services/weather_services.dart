import 'package:weather_app/models/weather_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherServices {
  final String apiKey = '72a9ba3f40e7af40008ad23cc2dd18d9';

  Future<Weather> fetchWeather(String cityName) async {  // Fix: Corrected method name

    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      print("Error Response: ${response.body}");  // Debugging info
      throw Exception('Failed to load weather data');  // Fix: Corrected exception message
    }
  }
}
