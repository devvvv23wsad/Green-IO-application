import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    const routes = ['/weather', '/soil', '/', '/water', '/tds'];

    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final icons = <IconData>[
      Icons.cloud_outlined, // weather
      Icons.spa_outlined, // soil
      Icons.home_filled, // HOME (middle)
      Icons.water_damage_outlined, // water
      Icons.water_drop_outlined, // tds
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFDFF8E7),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(icons.length, (index) {
              final isActive = index == currentIndex;
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _onTap(context, index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Icon(
                    icons[index],
                    size: isActive ? 26 : 22,
                    color: isActive ? Colors.black : Colors.black54,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
