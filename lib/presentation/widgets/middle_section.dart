import 'package:flutter/material.dart';

class MiddleSection extends StatelessWidget {
  final String city;
  final String temperature;
  final String humidity;
  final String windSpeed;
  final String weatherDescription;
  final String weatherIcon;
  final String day;
  final String date;

  const MiddleSection({
    super.key,
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.day,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            city,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$day, $date',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weatherIcon,
            style: const TextStyle(fontSize: 54),
          ),
          Text(
            weatherDescription,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            temperature,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoTile('Humidity', humidity),
              _buildInfoTile('Wind', windSpeed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}