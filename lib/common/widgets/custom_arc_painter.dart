import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector_math;
import '../../core/constants/app_colors.dart';

class CustomArcPainter extends CustomPainter {
  final double start;
  final double end;
  final double width;
  final double blurWidth;

  CustomArcPainter({
    this.start = 0, 
    this.end = 220,
    this.width = 15, 
    this.blurWidth = 6
  });

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - width) / 2
    );

    // Gradient cho phần active
    var gradientColor = LinearGradient(
      colors: [
        AppColors.primary.withOpacity(0.8),
        AppColors.primary,
        AppColors.primary.withOpacity(0.8),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter
    );

    // Shadow paint
    Paint shadowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + blurWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Background paint  
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // Active paint
    Paint activePaint = Paint()
      ..shader = gradientColor.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    var startVal = 160.0;
    var sweepAngle = 220.0;

    // Vẽ background
    canvas.drawArc(
      rect,
      vector_math.radians(startVal),
      vector_math.radians(sweepAngle),
      false,
      backgroundPaint
    );

    // Vẽ shadow
    canvas.drawArc(
      rect,
      vector_math.radians(startVal),
      vector_math.radians(end),
      false,
      shadowPaint
    );

    // Vẽ active arc
    canvas.drawArc(
      rect, 
      vector_math.radians(startVal),
      vector_math.radians(end),
      false,
      activePaint
    );
  }

  @override
  bool shouldRepaint(CustomArcPainter oldDelegate) => false;
} 