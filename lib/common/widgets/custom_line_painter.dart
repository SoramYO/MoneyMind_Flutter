import 'package:flutter/material.dart';
import 'package:my_project/core/constants/app_colors.dart';

class CustomLinePainter extends CustomPainter {
  final double progress; // Giá trị tiến độ (0 đến 1)
  final double width;
  final double blurWidth;
  final bool status;

  CustomLinePainter({
    required this.progress,
    required this.status,
    this.width = 15,
    this.blurWidth = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double lineWidth = size.width; // Chiều dài đoạn thẳng

    // Background Paint (đường mờ phía sau)
    Paint backgroundPaint = Paint()
      ..color = Colors.grey
          .withAlpha((0.2 * 255).toInt()) // Thay thế withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // Shadow Paint (hiệu ứng mờ)
    Paint shadowPaint = Paint()
      ..color = status
          ? AppColors.primary
          : AppColors.error
              .withAlpha((0.4 * 255).toInt()) // Thay thế withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width + blurWidth
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Active Paint (đường chính hiển thị tiến độ)
    Paint activePaint = Paint()
      ..color = status ? AppColors.primary : AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // Tính toán điểm bắt đầu và kết thúc
    Offset startPoint = Offset(0, size.height / 2);
    Offset endPoint = Offset(lineWidth * progress, size.height / 2);

    // Vẽ background (đường toàn bộ)
    canvas.drawLine(
        startPoint, Offset(lineWidth, size.height / 2), backgroundPaint);

    // Vẽ shadow (hiệu ứng mờ)
    canvas.drawLine(startPoint, endPoint, shadowPaint);

    // Vẽ active line (đường hiển thị tiến độ)
    canvas.drawLine(startPoint, endPoint, activePaint);
  }

  @override
  bool shouldRepaint(CustomLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.width != width ||
        oldDelegate.blurWidth != blurWidth;
  }
}
