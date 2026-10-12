import 'package:flutter/material.dart';

class GoogleLogoWidget extends StatelessWidget {
  final double size;

  const GoogleLogoWidget({
    super.key,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw Google 'G' using paths
    final Paint blue = Paint()..color = const Color(0xFF4285F4);
    final Paint green = Paint()..color = const Color(0xFF34A853);
    final Paint yellow = Paint()..color = const Color(0xFFFBBC05);
    final Paint red = Paint()..color = const Color(0xFFEA4335);

    final Path bluePath = Path()
      ..moveTo(w * 0.95, h * 0.5)
      ..cubicTo(w * 0.95, h * 0.45, w * 0.94, h * 0.40, w * 0.93, h * 0.35)
      ..lineTo(w * 0.5, h * 0.35)
      ..lineTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.76, h * 0.55)
      ..cubicTo(w * 0.75, h * 0.62, w * 0.71, h * 0.68, w * 0.65, h * 0.72)
      ..lineTo(w * 0.65, h * 0.86)
      ..lineTo(w * 0.79, h * 0.86)
      ..cubicTo(w * 0.88, h * 0.78, w * 0.95, h * 0.65, w * 0.95, h * 0.5);

    final Path greenPath = Path()
      ..moveTo(w * 0.5, h * 0.95)
      ..cubicTo(w * 0.64, h * 0.95, w * 0.76, h * 0.90, w * 0.84, h * 0.83)
      ..lineTo(w * 0.70, h * 0.72)
      ..cubicTo(w * 0.65, h * 0.75, w * 0.58, h * 0.77, w * 0.5, h * 0.77)
      ..cubicTo(w * 0.36, h * 0.77, w * 0.24, h * 0.68, w * 0.19, h * 0.56)
      ..lineTo(w * 0.05, h * 0.67)
      ..cubicTo(w * 0.14, h * 0.84, w * 0.31, h * 0.95, w * 0.5, h * 0.95);

    final Path yellowPath = Path()
      ..moveTo(w * 0.19, h * 0.56)
      ..cubicTo(w * 0.17, h * 0.52, w * 0.16, h * 0.48, w * 0.16, h * 0.44)
      ..cubicTo(w * 0.16, h * 0.40, w * 0.17, h * 0.36, w * 0.19, h * 0.32)
      ..lineTo(w * 0.05, h * 0.21)
      ..cubicTo(w * 0.01, h * 0.28, 0, h * 0.36, 0, h * 0.44)
      ..cubicTo(0, h * 0.52, w * 0.01, h * 0.60, w * 0.05, h * 0.67)
      ..lineTo(w * 0.19, h * 0.56);

    final Path redPath = Path()
      ..moveTo(w * 0.5, h * 0.13)
      ..cubicTo(w * 0.59, h * 0.13, w * 0.67, h * 0.16, w * 0.73, h * 0.22)
      ..lineTo(w * 0.84, h * 0.11)
      ..cubicTo(w * 0.75, h * 0.03, w * 0.63, 0, w * 0.5, 0)
      ..cubicTo(w * 0.31, 0, w * 0.14, h * 0.11, w * 0.05, h * 0.27)
      ..lineTo(w * 0.19, h * 0.38)
      ..cubicTo(w * 0.24, h * 0.25, w * 0.36, h * 0.13, w * 0.5, h * 0.13);

    canvas.drawPath(bluePath, blue);
    canvas.drawPath(greenPath, green);
    canvas.drawPath(yellowPath, yellow);
    canvas.drawPath(redPath, red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
