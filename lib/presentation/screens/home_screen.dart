import 'package:flutter/material.dart';
import '../widgets/top_section.dart';
import '../widgets/middle_section.dart';

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
      weatherCondition = 'clouds'; // mock for now
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const TopSection(),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter City Name',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (hasSearched) ...[
                            const SizedBox(height: 40),
                            MiddleSection(
                              city: city,
                              temperature: '32°C', // static mock
                              condition: 'Cloudy',
                              humidity: '60%',
                              windSpeed: '12 km/h',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
