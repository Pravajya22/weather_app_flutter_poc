class CurrentWeather {
  final String cityName;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final String day;
  final String date;

  CurrentWeather({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.day,
    required this.date,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      json['dt'] * 1000,
      isUtc: true,
    ).toLocal();
    final String formattedDate =
        '${dateTime.day}-${dateTime.month}-${dateTime.year}';
    final String dayName = _getDayName(dateTime.weekday);

    return CurrentWeather(
      cityName: json['name'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      day: dayName,
      date: formattedDate,
    );
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
