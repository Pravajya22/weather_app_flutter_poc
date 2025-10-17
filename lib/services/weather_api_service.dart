import 'dart:convert';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/current_weather_model.dart';
import '../models/forecast_model.dart';
import '../core/api_constants.dart';
import '../services/rate_limiter.dart';
import '../services/api_usage_tracker.dart';

class WeatherApiService {
  static final CacheManager cacheManager = DefaultCacheManager();
  static final RateLimiter _rateLimiter = RateLimiter(const Duration(seconds: 2));

  Future<CurrentWeather?> fetchCurrentWeather(String city) async {
    try {
      // Check rate limiting
      if (!_rateLimiter.canCall('current_$city')) {
        print('⏳ Rate limited: Skipping API call for $city');
        return await _getCachedCurrentWeather(city);
      }

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
        
        // Cache the response
        await _cacheResponse('current_$city', response.body, const Duration(minutes: 30));
        
        // Track usage
        ApiUsageTracker.recordCall('current_weather');
        _rateLimiter.recordCall('current_$city');
        
        return CurrentWeather.fromJson(data);
      } else if (response.statusCode == 429) {
        print('❌ Rate limit exceeded for current weather');
        throw Exception('Daily API limit reached. Using cached data if available.');
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.body}");
        return await _getCachedCurrentWeather(city);
      }
    } catch (e) {
      print("⚠️ Exception in fetchCurrentWeather: $e");
      return await _getCachedCurrentWeather(city);
    }
  }

  Future<List<DailyForecast>> getForecastForDateRange(
    String city,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final cacheKey = 'forecast_${city}_${_formatDate(startDate)}_${_formatDate(endDate)}';
      
      // Check rate limiting
      if (!_rateLimiter.canCall(cacheKey)) {
        print('⏳ Rate limited: Skipping forecast API call');
        return await _getCachedForecast(cacheKey);
      }

      final apiKey = ApiConstants.apiKey;
      final baseUrl = ApiConstants.baseUrl;

      if (apiKey.isEmpty || baseUrl.isEmpty) {
        throw Exception("Missing API credentials.");
      }

      final encodedCity = Uri.encodeComponent(city.trim());
      final startDateStr = _formatDate(startDate);
      final endDateStr = _formatDate(endDate);

      final url = Uri.parse(
        '$baseUrl/$encodedCity/$startDateStr/$endDateStr?unitGroup=metric&key=$apiKey',
      );

      print("📡 Requesting Forecast: $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final days = data['days'] as List<dynamic>? ?? [];
        
        // Cache the response
        await _cacheResponse(cacheKey, response.body, const Duration(hours: 2));
        
        // Track usage
        ApiUsageTracker.recordCall('forecast');
        _rateLimiter.recordCall(cacheKey);
        
        return days.map((dayData) {
          final DateTime dateTime = DateTime.parse(dayData['datetime']);

          return DailyForecast(
            day: _getDayName(dateTime.weekday),
            date: '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}',
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
      } else if (response.statusCode == 429) {
        print('❌ Rate limit exceeded for forecast');
        return await _getCachedForecast(cacheKey);
      } else {
        print("❌ Forecast API Error: ${response.statusCode} - ${response.body}");
        return await _getCachedForecast(cacheKey);
      }
    } catch (e) {
      print("⚠️ Error in getForecastForDateRange: $e");
      return [];
    }
  }

  Future<void> _cacheResponse(String key, String response, Duration maxAge) async {
    try {
      await cacheManager.putFile(
        key,
        utf8.encode(response),
        maxAge: maxAge,
        fileExtension: 'json',
      );
      print('💾 Cached response for: $key');
    } catch (e) {
      print('⚠️ Error caching response: $e');
    }
  }

  Future<CurrentWeather?> _getCachedCurrentWeather(String city) async {
    try {
      final cacheKey = 'current_$city';
      final fileInfo = await cacheManager.getFileFromCache(cacheKey);
      
      if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
        print('📦 Using cached current weather for: $city');
        final cachedData = await fileInfo.file.readAsString();
        return CurrentWeather.fromJson(jsonDecode(cachedData));
      }
    } catch (e) {
      print('⚠️ Error reading cached current weather: $e');
    }
    return null;
  }

  Future<List<DailyForecast>> _getCachedForecast(String cacheKey) async {
    try {
      final fileInfo = await cacheManager.getFileFromCache(cacheKey);
      
      if (fileInfo != null && fileInfo.validTill.isAfter(DateTime.now())) {
        print('📦 Using cached forecast data for: $cacheKey');
        final cachedData = await fileInfo.file.readAsString();
        final data = jsonDecode(cachedData);
        final days = data['days'] as List<dynamic>? ?? [];
        
        return days.map((dayData) {
          final DateTime dateTime = DateTime.parse(dayData['datetime']);
          
          return DailyForecast(
            day: _getDayName(dateTime.weekday),
            date: '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}',
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
      }
    } catch (e) {
      print('⚠️ Error reading cached forecast: $e');
    }
    return [];
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