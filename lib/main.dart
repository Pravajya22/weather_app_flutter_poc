import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart'; // Import your custom screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        city: 'Ahmedabad',
        weatherCondition: 'Clear', // Make sure this is passed
      ),
    );
  }
}