import 'dart:async';
import 'package:flutter/material.dart';
import '../services/blynk_service.dart';
import '../widgets/app_bottom_nav.dart';

class SoilPage extends StatefulWidget {
  final String token;
  const SoilPage({super.key, required this.token});

  @override
  State<SoilPage> createState() => _SoilPageState();
}

class _SoilPageState extends State<SoilPage> {
  late BlynkService api;
  int? soilPercent; // ความชื้นในดิน (%) v2
  int? raw; // raw sensor (v21) ถ้ามี
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
        soilPercent = all['v2'] != null
            ? int.tryParse(all['v2'].toString())
            : null;
        raw = all['v21'] != null ? int.tryParse(all['v21'].toString()) : null;
      });
    } catch (e) {
      setState(() {
        soilPercent = null;
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
                'ความชื้นในดิน',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: h * 0.06),

              // ไอคอนต้นไม้ใหญ่
              Icon(Icons.spa_outlined, size: h * 0.18, color: Colors.black),
              SizedBox(height: h * 0.04),

              // ค่าเปอร์เซ็นต์ความชื้น
              Text(
                soilPercent != null ? '$soilPercent%' : '--%',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: h * 0.08),

              // ปุ่ม 2 ปุ่มตามภาพ
              _ActionButton(
                title: 'ตั้งค่ารดน้ำอัตโนมัติ',
                onTap: () {
                  // ใส่ฟังก์ชันที่ต้องการได้ตรงนี้ เช่นไปตั้งค่าที่หน้าอื่น
                },
              ),
              const SizedBox(height: 20),
              _ActionButton(
                title: 'รดน้ำทันที',
                onTap: () {
                  // ถ้าต้องการสั่งรดน้ำทันที ให้เรียก Blynk API เช่น:
                  // api.setPin("v5", "1"); แล้วค่อยสั่งปิดภายหลัง
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

// ปุ่มสไตล์ฟองน้ำเขียวจาง ๆ
class _ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ActionButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDFF8E7), Color(0xFFC6F3D3)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
