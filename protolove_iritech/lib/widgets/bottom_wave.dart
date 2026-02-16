import 'package:flutter/material.dart';

class BottomWave extends StatelessWidget {
  final Color color;
  final double height;

  const BottomWave({
    super.key,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        color: color,
      ),
    );
  }
}


class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height);

    path.lineTo(0, size.height * 0.6);

    path.cubicTo(
      size.width * 0.25,
      size.height * 0.45,
      size.width * 0.40,
      size.height * 0.75,
      size.width * 0.55,
      size.height * 0.65,
    );

    path.cubicTo(
      size.width * 0.70,
      size.height * 0.55,
      size.width * 0.85,
      size.height * 0.75,
      size.width,
      size.height * 0.6,
    );

    // Bajamos al fondo derecho
    path.lineTo(size.width, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


