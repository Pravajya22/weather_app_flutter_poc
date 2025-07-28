import 'package:flutter/material.dart';

class BottomSection extends StatelessWidget {
  final List<Map<String, String>> pastForecast;
  final List<Map<String, String>> futureForecast;

  const BottomSection({
    super.key,
    required this.pastForecast,
    required this.futureForecast,
  });

  Widget _buildForecastItem(Map<String, String> data) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data['day'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(data['icon'] ?? defaultWeatherIcon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            data['date'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            data['temp'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> combinedForecast = [
      ...pastForecast,
      ...futureForecast,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 8),
          child: Text(
            'Past & Upcoming Weather',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: combinedForecast.length,
            itemBuilder: (context, index) {
              return _buildForecastItem(combinedForecast[index]);
            },
          ),
        ),
      ],
    );
  }
}
