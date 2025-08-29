import 'package:flutter/material.dart';
import 'hint_dialog.dart';
import '../escape_room.dart';
import 'room_navigation_system.dart';
import 'lighting_system.dart';
import 'inventory_system.dart';
import '../../screens/debug/audio_debug_screen.dart';
import '../../screens/debug/image_debug_screen.dart';
import '../../screens/debug/item_debug_screen.dart';
import '../../screens/debug/puzzle_debug_screen.dart';

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

              // 区切り線
              Container(width: 1, height: 30, color: Colors.brown[400]),

              // デバッグボタン
              _buildMenuButton(
                icon: Icons.bug_report,
                label: 'デバッグ',
                onPressed: () {
                  debugPrint('🐛 Debug pressed - Opening debug menu');
                  _showDebugMenu(context);
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

  /// デバッグメニューを表示
  void _showDebugMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.green[400]!, width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: Colors.green),
              SizedBox(width: 8),
              Text('デバッグメニュー', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDebugMenuItem(
                context,
                icon: Icons.volume_up,
                title: '音声デバッグ',
                subtitle: 'BGM・効果音の制御',
                onTap: () => _navigateToDebugScreen(context, const AudioDebugScreen()),
              ),
              const SizedBox(height: 8),
              _buildDebugMenuItem(
                context,
                icon: Icons.image,
                title: '画像デバッグ', 
                subtitle: '背景・アイテム画像の確認',
                onTap: () => _navigateToDebugScreen(context, const ImageDebugScreen()),
              ),
              const SizedBox(height: 8),
              _buildDebugMenuItem(
                context,
                icon: Icons.inventory,
                title: 'アイテムデバッグ',
                subtitle: 'インベントリシステムの確認',
                onTap: () => _navigateToDebugScreen(context, const ItemDebugScreen()),
              ),
              const SizedBox(height: 8),
              _buildDebugMenuItem(
                context,
                icon: Icons.extension,
                title: 'パズルデバッグ',
                subtitle: 'パズル状態・進行の確認',
                onTap: () => _navigateToDebugScreen(context, const PuzzleDebugScreen()),
              ),
              const SizedBox(height: 8),
              _buildDebugMenuItem(
                context,
                icon: Icons.visibility,
                title: 'ホットスポット表示',
                subtitle: 'ホットスポットの可視化切替',
                onTap: () => _toggleHotspotVisibility(context),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('閉じる', style: TextStyle(color: Colors.green[300])),
            ),
          ],
        );
      },
    );
  }

  /// デバッグメニューアイテムを構築
  Widget _buildDebugMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }

  /// デバッグ画面に遷移
  void _navigateToDebugScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pop(); // メニューを閉じる
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// ホットスポット可視性を切り替え
  void _toggleHotspotVisibility(BuildContext context) {
    Navigator.of(context).pop(); // メニューを閉じる
    
    // ホットスポット表示状態の切り替えを通知
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ホットスポット表示を切り替えました'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    debugPrint('🎯 Hotspot visibility toggled');
    // TODO: 実際のホットスポット表示切り替えロジックを実装
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
