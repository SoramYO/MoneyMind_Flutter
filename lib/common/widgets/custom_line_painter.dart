import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_project/core/constants/app_colors.dart';

class CustomLinePainter extends CustomPainter {
  final double progress;
  final double width;
  final double blurWidth;
  final bool status;

  List<Offset> sparkleOffsets = [];
  List<double> sparkleSpeeds = [];
  List<Color> sparkleColors = [];

  CustomLinePainter({
    required this.progress,
    required this.status,
    this.width = 15,
    this.blurWidth = 5,
  }) {
    _initializeSparkles();
  }

  void _initializeSparkles() {
    final random = Random();
    int sparkleCount = 20;

    List<Color> availableColors = [
      Colors.white,
      Colors.yellow,
      Colors.blue,
      Colors.purple,
      Colors.cyan,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.pink,
    ];

    sparkleOffsets = List.generate(sparkleCount, (_) {
      return Offset(random.nextDouble(), random.nextDouble() - 0.5);
    });

    sparkleSpeeds = List.generate(sparkleCount, (_) {
      return 0.5 + random.nextDouble() * 1.5;
    });

    sparkleColors = List.generate(sparkleCount, (_) {
      return availableColors[random.nextInt(availableColors.length)]
          .withAlpha((0.7 * 255).toInt()); // Thêm hiệu ứng trong suốt
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    double lineWidth = size.width;

    Paint backgroundPaint = Paint()
      ..color = Colors.grey.withAlpha((0.2 * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    Paint shadowPaint = Paint()
      ..color = status
          ? AppColors.primary
          : AppColors.error.withAlpha((0.4 * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + blurWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    Paint activePaint = Paint()
      ..color = status ? AppColors.primary : AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    Offset startPoint = Offset(0, size.height / 2);
    Offset endPoint = Offset(lineWidth * progress, size.height / 2);

    canvas.drawLine(
        startPoint, Offset(lineWidth, size.height / 2), backgroundPaint);
    canvas.drawLine(startPoint, endPoint, shadowPaint);
    canvas.drawLine(startPoint, endPoint, activePaint);
  }

  void _drawGlitter(Canvas canvas, Offset start, Offset end, Size size) {
    final random = Random();

    int time = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < sparkleOffsets.length; i++) {
      double sparkleX = start.dx + sparkleOffsets[i].dx * (end.dx - start.dx);
      double sparkleY = start.dy + sparkleOffsets[i].dy * width;
      double sparkleOpacity = 0.5 + random.nextDouble() * 0.5;

      double sparkleSizeAnimated =
          3.0 * (0.8 + 0.4 * sin(time * 0.005 * sparkleSpeeds[i]));

      Paint animatedGlitterPaint = Paint()
        ..color = sparkleColors[i]
            .withAlpha((sparkleOpacity * 255).toInt()) // Duy trì độ trong suốt
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleSizeAnimated,
          animatedGlitterPaint);
    }
  }

  @override
  bool shouldRepaint(CustomLinePainter oldDelegate) {
    return true;
  }
}
