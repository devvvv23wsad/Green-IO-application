import 'dart:async';
import 'package:flutter/material.dart';
import '../services/blynk_service.dart';
import '../widgets/app_bottom_nav.dart';

class WeatherPage extends StatefulWidget {
  final String token;
  const WeatherPage({super.key, required this.token});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late BlynkService api;
  double? temp; // อุณหภูมิ (°C) จาก v11
  int? hum; // ความชื้นในอากาศ (%) จาก v12
  int? rainPercent; // ตอนนี้ยังไม่มีจาก Blynk จะโชว์ --%
  Timer? timer;

  @override
  void initState() {
    super.initState();
    api = BlynkService(token: widget.token);
    fetchData();
    timer = Timer.periodic(const Duration(seconds: 30), (_) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      final all = await api.fetchAll();
      setState(() {
        temp = all['v11'] != null
            ? double.tryParse(all['v11'].toString())
            : null;
        hum = all['v12'] != null ? int.tryParse(all['v12'].toString()) : null;
        // ถ้าอนาคตเพิ่ม datastream ฝน เช่น v13 ค่อย map มาเติมตรงนี้
        rainPercent = null;
      });
    } catch (e) {
      // ถ้า error ให้เคลียร์ค่า
      setState(() {
        temp = null;
        hum = null;
        rainPercent = null;
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
              final screenHeight = constraints.maxHeight;

              return Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'พยากรณ์อากาศ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  // ไอคอนเมฆ+พระอาทิตย์ใหญ่ ๆ
                  Icon(
                    Icons.wb_cloudy_outlined,
                    size: screenHeight * 0.18,
                    color: Colors.black,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // อุณหภูมิ
                  Text(
                    temp != null ? '${temp!.toStringAsFixed(0)}°' : '--°',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  // ความชื้น + ปริมาตรน้ำฝน (ตอนนี้ฝนเป็น --%)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'ความชื้นในอากาศ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hum != null ? '$hum%' : '--%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'ปริมาตรน้ำฝน',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rainPercent != null ? '$rainPercent%' : '--%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  // เส้นกราฟแบบสไตล์ในภาพ + เวลา
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 60,
                          width: double.infinity,
                          child: CustomPaint(painter: _WeatherLinePainter()),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('9am'),
                            Text('12pm'),
                            Text('3pm'),
                            Text('6pm'),
                          ],
                        ),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

// วาดเส้นกราฟแบบโค้งง่าย ๆ ให้คล้ายภาพตัวอย่าง
class _WeatherLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // เส้นกราฟโค้ง ๆ
    path.moveTo(0, h * 0.7);
    path.quadraticBezierTo(w * 0.25, h * 0.5, w * 0.5, h * 0.7);
    path.quadraticBezierTo(w * 0.75, h * 0.9, w, h * 0.6);
    canvas.drawPath(path, linePaint);

    // เส้นฐานด้านล่าง
    final baseY = h * 0.92;
    canvas.drawLine(Offset(0, baseY), Offset(w, baseY), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
