import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../data/models/weather_model.dart';

class WeatherService {
  final _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel?> fetchWeather(
      {required double lat, required double lon}) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    final uri =
        Uri.parse('$_baseUrl?lat=$lat&lon=$lon&units=metric&appid=$apiKey');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    return WeatherModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }
}
