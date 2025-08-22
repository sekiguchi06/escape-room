import 'package:flutter/material.dart';
import '../components/custom_action_button.dart';

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
