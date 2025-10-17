class DailyForecast {
  final String day;
  final String date;
  final double maxTemp;
  final double minTemp;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final String mainCondition;
  final String icon;
  final double feelsLike;
  final double pressure;
  final double uvIndex;

  DailyForecast({
    required this.day,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.feelsLike,
    required this.pressure,
    required this.uvIndex,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      (json['dt'] as int) * 1000,
      isUtc: true,
    ).toLocal();
    
    final String formattedDate =
        '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}';
    final String dayName = _getDayName(dateTime.weekday);

    final tempData = json['temp'] as Map<String, dynamic>? ?? {};
    final weatherData = json['weather'] as List<dynamic>? ?? [];
    final weatherItem = weatherData.isNotEmpty ? weatherData[0] as Map<String, dynamic> : {};
    
    return DailyForecast(
      day: dayName,
      date: formattedDate,
      maxTemp: (tempData['max'] as num?)?.toDouble() ?? 0.0,
      minTemp: (tempData['min'] as num?)?.toDouble() ?? 0.0,
      temperature: (tempData['day'] as num?)?.toDouble() ?? 0.0,
      humidity: (json['humidity'] as int?) ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      description: _capitalizeDescription((weatherItem['description'] as String?) ?? 'No description'),
      mainCondition: (weatherItem['main'] as String?) ?? 'Unknown',
      icon: (weatherItem['icon'] as String?) ?? '01d',
      feelsLike: (tempData['feels_like'] as num?)?.toDouble() ?? 0.0,
      pressure: (json['pressure'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['uvi'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  static String _capitalizeDescription(String description) {
    return description.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}