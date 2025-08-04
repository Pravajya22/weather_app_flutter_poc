import 'package:flutter/material.dart';
import '../widgets/top_section.dart';
import '../widgets/middle_section.dart';
import '../widgets/bottom_section.dart';
import '../../services/weather_api_service.dart';
import '../../models/current_weather_model.dart';

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
    String query = _controller.text.trim().isEmpty
        ? 'Ahmedabad'
        : _controller.text.trim();

    final weather = await WeatherApiService.fetchCurrentWeather(query);

    if (weather != null) {
      setState(() {
        city = weather.cityName;
        weatherCondition = weather.description;
        temperature = '${weather.temperature}°C';
        humidity = '${weather.humidity}%';
        windSpeed = '${weather.windSpeed} km/h';
        weatherDescription = weather.description;
        weatherIcon = weather.icon;
        day = weather.day;
        date = weather.date;
        hasSearched = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City not found or API error!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String backgroundImage = _getBackgroundImage(weatherCondition);

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
                      const BottomSection(pastForecast: [], futureForecast: []),
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