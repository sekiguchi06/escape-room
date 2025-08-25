import 'package:flutter/material.dart';
import 'custom_game_ui.dart';

/// スタート画面用のカスタムUI（進行度管理対応）
class CustomStartUI extends StatelessWidget {
  final VoidCallback? onStartPressed;
  final VoidCallback? onContinuePressed;
  final VoidCallback? onRetryPressed;
  final String title;
  final bool hasProgress;
  final String? progressInfo;

  const CustomStartUI({
    super.key,
    this.onStartPressed,
    this.onContinuePressed,
    this.onRetryPressed,
    this.title = 'Simple Game',
    this.hasProgress = false,
    this.progressInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.purple.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // タイトル
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // 進行度情報
          if (hasProgress && progressInfo != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  progressInfo!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // ゲームボタン群
          _buildGameButtons(context),

        ],
      ),
    );
  }

  Widget _buildGameButtons(BuildContext context) {
    if (hasProgress) {
      // 進行度がある場合のボタン配置
      return Positioned(
        bottom: MediaQuery.of(context).size.height * 0.15,
        left: 20,
        right: 20,
        child: Column(
          children: [
            // 続きからボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onContinuePressed,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  '続きから',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 下段のボタン行
            Row(
              children: [
                // リトライボタン
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetryPressed,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'リトライ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 初めからボタン
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showResetConfirmDialog(context),
                    icon: const Icon(
                      Icons.restart_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      '初めから',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // 進行度がない場合の従来のボタン
      return Positioned(
        bottom: MediaQuery.of(context).size.height * 0.2,
        left: 20,
        right: 20,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartPressed,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
                label: const Text(
                  'START GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '進行度をリセット',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('現在の進行度を削除して、最初からゲームを開始しますか？\n\nこの操作は取り消せません。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'キャンセル',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onStartPressed?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: const Text(
                'リセットして開始',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
