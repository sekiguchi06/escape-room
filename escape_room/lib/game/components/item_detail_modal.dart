import 'package:flutter/material.dart';
import 'lighting_system.dart';
import 'inventory_system.dart';
import '../../gen/assets.gen.dart';
import '../../framework/ui/multi_floor_navigation_system.dart';

/// アイテム詳細表示モーダル
class ItemDetailModal {
  /// アイテム詳細表示モーダルを表示（画像のみ）
  static void show(BuildContext context, String itemId) {
    showDialog(
      context: context,
      barrierDismissible: true, // 外側タップで閉じる
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // 画像タップでギミック実行
              _executeItemGimmick(context, itemId);
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.brown[800], // 外枠の色
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.amber[700]!, // ゴールドの枠線
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3), // 3pxの余白
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _getItemImage(
                    itemId,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 画像が見つからない場合の代替表示
                      return Container(
                        color: Colors.brown[200],
                        child: Center(
                          child: Icon(
                            _getItemIcon(itemId),
                            size: 100,
                            color: Colors.brown[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// アイテムのギミックを実行
  static void _executeItemGimmick(BuildContext context, String itemId) {
    Navigator.of(context).pop(); // モーダルを閉じる

    switch (itemId) {
      case 'key':
        debugPrint('🔑 鍵ギミック実行: ドアを開ける');
        // TODO: ドア開けギミック実装
        break;
      case 'lightbulb':
        debugPrint('💡 電球ギミック実行: 照明を切り替え');
        LightingSystem().toggleLight();
        break;
      case 'book':
        debugPrint('📖 本ギミック実行: 暗号を解読');
        // TODO: 暗号解読ギミック実装
        break;
      case 'coin':
        debugPrint('🪙 コインギミック実行: 機械に投入');
        // TODO: 機械操作ギミック実装
        break;
      case 'gem':
        debugPrint('💎 宝石ギミック実行: 魔法陣を起動');
        // TODO: 魔法陣ギミック実装
        break;
      case 'main_escape_key':
        debugPrint('🗝️ 地下の鍵ギミック実行: 階段を解放');
        _useMainEscapeKey(context);
        break;
      default:
        debugPrint('❓ 不明アイテム: ギミックなし');
    }
  }

  /// main_escape_keyを使用して地下の階段を解放
  static void _useMainEscapeKey(BuildContext context) {
    final inventorySystem = InventorySystem();
    final multiFloorNav = MultiFloorNavigationSystem();
    
    // アイテムを消費
    inventorySystem.removeItemById('main_escape_key');
    
    // 階段を解放
    multiFloorNav.unlockStairsWithKey();
    
    debugPrint('🗝️ 地下の鍵を使用しました！');
    debugPrint('🪜 階段が解放され、地下へのアクセスが可能になりました');
    
    // 成功メッセージを表示
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          '🗝️ 階段解放成功！',
          style: TextStyle(
            color: Colors.amber[200],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '地下の鍵を使用して階段が解放されました！\n今後は1階と地下を自由に行き来できます。',
          style: TextStyle(color: Colors.brown[100]),
        ),
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

  /// アイテムアセットマップ（型安全性とスケーラビリティの両立）
  static final Map<String, AssetGenImage> _itemAssets = {
    'key': Assets.images.items.key,
    'lightbulb': Assets.images.items.lightbulb,
    'book': Assets.images.items.book,
    'coin': Assets.images.items.coin,
    'gem': Assets.images.items.gem,
    'main_escape_key': Assets.images.items.key, // 仮画像
  };

  /// アイテム画像を取得（型安全なflutter_gen使用）
  static Image _getItemImage(
    String itemId, {
    BoxFit? fit,
    ImageErrorWidgetBuilder? errorBuilder,
  }) {
    final asset = _itemAssets[itemId] ?? Assets.images.items.key; // デフォルト
    return asset.image(fit: fit, errorBuilder: errorBuilder);
  }

  /// アイテムアイコンを取得
  static IconData _getItemIcon(String itemId) {
    switch (itemId) {
      case 'key':
        return Icons.key;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'book':
        return Icons.book;
      case 'coin':
        return Icons.monetization_on;
      case 'gem':
        return Icons.diamond;
      case 'main_escape_key':
        return Icons.vpn_key;
      default:
        return Icons.help_outline;
    }
  }
}
