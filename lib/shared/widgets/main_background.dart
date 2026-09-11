import 'package:flutter/material.dart';

class MainBackground extends StatelessWidget {
  final Widget child;

  const MainBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2563EB), // Royal Blue
            Color(0xFFDBEAFE),
            Color(0xFFF3F4F6),
            Color(0xFFF3F4F6),
          ],
          stops: [0.0, 0.2, 0.4, 1.0],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
