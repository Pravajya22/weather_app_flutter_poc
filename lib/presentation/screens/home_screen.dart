import 'package:flutter/material.dart';
import '../widgets/top_section.dart';
import '../widgets/middle_section.dart';
import '../widgets/bottom_section.dart';
import '../../services/weather_api_service.dart';
import '../../models/current_weather_model.dart';
import '../../models/forecast_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String city = 'Ahmedabad';
  String weatherCondition = 'default';
  final TextEditingController _controller = TextEditingController();
  bool hasSearched = false;
  DateTime? _lastApiCallTime;
  final Map<String, dynamic> _lastWeatherData = {};

  // dynamic values from API
  String temperature = '';
  String humidity = '';
  String windSpeed = '';
  String weatherDescription = '';
  String weatherIcon = '';
  String day = '';
  String date = '';

  String _getBackgroundImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'sun':
      case 'clear':
        return 'assets/images/sunny.jpg';
      case 'rain':
      case 'rainy':
        return 'assets/images/rainy.jpg';
      case 'clouds':
      case 'cloudy':
        return 'assets/images/cloudy.jpg';
      case 'snow':
        return 'assets/images/snowy.jpg';
      default:
        return 'assets/images/default.jpg';
    }
  }

  Future<void> _onSearch() async {
    final query = _controller.text.trim().isEmpty
        ? 'Ahmedabad'
        : _controller.text.trim();

    // Don't call API if we recently fetched data for this city
    if (_lastApiCallTime != null && 
        DateTime.now().difference(_lastApiCallTime!) < const Duration(minutes: 5) &&
        _lastWeatherData['city'] == query) {
      print('♻️ Using recent data, skipping API call');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using recently fetched data'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final service = WeatherApiService();
    
    try {
      final weather = await service.fetchCurrentWeather(query);

      if (weather != null) {
        setState(() {
          city = weather.cityName;
          weatherCondition = weather.mainCondition;
          temperature = '${weather.temperature}°C';
          humidity = '${weather.humidity}%';
          windSpeed = '${weather.windSpeed} km/h';
          weatherDescription = CurrentWeather.capitalizeDescription(
            weather.description,
          );
          weatherIcon = weather.icon;
          day = weather.day;
          date = weather.date;
          hasSearched = true;
          _lastApiCallTime = DateTime.now();
          _lastWeatherData['city'] = query;
          _lastWeatherData['weather'] = weather.toJson();
        });
      } else {
        // Try to load from cache as fallback
        _loadCachedData(query);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains('limit') 
            ? 'Daily limit reached. Using cached data if available.'
            : 'Error: ${e.toString()}'
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Try to load from cache as fallback
      _loadCachedData(query);
    }
  }

  Future<void> _loadCachedData(String query) async {
    try {
      // Create a new service instance to access cached data
      final service = WeatherApiService();
      
      // Since _getCachedCurrentWeather is private, we need to use fetchCurrentWeather
      // which will automatically use cached data if available due to our implementation
      final weather = await service.fetchCurrentWeather(query);
      
      if (weather != null) {
        setState(() {
          city = weather.cityName;
          weatherCondition = weather.mainCondition;
          temperature = '${weather.temperature}°C';
          humidity = '${weather.humidity}%';
          windSpeed = '${weather.windSpeed} km/h';
          weatherDescription = CurrentWeather.capitalizeDescription(
            weather.description,
          );
          weatherIcon = weather.icon;
          day = weather.day;
          date = weather.date;
          hasSearched = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Using cached data'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No cached data available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error loading cached data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading cached data'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String backgroundImage = hasSearched
        ? _getBackgroundImage(weatherCondition)
        : 'assets/images/default.jpg';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(backgroundImage, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TopSection(controller: _controller, onSearch: _onSearch),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: _onSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Get Weather',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasSearched) ...[
                      const SizedBox(height: 40),
                      MiddleSection(
                        city: city,
                        temperature: temperature,
                        humidity: humidity,
                        windSpeed: windSpeed,
                        weatherDescription: weatherDescription,
                        weatherIcon: weatherIcon,
                        day: day,
                        date: date,
                      ),
                      const SizedBox(height: 20),
                      BottomSection(
                        city: city,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}