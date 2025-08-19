// services/weather_api_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/current_weather_model.dart';
import '../models/forecast_model.dart';

class WeatherApiService {
  Future<CurrentWeather?> fetchCurrentWeather(String city) async {
    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      final baseUrl = dotenv.env['BASE_URL'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key is missing. Check your .env file.");
      }
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("Base URL is missing. Check your .env file.");
      }

      // ✅ Encode city to handle spaces/special chars
      final encodedCity = Uri.encodeComponent(city.trim());

      final url = Uri.parse(
        '${baseUrl}weather?q=$encodedCity&appid=$apiKey&units=metric',
      );

      print("📡 Requesting URL: $url"); // Debug log

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ API Response: $data");

        // Validate required fields
        if (data['name'] == null ||
            data['main'] == null ||
            data['weather'] == null) {
          print("❌ Missing required fields in API response");
          return null;
        }

        final weather = CurrentWeather.fromJson(data);
        print("📊 Parsed Weather Data:");
        print("   City: ${weather.cityName}");
        print("   Temperature: ${weather.temperature}°C");
        print("   Humidity: ${weather.humidity}%");
        print("   Wind Speed: ${weather.windSpeed} km/h");
        print("   Description: ${weather.description}");
        print("   Main Condition: ${weather.mainCondition}");
        print("   Icon: ${weather.icon}");

        return weather;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Unknown API error';
        print("❌ API Error: $message");
        print("📊 Status Code: ${response.statusCode}");
        print("📊 Response Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception in fetchCurrentWeather: $e");
      return null;
    }
  }

  Future<List<DailyForecast>?> fetchForecast(String city) async {
    try {
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
      final baseUrl = dotenv.env['BASE_URL'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception("API key is missing. Check your .env file.");
      }
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception("Base URL is missing. Check your .env file.");
      }

      final encodedCity = Uri.encodeComponent(city.trim());

      // Use 5-day forecast endpoint which works with standard API key
      final forecastUrl = Uri.parse(
        '${baseUrl}forecast?q=$encodedCity&appid=$apiKey&units=metric',
      );

      print("📡 Requesting forecast URL: $forecastUrl");

      final response = await http.get(forecastUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Raw Forecast Data: $data"); // Debug log
        final forecastList = data['list'] as List<dynamic>? ?? [];

        // Group forecasts by day and create daily summaries
        final Map<String, List<dynamic>> dailyForecasts = {};

        for (var forecast in forecastList) {
          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
            (forecast['dt'] as int) * 1000,
            isUtc: true,
          ).toLocal();

          print("Processing date: $dateTime"); // Debug log
          final String dateKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = [];
          }
          dailyForecasts[dateKey]!.add(forecast);
        }

        // Create daily forecasts from grouped data
        final List<DailyForecast> forecasts = [];

        for (var entry in dailyForecasts.entries.take(6)) {
          final parts = entry.key.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          final dateTime = DateTime(year, month, day);
          final List<dynamic> dayForecasts = entry.value;

          // Find max and min temps for the day
          double maxTemp = 0;
          double minTemp = 1000;
          double avgTemp = 0;
          double avgHumidity = 0;
          double avgWindSpeed = 0;

          for (var forecast in dayForecasts) {
            final temp = (forecast['main']['temp'] as num).toDouble();
            maxTemp = temp > maxTemp ? temp : maxTemp;
            minTemp = temp < minTemp ? temp : minTemp;
            avgTemp += temp;
            avgHumidity += (forecast['main']['humidity'] as num).toDouble();
            avgWindSpeed += (forecast['wind']['speed'] as num).toDouble();
          }

          avgTemp /= dayForecasts.length;
          avgHumidity /= dayForecasts.length;
          avgWindSpeed /= dayForecasts.length;

          // Use midday forecast for description and icon
          final middayForecast = dayForecasts[dayForecasts.length ~/ 2];
          final weatherData = middayForecast['weather'][0];

          forecasts.add(
            DailyForecast(
              day: _getDayName(dateTime.weekday),
              date:
                  '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}',
              maxTemp: maxTemp,
              minTemp: minTemp,
              temperature: avgTemp,
              humidity: avgHumidity.round(),
              windSpeed: avgWindSpeed,
              description: _capitalizeDescription(
                weatherData['description'] as String,
              ),
              mainCondition: weatherData['main'] as String,
              icon: weatherData['icon'] as String,
              feelsLike: (middayForecast['main']['feels_like'] as num)
                  .toDouble(),
              pressure: (middayForecast['main']['pressure'] as num).toDouble(),
              uvIndex: 0, // Not available in 5-day forecast
            ),
          );
        }

        print("✅ Forecast loaded: ${forecasts.length} days");
        print("Forecast Data: $forecasts"); // Debug log
        return forecasts;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Unknown API error';
        print("❌ Forecast API Error: $message");
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
        .map((word) {
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // New method to get extended forecast data for past and future days
  Future<Map<String, List<DailyForecast>>> getExtendedForecast(String city) async {
    try {
      final forecasts = await fetchForecast(city);
      
      if (forecasts == null || forecasts.isEmpty) {
        return {
          'past': [],
          'future': [],
        };
      }

      // Since OpenWeatherMap free API doesn't provide historical data,
      // we'll use the available forecast data and structure it appropriately
      
      // Get current date
      final now = DateTime.now();
      
      // Separate forecasts into past (mock) and future
      final List<DailyForecast> futureForecasts = [];
      final List<DailyForecast> pastForecasts = [];
      
      // Use the first 3 forecast days as "upcoming"
      futureForecasts.addAll(forecasts.take(3));
      
      // Create mock past days (since we don't have historical data)
      // In a real app, you'd use a historical weather API
      for (int i = 1; i <= 3; i++) {
        final pastDate = now.subtract(Duration(days: i));
        pastForecasts.add(
          DailyForecast(
            day: _getDayName(pastDate.weekday),
            date: '${pastDate.day.toString().padLeft(2, '0')}-${pastDate.month.toString().padLeft(2, '0')}',
            maxTemp: 25.0, // Mock data
            minTemp: 18.0, // Mock data
            temperature: 21.5, // Mock data
            humidity: 65, // Mock data
            windSpeed: 12.0, // Mock data
            description: 'Historical data not available',
            mainCondition: 'Clear',
            icon: '01d',
            feelsLike: 20.0,
            pressure: 1013.0,
            uvIndex: 5.0,
          ),
        );
      }

      return {
        'past': pastForecasts,
        'future': futureForecasts,
      };
    } catch (e) {
      print("⚠️ Exception in getExtendedForecast: $e");
      return {
        'past': [],
        'future': [],
      };
    }
  }
}
