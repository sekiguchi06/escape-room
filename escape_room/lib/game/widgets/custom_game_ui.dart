import 'package:flutter/material.dart';

/// プログラム生成によるカスタムゲームUI Widget
/// Illustrator/Photoshop不要でプロ品質のUI作成
class CustomGameUI extends StatelessWidget {
  final int score;
  final String timeRemaining;
  final bool isGameActive;
  final VoidCallback? onPausePressed;
  final VoidCallback? onRestartPressed;

  const CustomGameUI({
    super.key,
    required this.score,
    required this.timeRemaining,
    required this.isGameActive,
    this.onPausePressed,
    this.onRestartPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // スコア表示 - 左上
        Positioned(top: 60, left: 20, child: CustomScoreWidget(score: score)),

        // タイマー表示 - 右上
        Positioned(
          top: 60,
          right: 20,
          child: CustomTimerWidget(timeRemaining: timeRemaining),
        ),

        // ゲームコントロール - 右下
        Positioned(
          bottom: 100,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomActionButton(
                icon: isGameActive ? Icons.pause : Icons.play_arrow,
                onPressed: onPausePressed,
                color: isGameActive ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 12),
              CustomActionButton(
                icon: Icons.refresh,
                onPressed: onRestartPressed,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// カスタムスコアWidget - グラデーション背景付き
class CustomScoreWidget extends StatelessWidget {
  final int score;

  const CustomScoreWidget({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.4),
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
          Icon(Icons.stars, color: Colors.yellow.shade300, size: 20),
          const SizedBox(width: 8),
          Text(
            '$score',
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
          const Icon(Icons.timer, color: Colors.white, size: 18),
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

/// ゲームオーバー画面用カスタムUI
class CustomGameOverUI extends StatelessWidget {
  final int finalScore;
  final VoidCallback? onRestartPressed;
  final VoidCallback? onMenuPressed;

  const CustomGameOverUI({
    super.key,
    required this.finalScore,
    this.onRestartPressed,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade800, Colors.indigo.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ゲームオーバータイトル
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 最終スコア表示
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Final Score',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$finalScore',
                      style: TextStyle(
                        color: Colors.yellow.shade300,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // アクションボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (onMenuPressed != null)
                    CustomActionButton(
                      icon: Icons.home,
                      onPressed: onMenuPressed,
                      color: Colors.grey.shade600,
                    ),
                  if (onRestartPressed != null)
                    CustomActionButton(
                      icon: Icons.refresh,
                      onPressed: onRestartPressed,
                      color: Colors.green.shade600,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
