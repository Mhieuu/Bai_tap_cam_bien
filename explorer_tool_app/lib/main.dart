import 'dart:async';
import 'dart:math' show atan2, pi;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const ExplorerApp());
}

class ExplorerApp extends StatelessWidget {
  const ExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explorer Tool',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Colors.tealAccent),
      ),
      home: const ExplorerTool(),
    );
  }
}

class ExplorerTool extends StatefulWidget {
  const ExplorerTool({super.key});

  @override
  ExplorerToolState createState() => ExplorerToolState();
}

class ExplorerToolState extends State<ExplorerTool> {
  String _locationMessage = 'Đang lấy vị trí...';
  double _headingDegrees = 0;
  StreamSubscription<MagnetometerEvent>? _magSubscription;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _listenMagnetometer();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = 'Hãy bật GPS (Location Service)!';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() {
        _locationMessage = 'Quyền vị trí bị từ chối.';
      });
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _locationMessage =
          'Vĩ độ (lat): ${position.latitude}\nKinh độ (lon): ${position.longitude}\nĐộ cao (alt): ${position.altitude.toStringAsFixed(1)} m';
    });
  }

  void _listenMagnetometer() {
    _magSubscription = magnetometerEvents.listen((event) {
      final headingRad = atan2(event.y, event.x);
      double headingDeg = headingRad * 180 / pi;
      if (headingDeg < 0) headingDeg += 360;
      setState(() {
        _headingDegrees = headingDeg;
      });
    });
  }

  @override
  void dispose() {
    _magSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer Tool (GPS + La bàn)'),
        backgroundColor: Colors.grey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GPS',
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _locationMessage,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'La bàn',
                    style: TextStyle(
                      color: Colors.tealAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hướng: ${_headingDegrees.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Transform.rotate(
                    angle: -_headingDegrees * pi / 180, // kim chỉ Bắc
                    child: Icon(
                      Icons.navigation,
                      color: Colors.redAccent,
                      size: 150,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
