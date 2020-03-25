import 'package:flutter/material.dart';

class LidarScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 60;
    return Center(
      child: CustomPaint(
        size: Size(width, width),
        painter: ScannerPainter(),
      ),
    );
  }
}

class ScannerPainter extends CustomPainter {
  final Gradient gradient = new SweepGradient(
    endAngle: 1,
    colors: [
      Colors.transparent,
      Colors.black12,
    ],
  );
  Paint _paint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..strokeWidth = 12.0;
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    canvas.drawArc(
        rect, 0, 1, true, _paint..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
