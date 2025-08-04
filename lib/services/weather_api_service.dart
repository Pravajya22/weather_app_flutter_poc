import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/current_weather_model.dart';

class WeatherApiService {
  static final String? _apiKey = dotenv.env['API_KEY'];
  static final String? _baseUrl = dotenv.env['BASE_URL'];

  static Future<CurrentWeather?> fetchCurrentWeather(String cityName) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CurrentWeather.fromJson(data);
      } else {
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }
}
