import 'package:flutter/material.dart';

/// Background decoration component for the game selection screen
class BackgroundDecoration extends StatelessWidget {
  final Widget child;

  const BackgroundDecoration({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade900,
            Colors.indigo.shade900,
            Colors.blue.shade800,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: 100,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: -75,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Main content
            child,
          ],
        ),
      ),
    );
  }
}
