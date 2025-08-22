import 'package:flutter/material.dart';
import '../components/inventory_system.dart';
import '../components/models/hotspot_models.dart' as hotspot_models;
import '../../framework/game_timer.dart';
import 'premium_clear_screen.dart';

/// ホットスポット詳細モーダル
class HotspotDetailModal extends StatelessWidget {
  final hotspot_models.HotspotData hotspot;

  const HotspotDetailModal({super.key, required this.hotspot});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalSize = screenWidth * 0.9; // 横幅の90%を正方形に

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20), // 画面端との余白
      child: SizedBox(
        width: modalSize,
        height: modalSize,
        child: GestureDetector(
          onTap: () => _onModalTap(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.brown[800],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber[700]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hotspot.asset.image(
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.brown[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 50,
                              color: Colors.brown[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'IMAGE NOT FOUND',
                              style: TextStyle(
                                color: Colors.brown[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              hotspot.id,
                              style: TextStyle(
                                color: Colors.brown[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ギミック実行可能かチェック
  bool _canExecuteGimmick() {
    final inventorySystem = InventorySystem();
    switch (hotspot.id) {
      case 'treasure_chest':
        return inventorySystem.inventory.contains('master_key');
      case 'entrance_door':
        return inventorySystem.inventory.contains('escape_key');
      default:
        return false;
    }
  }

  /// ギミック実行
  void _executeGimmick(BuildContext context) {
    if (!_canExecuteGimmick()) return;

    final inventorySystem = InventorySystem();

    switch (hotspot.id) {
      case 'treasure_chest':
        // 宝箱のギミック解除
        final success = inventorySystem.addItem('escape_key');
        if (success) {
          // master_keyを消費
          inventorySystem.removeItemById('master_key');

          debugPrint('🗝️ 脱出の鍵を取得しました！master_keyを消費');
          // TODO: Implement item discovery notification system
          debugPrint('🎁 Item discovered: escape_key - 脱出の鍵');

          Navigator.of(context).pop();
          _showGimmickSuccessMessage(context, '宝箱が開いた！最終的な脱出の鍵を発見！');
        }
        break;

      case 'entrance_door':
        // 扉のギミック解除
        // escape_keyを消費
        inventorySystem.removeItemById('escape_key');

        debugPrint('🎉 脱出成功！ゲームクリア！escape_keyを消費');
        GameTimer().stop(); // ゲーム時間計測停止
        Navigator.of(context).pop();
        _showGameClearMessage(context);
        break;
    }
  }

  /// ギミック成功メッセージを表示
  void _showGimmickSuccessMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          '🔓 ギミック解除成功！',
          style: TextStyle(
            color: Colors.amber[200],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: TextStyle(color: Colors.brown[100])),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.brown[800],
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// ゲームクリアメッセージを表示
  void _showGameClearMessage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return PremiumClearScreen(
            clearTime: GameTimer().gameTime,
            onHomePressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          );
        },
        transitionDuration: const Duration(milliseconds: 3000),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Stack(
            children: [
              // 背景拡大＋白フェードアウト演出（前半）
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: 1.0 + (animation.value * 0.4),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.5 - (animation.value * 0.5),
                          colors: [
                            Colors.brown.shade800.withValues(alpha: 0.8),
                            Colors.brown.shade900,
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // 白フェード演出
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  double whiteOpacity;
                  if (animation.value <= 0.5) {
                    // 前半：白くなっていく
                    whiteOpacity = animation.value * 2;
                  } else {
                    // 後半：白から元に戻る
                    whiteOpacity = (1.0 - animation.value) * 2;
                  }
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white.withValues(
                      alpha: whiteOpacity.clamp(0.0, 0.9),
                    ),
                  );
                },
              ),
              // プレミアムクリア画面（後半からフェードイン）
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
                  ),
                ),
                child: child,
              ),
            ],
          );
        },
        opaque: false,
      ),
    );
  }

  /// モーダル内タップ処理
  void _onModalTap(BuildContext context) {
    final inventorySystem = InventorySystem();
    final selectedItem = inventorySystem.selectedItemId;

    // 選択されたアイテムがない場合は何もしない
    if (selectedItem == null) return;

    switch (hotspot.id) {
      case 'treasure_chest':
        if (selectedItem == 'master_key') {
          _executeGimmick(context);
        }
        break;

      case 'entrance_door':
        if (selectedItem == 'escape_key') {
          _executeGimmick(context);
        }
        break;

      default:
        // その他のホットスポットでは何もしない
        break;
    }
  }
}
