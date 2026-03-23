/// Matches backend [dashboard.WeatherResponse] JSON.
class WeatherResponse {
  const WeatherResponse({
    required this.locationName,
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.iconUrl,
  });

  final String locationName;
  final double temperature;
  final String condition;
  final String description;
  final int humidity;
  final String iconUrl;

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      locationName: json['location_name']?.toString() ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      condition: json['condition']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      iconUrl: json['icon_url']?.toString() ?? '',
    );
  }
}
