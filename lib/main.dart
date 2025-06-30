import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart'; // Import your custom screen
import 'package:weather_app_flutter_poc/presentation/screens/home_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(), // 👈 Use your screen here
    );
  }
}