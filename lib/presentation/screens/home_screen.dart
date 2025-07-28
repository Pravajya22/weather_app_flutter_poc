import 'package:flutter/material.dart';
import '../widgets/top_section.dart';
import '../widgets/middle_section.dart';
import '../widgets/bottom_section.dart';

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

  String _getBackgroundImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'sun':
        return 'assets/images/sunny.jpg';
      case 'rain':
        return 'assets/images/rainy.jpg';
      case 'clouds':
        return 'assets/images/cloudy.jpg';
      case 'snow':
        return 'assets/images/snowy.jpg';
      default:
        return 'assets/images/default.jpg';
    }
  }

  void _onSearch() {
    setState(() {
      city = _controller.text.trim().isEmpty
          ? 'Ahmedabad'
          : _controller.text.trim();
      weatherCondition = 'clouds'; // mock
      hasSearched = true;
    });
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
                    const TopSection(),
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
                        temperature: '31°C',
                        humidity: '58%',
                        windSpeed: '12 km/h',
                        weatherDescription: 'Cloudy',
                        weatherIcon: '☁️',
                        day: 'Friday',
                        date: '18 July 2025',
                      ),
                      const SizedBox(height: 20),
                      BottomSection(
                        pastForecast: [
                          {
                            'day': 'Tue',
                            'icon': '🌦️',
                            'date': '15 Jul',
                            'temp': '28°C',
                          },
                          {
                            'day': 'Wed',
                            'icon': '🌧️',
                            'date': '16 Jul',
                            'temp': '26°C',
                          },
                          {
                            'day': 'Thu',
                            'icon': '⛅',
                            'date': '17 Jul',
                            'temp': '27°C',
                          },
                        ],
                        futureForecast: [
                          {
                            'day': 'Sat',
                            'icon': '🌤️',
                            'date': '19 Jul',
                            'temp': '30°C',
                          },
                          {
                            'day': 'Sun',
                            'icon': '🌦️',
                            'date': '20 Jul',
                            'temp': '29°C',
                          },
                          {
                            'day': 'Mon',
                            'icon': '☀️',
                            'date': '21 Jul',
                            'temp': '31°C',
                          },
                        ],
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
