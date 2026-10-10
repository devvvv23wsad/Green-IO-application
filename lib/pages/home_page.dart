import 'package:flutter/material.dart';
import '../widgets/app_bottom_nav.dart';

class HomePage extends StatelessWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    // เมนูแต่ละการ์ด
    final items = [
      {
        'title': 'พยากรณ์อากาศ',
        'route': '/weather',
        'icon': Icons.cloud_outlined,
      },
      {'title': 'ปริมาตรน้ำ', 'route': '/water', 'icon': Icons.opacity},
      {'title': 'ความชื้นในดิน', 'route': '/soil', 'icon': Icons.spa_outlined},
      {
        'title': 'วัดคุณภาพน้ำ',
        'route': '/tds',
        'icon': Icons.water_drop_outlined,
      },
    ];

    return Scaffold(
      // ไม่ใช้ AppBar เพราะมีดีไซน์พื้นหลัง + หัวข้อด้านบนเอง
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE9FBEF), // เขียวอ่อนด้านบน
              Color(0xFFC2F0CF),
              Color(0xFF8AD89F), // เขียวเข้มด้านล่าง
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // ชื่อแอปด้านบน
              const Text(
                'Green IQ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              // กริดการ์ด 2x2
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            // ปรับสัดส่วนให้การ์ดดูเล็กลงแต่ยังอ่านง่าย
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _MenuCard(
                          title: item['title'] as String,
                          icon: item['icon'] as IconData,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              item['route'] as String,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

// การ์ดเมนู 1 ช่อง (ขนาดเล็กลง มุมโค้ง ฟุ้ง ๆ)
class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 42, // เล็กกว่าของเดิมนิดหน่อย
              color: Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
