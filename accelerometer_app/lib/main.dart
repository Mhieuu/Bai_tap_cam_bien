import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MotionTrackerApp());
}

class MotionTrackerApp extends StatelessWidget {
  const MotionTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motion Tracker',
      theme: ThemeData.dark(),
      home: const MotionTracker(),
    );
  }
}

class MotionTracker extends StatefulWidget {
  const MotionTracker({super.key});

  @override
  State<MotionTracker> createState() => _MotionTrackerState();
}

class _MotionTrackerState extends State<MotionTracker> {
  // Biến đếm số lần lắc
  int _shakeCount = 0;
  // Ngưỡng rung lắc (m/s2)
  static const double _shakeThreshold = 12.0;
  DateTime _lastShakeTime = DateTime.now();

  // Màu nền thay đổi theo cường độ
  Color _bgColor = Colors.blueGrey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(title: const Text("Motion Tracker - Shake to Count")),
      body: StreamBuilder<UserAccelerometerEvent>(
        stream: userAccelerometerEvents,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final event = snapshot.data!;
          // Tổng gia tốc theo công thức căn bậc 2 của bình phương ba trục
          final acceleration = sqrt(
            event.x * event.x + event.y * event.y + event.z * event.z,
          );

          // Logic phát hiện lắc
          if (acceleration > _shakeThreshold) {
            final now = DateTime.now();
            // Debounce 500ms để tránh đếm dư chấn
            if (now.difference(_lastShakeTime).inMilliseconds > 500) {
              _lastShakeTime = now;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _shakeCount++;
                  _bgColor = Colors
                      .primaries[Random().nextInt(Colors.primaries.length)];
                });
              });
            }
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.vibration, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  "SHAKE COUNT: $_shakeCount",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Gia tốc hiện tại:\n${acceleration.toStringAsFixed(2)} m/s²",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
