import 'package:flutter/material.dart';

/// カスタムタイマーWidget - 時間に応じて色変化
class CustomTimerWidget extends StatelessWidget {
  final String timeRemaining;

  const CustomTimerWidget({super.key, required this.timeRemaining});

  Color get _timerColor {
    // 時間文字列から秒数を計算
    final parts = timeRemaining.split(':');
    if (parts.length == 2) {
      final minutes = int.tryParse(parts[0]) ?? 0;
      final seconds = int.tryParse(parts[1]) ?? 0;
      final totalSeconds = minutes * 60 + seconds;

      // 30秒以下で赤、60秒以下でオレンジ、それ以上で緑
      if (totalSeconds <= 30) return Colors.red.shade600;
      if (totalSeconds <= 60) return Colors.orange.shade600;
    }
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_timerColor.withValues(alpha: 0.9), _timerColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _timerColor.withValues(alpha: 0.9),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            timeRemaining,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
