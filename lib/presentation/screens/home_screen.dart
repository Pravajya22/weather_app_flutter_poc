import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String weatherCondition; // e.g., 'Clear', 'Rain', etc.
  final String city;

  const HomeScreen({
    Key? key,
    required this.weatherCondition,
    this.city = 'Ahmedabad', // default value
  }) : super(key: key);

  String _getBackgroundImage(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
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

  @override
  Widget build(BuildContext context) {
    final String backgroundImage = _getBackgroundImage(weatherCondition);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          Center(
            child: Text(
              city,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}