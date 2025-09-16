import 'package:flutter/material.dart';
import '../../models/forecast_model.dart';
import 'package:intl/intl.dart';

const String defaultWeatherIcon = '☀️';

class BottomSection extends StatelessWidget {
  final List<DailyForecast> pastForecast;
  final List<DailyForecast> futureForecast;

  const BottomSection({
    super.key,
    required this.pastForecast,
    required this.futureForecast,
  });

  // Get weather icon based on icon code
  String _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return '☀️';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return defaultWeatherIcon;
    }
  }

  // Individual forecast item UI
  Widget _buildDetailedForecastItem(DailyForecast forecast, bool isPast) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: isPast
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPast
              ? Colors.white.withOpacity(0.4)
              : Colors.white.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            forecast.day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPast ? Colors.white.withOpacity(0.8) : Colors.white,
              fontSize: 11,
            ),
          ),
          Text(
            forecast.date,
            style: TextStyle(
              color: isPast
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getWeatherIcon(forecast.icon),
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            '${forecast.maxTemp.toStringAsFixed(0)}°',
            style: TextStyle(
              color: isPast ? Colors.white.withOpacity(0.7) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${forecast.minTemp.toStringAsFixed(0)}°',
            style: TextStyle(
              color: isPast
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              forecast.description,
              style: TextStyle(
                color: isPast
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.8),
                fontSize: 7,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop,
                size: 8,
                color: Colors.lightBlue.withOpacity(0.8),
              ),
              const SizedBox(width: 2),
              Text(
                '${forecast.humidity}%',
                style: TextStyle(
                  color: isPast
                      ? Colors.white.withOpacity(0.6)
                      : Colors.white.withOpacity(0.8),
                  fontSize: 7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.air, size: 8, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 2),
              Text(
                '${forecast.windSpeed.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isPast
                      ? Colors.white.withOpacity(0.6)
                      : Colors.white.withOpacity(0.8),
                  fontSize: 7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime todayOnly = DateTime(now.year, now.month, now.day);

    print("Past Forecast (raw):");
    for (var f in pastForecast) {
      print("Past → ${f.date} → ${f.day}");
    }

    print("Future Forecast (raw):");
    for (var f in futureForecast) {
      print("Future → ${f.date} → ${f.day}");
    }

    // Helper to parse from dd-MM (like 20-08)
    DateTime parseDateString(String dateStr) {
      try {
        final parts = dateStr.split('-');
        if (parts.length == 2) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          return DateTime(now.year, month, day);
        }
      } catch (_) {}
      return todayOnly;
    }

    // Fix: Get 3 full past days excluding today
    List<DailyForecast> pastList =
        pastForecast
            .where((f) => parseDateString(f.date).isBefore(todayOnly))
            .toList()
          ..sort(
            (a, b) =>
                parseDateString(b.date).compareTo(parseDateString(a.date)),
          );

    // 🔥 Fix here: make sure we get up to 3
    List<DailyForecast> pastThree = pastList.length >= 3
        ? pastList.take(3).toList().reversed.toList()
        : pastList.reversed.toList();

    // Upcoming forecast (after today)
    List<DailyForecast> futureList =
        futureForecast
            .where((f) => parseDateString(f.date).isAfter(todayOnly))
            .toList()
          ..sort(
            (a, b) =>
                parseDateString(a.date).compareTo(parseDateString(b.date)),
          );
  
    List<DailyForecast> futureThree = futureList.take(3).toList();

    // Combine for display
    final List<DailyForecast> allForecasts = [...pastThree, ...futureThree];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (allForecasts.isNotEmpty) ...[
          _buildSectionHeader('Weekly Weather', Icons.calendar_today),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allForecasts.length,
              itemBuilder: (context, index) {
                final isPast = index < pastThree.length;
                return _buildDetailedForecastItem(allForecasts[index], isPast);
              },
            ),
          ),
        ],
        if (allForecasts.isEmpty) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No weather data available',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
