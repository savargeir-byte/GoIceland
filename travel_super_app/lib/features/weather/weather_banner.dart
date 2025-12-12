import 'package:flutter/material.dart';

import '../../core/services/location_service.dart';
import '../../core/services/weather_service.dart';
import '../../data/models/weather_model.dart';

class WeatherBanner extends StatefulWidget {
  const WeatherBanner({super.key});

  @override
  State<WeatherBanner> createState() => _WeatherBannerState();
}

class _WeatherBannerState extends State<WeatherBanner> {
  final _weatherService = WeatherService();
  final _locationService = LocationService();
  late Future<WeatherModel> _future;

  static const double _defaultLat = 64.1466;
  static const double _defaultLon = -21.9426;
  static const WeatherModel _fallbackWeather = WeatherModel(
    description: 'Reykjavík • partly cloudy',
    temperature: 8,
    icon: '03d',
  );

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<WeatherModel> _load() async {
    try {
      final position = await _locationService.currentPosition();
      final lat = position?.latitude ?? _defaultLat;
      final lon = position?.longitude ?? _defaultLon;
      final weather = await _weatherService.fetchWeather(lat: lat, lon: lon);
      return weather ?? _fallbackWeather;
    } catch (_) {
      return _fallbackWeather;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherModel>(
      future: _future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final weather = snapshot.data ?? _fallbackWeather;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90E2), Color(0xFF6CD4A5)],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.description,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°C',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
              isLoading
                  ? const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () => setState(() => _future = _load()),
                    ),
            ],
          ),
        );
      },
    );
  }
}
