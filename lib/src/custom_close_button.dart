import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color; // Allow the user to set the background color

  CustomCloseButton({
    required this.onPressed,
    this.color, // Optional background color
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        size: const Size(35, 35), // Set size of the button
        painter: SquarePainter(
          color: color ?? Theme.of(context).primaryColor, // Use user-specified or theme's primary color
          borderRadius: 10.0, // Rounded corners
          strokeWidth: 2.0,  // Thickness of the cross icon
        ),
      ),
    );
  }
}

// Custom painter for square button with rounded edges and a cross icon
class SquarePainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double strokeWidth;

  SquarePainter({
    this.color = const Color(0xFF000000), // Default color is black
    this.borderRadius = 10.0, // Default border radius for rounded corners
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
      ..color = Colors.white // Cross color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Define the points for the cross lines
    final double padding = 10.0; // Increased padding for a smaller cross
    Offset topLeft = Offset(padding, padding);
    Offset bottomRight = Offset(size.width - padding, size.height - padding);
    Offset topRight = Offset(size.width - padding, padding);
    Offset bottomLeft = Offset(padding, size.height - padding);

    // Draw the cross
    canvas.drawLine(topLeft, bottomRight, crossPaint);
    canvas.drawLine(topRight, bottomLeft, crossPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
