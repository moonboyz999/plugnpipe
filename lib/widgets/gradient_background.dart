import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:
              colors ??
              [
                const Color(0xFFFFA726), // Orange
                const Color(0xFFFFD600), // Yellow
              ],
        ),
      ),
      child: child,
    );
  }
}
