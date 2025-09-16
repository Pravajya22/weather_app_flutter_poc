import 'package:flutter/material.dart';
import '../../models/forecast_model.dart';
import '../../services/weather_api_service.dart';

const String defaultWeatherIcon = '☀️';

class BottomSection extends StatefulWidget {
  final String city;

  const BottomSection({
    super.key,
    required this.city,
  });

  @override
  State<BottomSection> createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  final PageController _pageController = PageController(initialPage: 100);
  final WeatherApiService _apiService = WeatherApiService();
  final Map<int, List<DailyForecast>> _cachedWeeks = {};
  int _currentPage = 100;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWeek(_currentPage);
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page?.round() ?? _currentPage;
        });
        _fetchWeek(_currentPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeek(int pageIndex) async {
    if (_cachedWeeks.containsKey(pageIndex) || _isLoading) {
      return;
    }
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = firstDayOfWeek.add(Duration(days: (pageIndex - 100) * 7));
    final endDate = startDate.add(const Duration(days: 6));

    final weekForecast = await _apiService.getForecastForDateRange(
      widget.city,
      startDate,
      endDate,
    );

    setState(() {
      _cachedWeeks[pageIndex] = weekForecast;
      _isLoading = false;
    });
  }

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
    return Expanded(
      child: Container(
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

  bool _isPast(DailyForecast forecast) {
    final now = DateTime.now();
    try {
      final parts = forecast.date.split('-');
      final forecastDate = DateTime(now.year, int.parse(parts[1]), int.parse(parts[0]));
      return forecastDate.isBefore(DateTime(now.year, now.month, now.day));
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Weekly Weather', Icons.calendar_today),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 200,
            itemBuilder: (context, index) {
              final forecasts = _cachedWeeks[index];
              if (forecasts == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (forecasts.isEmpty) {
                return const Center(
                  child: Text('No data for this week.', style: TextStyle(color: Colors.white70)),
                );
              }
              return Row(
                children: forecasts.map((forecast) {
                  return _buildDetailedForecastItem(
                      forecast,
                      _isPast(forecast));
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}