import 'package:flutter/material.dart';

/// ヒントダイアログ
class HintDialog {
  /// ヒントダイアログを表示
  static void show(BuildContext context, VoidCallback? onAddItem) {
    // TODO: 将来的には広告表示後にヒントを表示する
    // 現在は直接ヒントモーダルを表示
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.brown[400]!, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.orange[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                '💡 ヒント',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(minHeight: 100),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!, width: 1),
                  ),
                  child: const Text(
                    '🔍 脱出のコツ:\n\n'
                    '1. 本棚の隠された本を調べてみよう\n'
                    '2. 金庫の番号は部屋のどこかにヒントが...\n'
                    '3. 机の引き出しには重要なアイテムが入っているかも\n'
                    '4. アイテムは組み合わせて使うことができる\n'
                    '5. 壁の絵をよく観察してみて',
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '行き詰まったら、画面をタップして調べてみよう！',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // デモ用のアイテム追加ボタン
            _buildItemButtons(context, onAddItem),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '✨ 頑張って脱出しよう！',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// デモ用アイテム追加ボタン
  static Widget _buildItemButtons(BuildContext context, VoidCallback? onAddItem) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: 実際のアイテム追加ロジックを実装
              debugPrint('📖 Adding book item');
              Navigator.of(context).pop();
              onAddItem?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('📖 本'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: 実際のアイテム追加ロジックを実装
              debugPrint('🪙 Adding coin item');
              Navigator.of(context).pop();
              onAddItem?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('🪙 コイン'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: 実際のアイテム追加ロジックを実装
              debugPrint('💎 Adding gem item');
              Navigator.of(context).pop();
              onAddItem?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('💎 宝石'),
          ),
        ),
      ],
    );
  }
}