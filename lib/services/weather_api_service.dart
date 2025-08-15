// services/weather_api_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/current_weather_model.dart';

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
        if (data['name'] == null || data['main'] == null || data['weather'] == null) {
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
}
