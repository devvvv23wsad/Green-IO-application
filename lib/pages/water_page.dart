import 'dart:async';
import 'package:flutter/material.dart';
import '../services/blynk_service.dart';
import '../widgets/app_bottom_nav.dart';

class WaterPage extends StatefulWidget {
  final String token;
  const WaterPage({super.key, required this.token});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  late BlynkService api;
  int? waterPercent; // % ปริมาตรน้ำ จาก v1
  int? raw; // ค่า raw จาก v20 (ถ้ามี)
  Timer? timer;

  @override
  void initState() {
    super.initState();
    api = BlynkService(token: widget.token);
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      final all = await api.fetchAll();
      setState(() {
        waterPercent = all['v1'] != null
            ? int.tryParse(all['v1'].toString())
            : null;
        raw = all['v20'] != null ? int.tryParse(all['v20'].toString()) : null;
      });
    } catch (e) {
      setState(() {
        waterPercent = null;
        raw = null;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9FBEF), Color(0xFFC2F0CF), Color(0xFF8AD89F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'ปริมาตรน้ำ',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: h * 0.07),

              // ไอคอนแท็งก์น้ำใหญ่กลางจอ
              Icon(
                Icons.water_damage_outlined, // ใช้แทนรูปแท็งก์ในแบบ
                size: h * 0.22,
                color: Colors.black,
              ),

              SizedBox(height: h * 0.06),

              // แสดงเปอร์เซ็นต์ปริมาตรน้ำ
              Text(
                waterPercent != null ? '$waterPercent%' : '--%',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              // ถ้าอยากดูค่า raw แอบไว้เล็ก ๆ ด้านล่าง (ไม่มีก็ไม่โชว์)
              if (raw != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Raw: $raw',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],

              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
