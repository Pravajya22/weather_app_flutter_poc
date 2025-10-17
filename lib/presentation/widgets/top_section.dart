import 'package:flutter/material.dart';
import 'dart:async';

class TopSection extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const TopSection({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection> {
  Timer? _debounceTimer;
  
  void _onSearchChanged(String value) {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (value.trim().isNotEmpty) {
        widget.onSearch();
      }
    });
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
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
            onChanged: _onSearchChanged,
            onSubmitted: (_) => widget.onSearch(),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: widget.onSearch,
        ),
      ],
    );
  }
}