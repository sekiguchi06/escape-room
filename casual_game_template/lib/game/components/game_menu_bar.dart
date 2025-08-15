import 'package:flutter/material.dart';
import 'hint_dialog.dart';

/// ゲーム上部メニューバー
class GameMenuBar extends StatelessWidget {
  final VoidCallback? onAddItem;
  
  const GameMenuBar({super.key, this.onAddItem});
  
  /// メニューバーの高さを取得（他のコンポーネントから参照用）
  static double getHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaTop = mediaQuery.padding.top;
    return safeAreaTop + 60 + 24; // SafeArea + height + margin
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 60,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.brown[400]!, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ホームボタン
              _buildMenuButton(
                icon: Icons.home,
                label: 'ホーム',
                onPressed: () {
                  debugPrint('🏠 Home pressed - Going to game start screen');
                  // ゲームスタート画面（GameSelectionScreen）に戻る
                  Navigator.of(context).pop();
                },
              ),
              
              // 区切り線
              Container(
                width: 1,
                height: 30,
                color: Colors.brown[400],
              ),
              
              // リトライボタン
              _buildMenuButton(
                icon: Icons.refresh,
                label: 'リトライ',
                onPressed: () {
                  debugPrint('🔄 Retry pressed - Restarting game');
                  // ゲームを再スタート（画面を再構築）
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        body: const Center(
                          child: Text('Game Restarting...'),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // 区切り線
              Container(
                width: 1,
                height: 30,
                color: Colors.brown[400],
              ),
              
              // ヒントボタン
              _buildMenuButton(
                icon: Icons.lightbulb_outline,
                label: 'ヒント',
                onPressed: () {
                  debugPrint('💡 Hint pressed');
                  HintDialog.show(context, onAddItem);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// メニューボタンを構築
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}