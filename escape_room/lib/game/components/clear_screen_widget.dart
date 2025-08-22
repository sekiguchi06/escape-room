import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ゲームクリア画面Widget
/// 🎯 目的: プレイヤーがゲームをクリアした際の祝福画面表示
class ClearScreenWidget extends StatelessWidget {
  final VoidCallback? onRestartGame;
  final VoidCallback? onMainMenu;
  final int clearTime;
  final int itemsCollected;
  final int totalItems;

  const ClearScreenWidget({
    super.key,
    this.onRestartGame,
    this.onMainMenu,
    this.clearTime = 0,
    this.itemsCollected = 0,
    this.totalItems = 0,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = clearTime ~/ 60;
    final seconds = clearTime % 60;

    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎉 クリアタイトル
              const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                '🎉 脱出成功！',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 📊 クリア統計
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      '⏱️ クリア時間',
                      '${minutes}分${seconds.toString().padLeft(2, '0')}秒',
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      '🎒 アイテム収集',
                      '$itemsCollected / $totalItems個',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 🎮 アクションボタン
              Row(
                children: [
                  // メインメニューボタン
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onMainMenu?.call();
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('メニュー'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // リスタートボタン
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onRestartGame?.call();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('再挑戦'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 統計表示行
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
