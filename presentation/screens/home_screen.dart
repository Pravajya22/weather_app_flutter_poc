import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _searchedCity;

  void _onSearch() {
    final city = _cityController.text.trim();

    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }

    setState(() {
      _searchedCity = city;
    });

    // We'll call API later from here
    print('Searching for: $city');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter City Name',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                hintText: 'e.g. Delhi, Mumbai, Tokyo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSearch,
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 30),
            if (_searchedCity != null)
              Column(
                children: [
                  const Text(
                    'Weather Info (Mock Display)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('City: $_searchedCity'),
                  const Text('Temperature: 25°C'),
                  const Text('Condition: Clear ☀️'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}