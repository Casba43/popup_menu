import 'package:flutter/material.dart';

// Custom painter for square button with rounded edges and a cross icon
class SquarePainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double strokeWidth;

  SquarePainter({
    this.color = const Color(0xFF000000), // Default color is black
    this.borderRadius = 8.0, // Default border radius for rounded corners
    this.strokeWidth = 2.0, // Default stroke width for the cross
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the square with rounded corners
    Paint squarePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Define a rounded rectangle
    RRect roundedRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    // Draw the rounded rectangle
    canvas.drawRRect(roundedRect, squarePaint);

    // Paint for the cross (X)
    Paint crossPaint = Paint()
      ..color = Colors.white // Cross color (you can adjust it)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Define the points for the cross lines
    final double padding = 10.0; // Padding for the cross inside the button
    Offset topLeft = Offset(padding, padding);
    Offset bottomRight = Offset(size.width - padding, size.height - padding);
    Offset topRight = Offset(size.width - padding, padding);
    Offset bottomLeft = Offset(padding, size.height - padding);

    // Draw the cross
    canvas.drawLine(topLeft, bottomRight, crossPaint);
    canvas.drawLine(topRight, bottomLeft, crossPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
