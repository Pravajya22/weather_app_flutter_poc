import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String baseUrl =
      "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline";

  static const String iconBaseUrl =
      "https://raw.githubusercontent.com/visualcrossing/WeatherIcons/main/PNG/2nd%20Set%20-%20Color";

  static String getIconUrl(String icon) => "$iconBaseUrl/$icon.png";

  static final String apiKey = dotenv.env['VIRTUALCROSSING_API_KEY'] ?? "";
}