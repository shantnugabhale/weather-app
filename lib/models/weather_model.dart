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
  final double pressure;
  final int visibility;
  final double uvIndex;
  final String airQuality;
  final DateTime lastUpdated;

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
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.airQuality,
    required this.lastUpdated,
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
      pressure: (json['main']['pressure'] as num?)?.toDouble() ?? 1013.25,
      visibility: (json['visibility'] as num?)?.toInt() ?? 10000,
      uvIndex: 5.0, // Default UV index (OpenWeatherMap doesn't provide this in free tier)
      airQuality: _getAirQualityFromPressure((json['main']['pressure'] as num?)?.toDouble() ?? 1013.25),
      lastUpdated: DateTime.now(),
    );
  }

  static String _getAirQualityFromPressure(double pressure) {
    if (pressure < 1000) return 'Low';
    if (pressure < 1013) return 'Moderate';
    if (pressure < 1025) return 'Good';
    return 'Excellent';
  }

  String getFormattedLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  String getWindDirection() {
    // This would need wind direction data from API
    return 'N'; // Default
  }

  String getHumidityLevel() {
    if (humidity < 30) return 'Low';
    if (humidity < 60) return 'Moderate';
    if (humidity < 80) return 'High';
    return 'Very High';
  }

  String getWindCategory() {
    if (windSpeed < 5) return 'Light';
    if (windSpeed < 15) return 'Moderate';
    if (windSpeed < 25) return 'Strong';
    return 'Very Strong';
  }
}
