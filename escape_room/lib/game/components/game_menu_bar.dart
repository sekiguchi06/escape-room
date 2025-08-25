import 'package:flutter/material.dart';
import 'hint_dialog.dart';
import '../escape_room.dart';
import 'room_navigation_system.dart';
import 'lighting_system.dart';
import 'inventory_system.dart';

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
            color: Colors.black.withValues(alpha: 0.7),
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
              Container(width: 1, height: 30, color: Colors.brown[400]),

              // リトライボタン
              _buildMenuButton(
                icon: Icons.refresh,
                label: 'リトライ',
                onPressed: () {
                  debugPrint('🔄 Retry pressed - Restarting game');
                  // 確認ダイアログを表示
                  _showRetryConfirmDialog(context);
                },
              ),

              // 区切り線
              Container(width: 1, height: 30, color: Colors.brown[400]),

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
        child: SizedBox(
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
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

  /// リトライ確認ダイアログを表示
  void _showRetryConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.brown[400]!, width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.refresh, color: Colors.white),
              SizedBox(width: 8),
              Text('ゲームをリスタート', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            '進行状況が失われますが、本当にゲームをリスタートしますか？',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('キャンセル', style: TextStyle(color: Colors.brown[300])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                _restartGame(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('リスタート'),
            ),
          ],
        );
      },
    );
  }

  /// ゲームを実際にリスタート
  void _restartGame(BuildContext context) {
    debugPrint('🔄 Restarting escape room game with fade transition...');

    // フェードオーバーレイを表示してリスタート
    _showFadeRestartOverlay(context);
  }

  /// フェード効果付きリスタートオーバーレイ
  void _showFadeRestartOverlay(BuildContext context) {
    // Navigatorの参照を事前に取得
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext overlayContext) {
        return _FadeRestartOverlay(
          onComplete: () {
            // ゲーム状態をリセット
            RoomNavigationSystem().resetToInitialRoom();
            LightingSystem().resetToInitialState();
            InventorySystem().initializeEmpty(); // インベントリを空で初期化

            // オーバーレイを閉じてから画面遷移（スライドなし）
            Navigator.of(overlayContext).pop();

            // 少し待ってから画面遷移（即座の置き換えでスライドを防ぐ）
            Future.delayed(const Duration(milliseconds: 50), () {
              navigator.pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const EscapeRoom(),
                  transitionDuration: Duration.zero, // スライドアニメーション除去
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            });
          },
        );
      },
    );
  }
}

/// フェードリスタート用オーバーレイWidget
class _FadeRestartOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _FadeRestartOverlay({required this.onComplete});

  @override
  State<_FadeRestartOverlay> createState() => _FadeRestartOverlayState();
}

class _FadeRestartOverlayState extends State<_FadeRestartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // 部屋移動より長め
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // フェード開始
    _controller.forward().then((_) {
      // フェード完了後にコールバックを実行（mountedチェック）
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: _fadeAnimation.value),
          child: _fadeAnimation.value > 0.5
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : null,
        );
      },
    );
  }
}
