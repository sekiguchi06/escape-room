import 'package:flutter/material.dart';

/// Circular icon button widget used in the bottom navigation
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
