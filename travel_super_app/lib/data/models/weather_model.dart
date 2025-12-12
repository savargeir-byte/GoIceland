class WeatherModel {
  const WeatherModel({
    required this.description,
    required this.temperature,
    required this.icon,
  });

  final String description;
  final double temperature;
  final String icon;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      description: (json['weather'] as List?)?.first['description'] as String? ?? '—',
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0,
      icon: (json['weather'] as List?)?.first['icon'] as String? ?? '01d',
    );
  }
}
