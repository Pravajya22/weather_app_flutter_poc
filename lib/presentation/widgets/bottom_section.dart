// lib/presentation/widgets/bottom_section.dart
import 'package:flutter/material.dart';
import '../../models/forecast_model.dart';
import '../../services/weather_api_service.dart';
import 'package:intl/intl.dart';

const String defaultWeatherIcon = '☀️';

class BottomSection extends StatefulWidget {
  final String city;
  const BottomSection({super.key, required this.city});

  @override
  State<BottomSection> createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  final PageController _pageController = PageController(initialPage: 100);
  final WeatherApiService _apiService = WeatherApiService();

  final Map<int, List<DailyForecast>> _cachedWeeks = {};
  final Set<int> _loadingPages = {};
  final Map<int, ScrollController> _innerControllers = {};

  int _currentPage = 100;

  @override
  void initState() {
    super.initState();
    _fetchWeek(_currentPage);
    _preloadAround(_currentPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeCenterTodayOnPage(_currentPage);
    });
  }

  @override
  void didUpdateWidget(covariant BottomSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != oldWidget.city) {
      _cachedWeeks.clear();
      _loadingPages.clear();
      _innerControllers.forEach((_, controller) => controller.dispose());
      _innerControllers.clear();
      _currentPage = 100;
      _pageController.jumpToPage(100);
      _fetchWeek(_currentPage);
      _preloadAround(_currentPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _innerControllers.forEach((_, c) => c.dispose());
    _innerControllers.clear();
    super.dispose();
  }

  void _preloadAround(int page) {
    for (int i = -1; i <= 1; i++) {
      final idx = page + i;
      // Always attempt fetching regardless of direction
      if (!_cachedWeeks.containsKey(idx)) _fetchWeek(idx);
    }
  }

  DateTime _getWeekStartDate(int pageIndex) {
    final now = DateTime.now();
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    return currentMonday.add(Duration(days: (pageIndex - 100) * 7));
  }

  String _formatDdMm(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}';

  String _getDayShortName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  DailyForecast _makePlaceholder(DateTime date) {
    final day = _getDayShortName(date.weekday);
    final dateStr = _formatDdMm(date);
    return DailyForecast(
      day: day,
      date: dateStr,
      maxTemp: 0.0,
      minTemp: 0.0,
      temperature: 0.0,
      humidity: 0,
      windSpeed: 0.0,
      description: 'No data',
      mainCondition: 'Unknown',
      icon: '01d',
      feelsLike: 0.0,
      pressure: 0.0,
      uvIndex: 0.0,
    );
  }

  Future<void> _fetchWeek(int pageIndex) async {
    // No restriction on past/future weeks
    if (_cachedWeeks.containsKey(pageIndex) ||
        _loadingPages.contains(pageIndex)) {
      return;
    }
    _loadingPages.add(pageIndex);

    final start = _getWeekStartDate(pageIndex);
    final end = start.add(const Duration(days: 6));

    try {
      final fetched =
          await _apiService.getForecastForDateRange(widget.city, start, end);

      final Map<String, DailyForecast> byDate = {};
      for (var d in fetched) {
        byDate[d.date] = d;
      }

      final List<DailyForecast> weekList = [];
      for (int i = 0; i < 7; i++) {
        final dt = start.add(Duration(days: i));
        final key = _formatDdMm(dt);
        final item = byDate[key] ?? _makePlaceholder(dt);
        weekList.add(item);
      }

      if (mounted) {
        _innerControllers.putIfAbsent(pageIndex, () => ScrollController());
        setState(() {
          _cachedWeeks[pageIndex] = weekList;
        });
        if (pageIndex == _currentPage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeCenterTodayOnPage(pageIndex);
          });
        }
      }
    } catch (e) {
      final List<DailyForecast> weekList = List.generate(7, (i) {
        final dt = _getWeekStartDate(pageIndex).add(Duration(days: i));
        return _makePlaceholder(dt);
      });
      if (mounted) {
        _innerControllers.putIfAbsent(pageIndex, () => ScrollController());
        setState(() {
          _cachedWeeks[pageIndex] = weekList;
        });
      }
      print('⚠️ _fetchWeek error for $pageIndex: $e');
    } finally {
      _loadingPages.remove(pageIndex);
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _preloadAround(page);
    _innerControllers.putIfAbsent(page, () => ScrollController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeCenterTodayOnPage(page);
    });
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

  bool _isPast(DailyForecast forecast) {
    final today = DateTime.now();
    try {
      final parts = forecast.date.split('-');
      final fd = DateTime(today.year, int.parse(parts[1]), int.parse(parts[0]));
      final todayOnly = DateTime(today.year, today.month, today.day);
      return fd.isBefore(todayOnly);
    } catch (_) {
      return false;
    }
  }

  Widget _buildDetailedForecastItem(DailyForecast forecast, double itemWidth) {
    final isPast = _isPast(forecast);
    return Container(
      width: itemWidth,
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      decoration: BoxDecoration(
        color: isPast
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              forecast.day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPast ? Colors.white.withOpacity(0.85) : Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              forecast.date,
              style: TextStyle(
                color: isPast ? Colors.white.withOpacity(0.8) : Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _getWeatherIcon(forecast.icon),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 10),
            Text(
              '${forecast.maxTemp.toStringAsFixed(0)}°',
              style: TextStyle(
                color: isPast ? Colors.white.withOpacity(0.95) : Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${forecast.minTemp.toStringAsFixed(0)}°',
              style: TextStyle(
                color: isPast ? Colors.white.withOpacity(0.75) : Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: itemWidth - 12,
              child: Text(
                forecast.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPast
                      ? Colors.white.withOpacity(0.75)
                      : Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop,
                    size: 14, color: Colors.lightBlue.withOpacity(0.9)),
                const SizedBox(width: 6),
                Text('${forecast.humidity}%',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(width: 12),
                Icon(Icons.air, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text('${forecast.windSpeed.toStringAsFixed(0)}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _maybeCenterTodayOnPage(int pageIndex) {
    final week = _cachedWeeks[pageIndex];
    if (week == null || week.isEmpty) return;

    final today = DateTime.now();
    final todayKey = _formatDdMm(today);

    final todayIndex = week.indexWhere((d) => d.date == todayKey);
    if (todayIndex == -1) return;

    final controller =
        _innerControllers.putIfAbsent(pageIndex, () => ScrollController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      final box = context.findRenderObject() as RenderBox?;
      final parentWidth = box?.size.width ?? MediaQuery.of(context).size.width;
      double itemWidth = 110.0; // Fixed width for centering logic

      final double itemFullWidth = itemWidth + 14.0;
      final targetOffset = (todayIndex * itemFullWidth) -
          (parentWidth / 2) +
          (itemWidth / 2) +
          7;
      final clampedOffset =
          targetOffset.clamp(0.0, controller.position.maxScrollExtent);
      controller.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _buildWeekPage(BuildContext context, int pageIndex) {
    final week = _cachedWeeks[pageIndex];

    return LayoutBuilder(builder: (context, constraints) {
      double itemWidth = 110.0; // Fixed width for every card

      final controller =
          _innerControllers.putIfAbsent(pageIndex, () => ScrollController());

      if (week == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Loading week...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          height: constraints.maxHeight,
          child: ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: week.length,
            shrinkWrap: true,
            itemBuilder: (context, idx) {
              final forecast = week[idx];
              return _buildDetailedForecastItem(forecast, itemWidth);
            },
          ),
        ),
      );
    });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Weekly Forecast', Icons.calendar_today),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Center(
            child: Text(
              'Swipe left/right to move by week · Scroll inside week for day-level navigation',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: 301,
            itemBuilder: (context, pageIndex) {
              if (!_cachedWeeks.containsKey(pageIndex) &&
                  !_loadingPages.contains(pageIndex)) {
                _fetchWeek(pageIndex);
              }
              return _buildWeekPage(context, pageIndex);
            },
          ),
        ),
      ],
    );
  }
}
