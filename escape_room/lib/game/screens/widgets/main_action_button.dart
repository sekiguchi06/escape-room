import 'package:flutter/material.dart';

/// Main action button widget used in the game selection screen
class MainActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtitle;
  final Color color;
  final VoidCallback? onPressed;

  const MainActionButton({
    super.key,
    required this.icon,
    required this.text,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 65 : 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, size: isSmallScreen ? 28 : 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
