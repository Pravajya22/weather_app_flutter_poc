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
      final DateTime dateTime = DateTime.now();
      final String formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
      final String dayName = _getDayName(dateTime.weekday);

      // Handle VirtualCrossing API response format
      final currentConditions = json['currentConditions'] as Map<String, dynamic>? ?? {};
      final address = json['address'] as String? ?? 'Unknown City';
      
      return CurrentWeather(
        cityName: address,
        temperature: (currentConditions['temp'] as num?)?.toDouble() ?? 0.0,
        humidity: (currentConditions['humidity'] as num?)?.round() ?? 0,
        windSpeed: (currentConditions['windspeed'] as num?)?.toDouble() ?? 0.0,
        description: capitalizeDescription((currentConditions['conditions'] as String?) ?? 'No description'),
        mainCondition: (currentConditions['icon'] as String?) ?? 'Unknown',
        icon: _mapVirtualCrossingIcon(currentConditions['icon'] as String? ?? 'clear-day'),
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

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'mainCondition': mainCondition,
      'icon': icon,
      'day': day,
      'date': date,
    };
  }

  static String _mapVirtualCrossingIcon(String virtualCrossingIcon) {
    const iconMap = {
      'clear-day': '01d',
      'clear-night': '01n',
      'partly-cloudy-day': '02d',
      'partly-cloudy-night': '02n',
      'cloudy': '03d',
      'overcast': '04d',
      'fog': '50d',
      'wind': '50d',
      'rain': '09d',
      'showers-day': '09d',
      'showers-night': '09n',
      'thunder-rain': '11d',
      'thunder-showers-day': '11d',
      'thunder-showers-night': '11n',
      'snow': '13d',
      'snow-showers-day': '13d',
      'snow-showers-night': '13n',
      'hail': '13d',
      'sleet': '13d',
    };
    
    return iconMap[virtualCrossingIcon] ?? '01d';
  }

  static String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}