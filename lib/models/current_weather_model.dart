class CurrentWeather {
  final String cityName;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final String mainCondition;
  final String icon;
  final String day;
  final String date;

  CurrentWeather({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.mainCondition,
    required this.icon,
    required this.day,
    required this.date,
  });

  static String capitalizeDescription(String description) {
    return description.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    try {
      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
        isUtc: true,
      ).toLocal();
      final String formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
      final String dayName = _getDayName(dateTime.weekday);

      // Validate and extract weather data with proper type checking
      final mainData = json['main'] as Map<String, dynamic>? ?? {};
      final weatherData = json['weather'] as List<dynamic>? ?? [];
      final windData = json['wind'] as Map<String, dynamic>? ?? {};
      
      final weatherItem = weatherData.isNotEmpty ? weatherData[0] as Map<String, dynamic> : {};
      
      return CurrentWeather(
        cityName: (json['name'] as String?) ?? 'Unknown City',
        temperature: (mainData['temp'] as num?)?.toDouble() ?? 0.0,
        humidity: (mainData['humidity'] as int?) ?? 0,
        windSpeed: (windData['speed'] as num?)?.toDouble() ?? 0.0,
        description: capitalizeDescription((weatherItem['description'] as String?) ?? 'No description'),
        mainCondition: (weatherItem['main'] as String?) ?? 'Unknown',
        icon: (weatherItem['icon'] as String?) ?? '01d',
        day: dayName,
        date: formattedDate,
      );
    } catch (e) {
      print('❌ Error parsing weather data: $e');
      print('📊 Raw JSON: $json');
      return CurrentWeather(
        cityName: 'Error',
        temperature: 0.0,
        humidity: 0,
        windSpeed: 0.0,
        description: 'Error loading data',
        mainCondition: 'Error',
        icon: '01d',
        day: 'Error',
        date: 'Error',
      );
    }
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
