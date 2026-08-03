// presentation/widgets/admin_top_bar.dart
import 'package:flutter/material.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  const AdminTopBar({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFF0A0F35),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search trips...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white70),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}