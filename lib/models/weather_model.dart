class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final int sunrise;
  final int sunset;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'] - 273.15, // Convert from Kelvin to Celsius
      description: json['weather'][0]['description'], // Fix: Access first element of the list
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'], // Fix: Corrected variable name
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'], // Fix: Corrected from sunrise to sunset
    );
  }
}
