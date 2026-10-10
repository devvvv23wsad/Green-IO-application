import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/soil_page.dart';
import 'pages/tds_page.dart';
import 'pages/water_page.dart';
import 'pages/weather_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ใส่ Device Token ของ Blynk ตรงนี้
  static const String blynkToken = 'UzEFkC3ieaJHNE8NYcWcs_TXTBeHiaC6';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(token: blynkToken),
        '/soil': (context) => SoilPage(token: blynkToken),
        '/tds': (context) => TDSPage(token: blynkToken),
        '/water': (context) => WaterPage(token: blynkToken),
        '/weather': (context) => WeatherPage(token: blynkToken),
      },
    );
  }
}
