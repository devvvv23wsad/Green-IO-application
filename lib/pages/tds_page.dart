import 'dart:async';
import 'package:flutter/material.dart';
import '../services/blynk_service.dart';
import '../widgets/app_bottom_nav.dart';

class TDSPage extends StatefulWidget {
  final String token;
  const TDSPage({super.key, required this.token});

  @override
  State<TDSPage> createState() => _TDSPageState();
}

class _TDSPageState extends State<TDSPage> {
  late BlynkService api;
  double? tds; // ค่า TDS (ppm) จาก v3
  int? raw; // ค่า raw จาก v22 (ถ้ามี)
  Timer? timer;

  @override
  void initState() {
    super.initState();
    api = BlynkService(token: widget.token);
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      final all = await api.fetchAll();
      setState(() {
        tds = all['v3'] != null ? double.tryParse(all['v3'].toString()) : null;
        raw = all['v22'] != null ? int.tryParse(all['v22'].toString()) : null;
      });
    } catch (e) {
      setState(() {
        tds = null;
        raw = null;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // แปลงค่า TDS → index 0..4 เพื่อเลือกหน้าอารมณ์/สี
  int _qualityIndex(double value) {
    if (value <= 150) return 4; // ดีเยี่ยม
    if (value <= 300) return 3; // ดี
    if (value <= 500) return 2; // พอใช้
    if (value <= 1000) return 1; // แย่
    return 0; // แย่มาก
  }

  @override
  Widget build(BuildContext context) {
    final qualityFaces = [
      {'emoji': '😵', 'color': const Color(0xFFE53935)}, // แย่มาก
      {'emoji': '😟', 'color': const Color(0xFFF57C00)}, // แย่
      {'emoji': '😐', 'color': const Color(0xFFFFC107)}, // พอใช้
      {'emoji': '🙂', 'color': const Color(0xFF8BC34A)}, // ดี
      {'emoji': '😁', 'color': const Color(0xFF4CAF50)}, // ดีเยี่ยม
    ];

    final idx = (tds != null) ? _qualityIndex(tds!) : -1;

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;

              return Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'วัดคุณภาพน้ำ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: h * 0.06),
                  // ไอคอนใหญ่กลางจอ (ใช้ water_drop แทนรูปในดีไซน์)
                  Icon(
                    Icons.water_drop_outlined,
                    size: h * 0.2,
                    color: Colors.black,
                  ),
                  SizedBox(height: h * 0.05),
                  // แถวอีโมจิ + bar rating
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(qualityFaces.length, (i) {
                            final face = qualityFaces[i];
                            final isActive = i == idx;
                            return Column(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: face['color'] as Color,
                                  child: Text(
                                    face['emoji'] as String,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _RatingDots(
                                  count: 5,
                                  // ทำให้ช่องที่ active มีจุดมากสุด
                                  filled: i + 1,
                                  isActive: isActive,
                                ),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        // แสดงค่า TDS จริงด้านล่าง
                        if (tds != null)
                          Text(
                            'TDS: ${tds!.toStringAsFixed(1)} ppm',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          const Text(
                            'กำลังรอข้อมูลเซ็นเซอร์...',
                            style: TextStyle(fontSize: 16),
                          ),
                        if (raw != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Raw: $raw',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

// bar เล็ก ๆ ใต้หน้าอีโมจิ
class _RatingDots extends StatelessWidget {
  final int count;
  final int filled;
  final bool isActive;

  const _RatingDots({
    required this.count,
    required this.filled,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.black;
    final inactiveColor = Colors.black.withOpacity(0.25);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final color = i < filled
            ? (isActive ? activeColor : inactiveColor)
            : inactiveColor;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
