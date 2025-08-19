import 'package:flutter/material.dart';
import '../../models/forecast_model.dart';

const String defaultWeatherIcon = '☀️';

class BottomSection extends StatelessWidget {
  final List<DailyForecast> pastForecast;
  final List<DailyForecast> futureForecast;

  const BottomSection({
    super.key,
    required this.pastForecast,
    required this.futureForecast,
  });

  Widget _buildDetailedForecastItem(DailyForecast forecast, bool isPast) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: isPast 
            ? Colors.white.withOpacity(0.15) 
            : Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPast 
              ? Colors.white.withOpacity(0.3) 
              : Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Day and Date - reduced spacing
          Text(
            forecast.day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPast ? Colors.white.withOpacity(0.7) : Colors.white,
              fontSize: 10,
            ),
          ),
          Text(
            forecast.date,
            style: TextStyle(
              color: isPast ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
              fontSize: 8,
            ),
          ),
          
          const SizedBox(height: 2),
          
          // Weather Icon - reduced size
          Text(
            _getWeatherIcon(forecast.icon),
            style: const TextStyle(fontSize: 20),
          ),
          
          const SizedBox(height: 1),
          
          // Temperature - reduced font sizes
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
              color: isPast ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
          
          const SizedBox(height: 1),
          
          // Weather Description - more compact
          Text(
            forecast.description,
            style: TextStyle(
              color: isPast ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
              fontSize: 7,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 1),
          
          // Additional Details - more compact
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.water_drop, size: 8, color: Colors.lightBlue.withOpacity(0.8)),
              const SizedBox(width: 1),
              Text(
                '${forecast.humidity}%',
                style: TextStyle(
                  color: isPast ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
                  fontSize: 7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.air, size: 8, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 1),
              Text(
                '${forecast.windSpeed.toStringAsFixed(0)}',
                style: TextStyle(
                  color: isPast ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
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

  @override
  Widget build(BuildContext context) {
    // Get last 3 days from past forecast and first 3 days from future forecast
    final List<DailyForecast> recentPast = pastForecast.take(3).toList();
    final List<DailyForecast> upcomingFuture = futureForecast.take(3).toList();
    
    // Combine all forecasts into a single list
    final List<DailyForecast> allForecasts = [
      ...recentPast,
      ...upcomingFuture,
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Combined Weather Forecast Section
        if (allForecasts.isNotEmpty) ...[
          _buildSectionHeader('Weather Forecast', Icons.calendar_view_day),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: allForecasts.length,
              itemBuilder: (context, index) {
                final isPast = index < recentPast.length;
                return _buildDetailedForecastItem(allForecasts[index], isPast);
              },
            ),
          ),
        ],
        
        // Empty state
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
