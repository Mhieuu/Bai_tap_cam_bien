import 'dart:async';

import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';

void main() {
  runApp(const LightMeterApp());
}

class LightMeterApp extends StatelessWidget {
  const LightMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Light Meter',
      home: const LightMeter(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black87),
      ),
    );
  }
}

class LightMeter extends StatefulWidget {
  const LightMeter({super.key});

  @override
  State<LightMeter> createState() => _LightMeterState();
}

class _LightMeterState extends State<LightMeter> {
  double _luxValue = 0;
  StreamSubscription<int>? _subscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    try {
      final hasSensor = await LightSensor.hasSensor();
      if (hasSensor) {
        _subscription = LightSensor.luxStream().listen((lux) {
          setState(() => _luxValue = lux.toDouble());
        });
      } else {
        debugPrint('Thiết bị không có cảm biến ánh sáng');
      }
    } catch (e) {
      debugPrint('Lỗi cảm biến: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String _getLightStatus(double lux) {
    if (lux < 10) return "Tối om (Phòng kín)";
    if (lux < 500) return "Sáng vừa (Trong nhà)";
    return "Rất sáng (Ngoài trời)";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = _luxValue < 50;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(title: const Text("Light Meter")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 120,
              color: isDark ? Colors.grey : Colors.orangeAccent,
            ),
            const SizedBox(height: 20),
            Text(
              "$_luxValue lux",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getLightStatus(_luxValue),
              style: TextStyle(
                fontSize: 24,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
