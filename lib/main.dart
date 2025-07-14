import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart'; // Import your custom screen

void main() {
  runApp(
    const MaterialApp(
      home: HomeScreen(weatherCondition: 'Clear', city: 'Ahmedabad'),
      debugShowCheckedModeBanner: false,
    ),
  );
}