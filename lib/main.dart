import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart'; // Import your custom screen
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv for environment variables

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: ThemeData(fontFamily: 'Roboto', brightness: Brightness.light),
    );
  }
}