import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class WaveBackground extends StatelessWidget {
  final Widget child;

  const WaveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Stack(
      children: [
        // Colored background (top area)
        Container(
          height: double.infinity,
          width: double.infinity,
          color: theme.colorScheme.primary,
        ),
        // Wave shape (bottom area)
        CustomPaint(
          size: Size.infinite,
          painter: WavePainter(
            color: theme.colorScheme
                .background, // This should be black in dark, white in light
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Start from a higher point (more space for title)
    path.moveTo(0, size.height * 0.45);

    // Create smoother wave curve
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.35,
      size.width * 0.6,
      size.height * 0.4,
    );

    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.45,
      size.width,
      size.height * 0.38,
    );

    // Complete the shape
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
