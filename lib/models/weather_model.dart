class Weather {
  final String cityName;
  final double temperature;
  final String? mainCondition;
  final String? description;
  final int humidity;
  final double windSpeed;
  final double feelsLike;
  final int? sunrise;
  final int? sunset;

  Weather({
    required this.cityName,
    required this.temperature,
    this.mainCondition,
    this.description,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    this.sunrise,
    this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown City',
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      mainCondition: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['main']
          : 'Unknown',
      description: json['weather'] != null && json['weather'].isNotEmpty
          ? json['weather'][0]['description']
          : 'Unknown',
      humidity: (json['main']['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']['feels_like'] as num?)?.toDouble() ?? 0.0,
      sunrise: json['sys']?['sunrise'] as int?,
      sunset: json['sys']?['sunset'] as int?,
    );
  }
}
