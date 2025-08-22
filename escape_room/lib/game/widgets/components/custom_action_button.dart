import 'package:flutter/material.dart';

/// カスタムアクションボタン - 3D効果付き
class CustomActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const CustomActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  State<CustomActionButton> createState() => _CustomActionButtonState();
}

class _CustomActionButtonState extends State<CustomActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              widget.onPressed?.call();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPressed
                      ? [
                          widget.color.withValues(alpha: 0.7),
                          widget.color.withValues(alpha: 0.7),
                        ]
                      : [widget.color.withValues(alpha: 0.9), widget.color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.7),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(-2, -2),
                        ),
                      ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 24),
            ),
          ),
        );
      },
    );
  }
}
