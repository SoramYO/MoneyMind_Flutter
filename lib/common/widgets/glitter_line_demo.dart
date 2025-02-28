import 'package:flutter/material.dart';
import 'custom_line_painter.dart';
import 'dart:async';

class GlitterLineDemo extends StatefulWidget {
  const GlitterLineDemo({super.key});

  @override
  _GlitterLineDemoState createState() => _GlitterLineDemoState();
}

class _GlitterLineDemoState extends State<GlitterLineDemo> {
  double progress = 0.7; // Tiến trình (0 đến 1)

  @override
  void initState() {
    super.initState();
    _startGlitterEffect();
  }

  void _startGlitterEffect() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {}); // Cập nhật lại widget để làm mới hiệu ứng
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CustomPaint(
          painter: CustomLinePainter(
            progress: progress,
            status: true,
          ),
          size: const Size(300, 20),
        ),
      ),
    );
  }
}
