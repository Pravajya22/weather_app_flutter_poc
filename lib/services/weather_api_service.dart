// weather_api_service.dart

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/current_weather_model.dart';
import '../models/forecast_model.dart';
import '../core/api_constants.dart';

class WeatherApiService {
  Future<CurrentWeather?> fetchCurrentWeather(String city) async {
    try {
      final apiKey = ApiConstants.apiKey;
      final baseUrl = ApiConstants.baseUrl;

      if (apiKey.isEmpty || baseUrl.isEmpty) {
        throw Exception("Missing API key or Base URL.");
      }

      final encodedCity = Uri.encodeComponent(city.trim());
      final url = Uri.parse(
        '$baseUrl/$encodedCity/today?unitGroup=metric&key=$apiKey',
      );

      print("📡 Requesting Current Weather: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CurrentWeather.fromJson(data);
      } else {
        print("❌ API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception in fetchCurrentWeather: $e");
      return null;
    }
  }

  Future<List<DailyForecast>> getForecastForDateRange(
      String city,
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final apiKey = ApiConstants.apiKey;
      final baseUrl = ApiConstants.baseUrl;

      if (apiKey.isEmpty || baseUrl.isEmpty) {
        throw Exception("Missing API credentials.");
      }

      final encodedCity = Uri.encodeComponent(city.trim());
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(endDate);

      // 🔥 CORRECTED URL CONSTRUCTION 🔥
      final url = Uri.parse(
        '$baseUrl/$encodedCity/$startDateStr/$endDateStr?unitGroup=metric&key=$apiKey',
      );
      
      print("📡 Requesting Forecast: $url");

      final response = await http.get(url);

      if (response.statusCode != 200) {
        print("❌ Forecast API Error");
        return [];
      }

      final data = jsonDecode(response.body);
      final days = data['days'] as List<dynamic>? ?? [];

      return days.map((dayData) {
        final DateTime dateTime = DateTime.parse(dayData['datetime']);

        return DailyForecast(
          day: _getDayName(dateTime.weekday),
          date:
          '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}',
          maxTemp: (dayData['tempmax'] as num?)?.toDouble() ?? 0.0,
          minTemp: (dayData['tempmin'] as num?)?.toDouble() ?? 0.0,
          temperature: (dayData['temp'] as num?)?.toDouble() ?? 0.0,
          humidity: (dayData['humidity'] as num?)?.round() ?? 0,
          windSpeed: (dayData['windspeed'] as num?)?.toDouble() ?? 0.0,
          description: _capitalizeDescription(
            (dayData['conditions'] as String?) ?? 'No description',
          ),
          mainCondition: (dayData['icon'] as String?) ?? 'Unknown',
          icon: _mapVirtualCrossingIcon(
            dayData['icon'] as String? ?? 'clear-day',
          ),
          feelsLike: (dayData['feelslike'] as num?)?.toDouble() ?? 0.0,
          pressure: (dayData['pressure'] as num?)?.toDouble() ?? 0.0,
          uvIndex: (dayData['uvindex'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
      print("⚠️ Error in getForecastForDateRange: $e");
      return [];
    }
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  static String _capitalizeDescription(String description) {
    return description
        .split(' ')
        .map(
          (word) =>
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
    )
        .join(' ');
  }

  static String _mapVirtualCrossingIcon(String icon) {
    const iconMap = {
      'clear-day': '01d',
      'clear-night': '01n',
      'partly-cloudy-day': '02d',
      'partly-cloudy-night': '02n',
      'cloudy': '03d',
      'overcast': '04d',
      'fog': '50d',
      'wind': '50d',
      'rain': '09d',
      'showers-day': '09d',
      'showers-night': '09n',
      'thunder-rain': '11d',
      'thunder-showers-day': '11d',
      'thunder-showers-night': '11n',
      'snow': '13d',
      'snow-showers-day': '13d',
      'snow-showers-night': '13n',
      'hail': '13d',
      'sleet': '13d',
    };
    return iconMap[icon] ?? '01d';
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}