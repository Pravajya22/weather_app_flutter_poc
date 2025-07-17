import 'package:flutter/material.dart';

class MiddleSection extends StatelessWidget {
  final String city;
  final String temperature;
  final String condition;
  final String humidity;
  final String windSpeed;

  const MiddleSection({
    super.key,
    required this.city,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
  });

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'cloudy':
        return Icons.cloud;
      case 'sunny':
        return Icons.wb_sunny;
      case 'rain':
        return Icons.beach_access;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getWeatherIcon(condition);

    return Column(
      children: [
        Text(
          city,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          temperature,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(width: 8),
            Text(
              condition,
              style: const TextStyle(color: Colors.white70, fontSize: 22),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _infoTile('Humidity', humidity),
            _infoTile('Wind', windSpeed),
          ],
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}
