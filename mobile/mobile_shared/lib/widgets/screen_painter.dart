import 'package:flutter/material.dart';

class ScreenPainter extends CustomPainter {
  final Color color;
  const ScreenPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final lightPath = Path();
    lightPath.moveTo(0, size.height);
    lightPath.quadraticBezierTo(size.width / 2, 0, size.width, size.height);
    lightPath.lineTo(size.width * 0.85, size.height + 16);
    lightPath.lineTo(size.width * 0.15, size.height + 16);
    lightPath.close();

    final lightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.16),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height + 16));
    canvas.drawPath(lightPath, lightPaint);

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 0, size.width, size.height);

    canvas.drawPath(path, glowPaint);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
