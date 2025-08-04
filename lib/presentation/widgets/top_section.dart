import 'package:flutter/material.dart';

class TopSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const TopSection({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter City / State / Country',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => onSearch(),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: onSearch,
        ),
      ],
    );
  }
}