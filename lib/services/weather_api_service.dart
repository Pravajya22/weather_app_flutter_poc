import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/current_weather_model.dart';
import '../models/forecast_model.dart';
import '../core/api_constants.dart';

class WeatherApiService {
  Future<CurrentWeather?> fetchCurrentWeather(String city) async {
    try {
      final apiKey = dotenv.env['VIRTUALCROSSING_API_KEY'];
      final baseUrl = dotenv.env['VIRTUALCROSSING_BASE_URL'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key is missing. Check your .env file.");
      }
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("Base URL is missing. Check your .env file.");
      }

      final encodedCity = Uri.encodeComponent(city.trim());
      final url = Uri.parse(
        '${baseUrl}${encodedCity}/today?unitGroup=metric&key=$apiKey',
      );

      print("📡 Requesting URL: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = CurrentWeather.fromJson(data);
        return weather;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Unknown API error';
        print("❌ API Error: $message");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception in fetchCurrentWeather: $e");
      return null;
    }
  }

  Future<List<DailyForecast>?> fetchForecast(String city) async {
    try {
      final apiKey = dotenv.env['VIRTUALCROSSING_API_KEY'];
      final baseUrl = dotenv.env['VIRTUALCROSSING_BASE_URL'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key is missing. Check your .env file.");
      }
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("Base URL is missing. Check your .env file.");
      }

      final encodedCity = Uri.encodeComponent(city.trim());
      final forecastUrl = Uri.parse(
        '${baseUrl}${encodedCity}?unitGroup=metric&key=$apiKey',
      );

      print("📡 Requesting forecast URL: $forecastUrl");

      final response = await http.get(forecastUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<DailyForecast> forecasts = [];
        final days = data['days'] as List<dynamic>? ?? [];

        for (int i = 0; i < days.length && i < 7; i++) {
          final dayData = days[i];
          final dateTime = DateTime.parse(dayData['datetime']);

          forecasts.add(
            DailyForecast(
              day: _getDayName(dateTime.weekday),
              date:
                  '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}',
              maxTemp: (dayData['tempmax'] as num).toDouble(),
              minTemp: (dayData['tempmin'] as num).toDouble(),
              temperature: (dayData['temp'] as num).toDouble(),
              humidity: (dayData['humidity'] as num).round(),
              windSpeed: (dayData['windspeed'] as num).toDouble(),
              description: _capitalizeDescription(
                dayData['description'] as String? ?? 'No description',
              ),
              mainCondition: dayData['icon'] as String? ?? 'Unknown',
              icon: _mapVirtualCrossingIcon(
                dayData['icon'] as String? ?? 'clear-day',
              ),
              feelsLike: (dayData['feelslike'] as num).toDouble(),
              pressure: (dayData['pressure'] as num).toDouble(),
              uvIndex: (dayData['uvindex'] as num).toDouble(),
            ),
          );
        }

        return forecasts;
      } else {
        print("❌ Forecast API error");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception in fetchForecast: $e");
      return null;
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

  static String _mapVirtualCrossingIcon(String virtualCrossingIcon) {
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

    return iconMap[virtualCrossingIcon] ?? '01d';
  }

  // ✅ Corrected: Get 3 past (excluding today) and 3 future days
  Future<Map<String, List<DailyForecast>>> getExtendedForecast(
    String city,
  ) async {
    try {
      final apiKey = ApiConstants.apiKey;
      final baseUrl = ApiConstants.baseUrl;

      if (apiKey == null || baseUrl == null) {
        throw Exception("Missing API credentials.");
      }

      final encodedCity = Uri.encodeComponent(city.trim());
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final startDate = today.subtract(const Duration(days: 3));
      final endDate = today.add(const Duration(days: 3));

      final dateFormat =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateFormat =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final historicalUrl = Uri.parse(
        '${baseUrl}${encodedCity}/$dateFormat/$endDateFormat?unitGroup=metric&key=$apiKey',
      );

      final response = await http.get(historicalUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final days = data['days'] as List<dynamic>? ?? [];

        final past = <DailyForecast>[];
        final future = <DailyForecast>[];

        for (final dayData in days) {
          final dateTime = DateTime.parse(dayData['datetime']);
          if (dateTime.isAtSameMomentAs(today)) continue; // Exclude today

          final forecast = DailyForecast(
            day: _getDayName(dateTime.weekday),
            date:
                '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}',
            maxTemp: (dayData['tempmax'] as num).toDouble(),
            minTemp: (dayData['tempmin'] as num).toDouble(),
            temperature: (dayData['temp'] as num).toDouble(),
            humidity: (dayData['humidity'] as num).round(),
            windSpeed: (dayData['windspeed'] as num).toDouble(),
            description: _capitalizeDescription(
              dayData['description'] as String? ?? 'No description',
            ),
            mainCondition: dayData['icon'] as String? ?? 'Unknown',
            icon: _mapVirtualCrossingIcon(
              dayData['icon'] as String? ?? 'clear-day',
            ),
            feelsLike: (dayData['feelslike'] as num).toDouble(),
            pressure: (dayData['pressure'] as num).toDouble(),
            uvIndex: (dayData['uvindex'] as num).toDouble(),
          );

          if (dateTime.isBefore(today)) {
            past.add(forecast);
          } else {
            future.add(forecast);
          }
        }

        past.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
        future.sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));

        return {
          'past': past.take(3).toList(),
          'future': future.take(3).toList(),
        };
      } else {
        print("❌ Historical API Error");
        return {'past': [], 'future': []};
      }
    } catch (e) {
      print("⚠️ Error in getExtendedForecast: $e");
      return {'past': [], 'future': []};
    }
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      DateTime.now().year,
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }
}
