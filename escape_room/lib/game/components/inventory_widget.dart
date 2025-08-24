import 'package:flutter/material.dart';
import 'item_detail_modal.dart';
import 'room_navigation_system.dart';
import 'inventory_system.dart';
import '../../framework/ui/multi_floor_navigation_system.dart';
import '../../framework/escape_room/core/room_types.dart';

/// インベントリ管理ウィジェット
class InventoryWidget extends StatefulWidget {
  const InventoryWidget({super.key});

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();

  /// インベントリ領域の高さを取得（他のコンポーネントから参照用）
  static double getHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    // 全体のパディングを画面幅の比率で計算
    final horizontalPadding = screenWidth * 0.02;
    final verticalPadding = screenWidth * 0.015;

    // 7個のボタン/アイテムのための計算
    const totalItems = 7;
    const itemSpacing = 2.0;

    // 利用可能な幅から全アイテムの幅を計算
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final totalSpacing = itemSpacing * (totalItems - 1);
    final itemSize = (availableWidth - totalSpacing) / totalItems;

    // エリア全体の高さを計算
    return itemSize + (verticalPadding * 2);
  }
}

class _InventoryWidgetState extends State<InventoryWidget> {
  @override
  void initState() {
    super.initState();
    // シングルトンインベントリシステムを使用（デモアイテム削除済み）
  }

  /// スロットを選択/詳細表示/組み合わせ
  void _selectSlot(int index) {
    final inventorySystem = InventorySystem();
    final itemId = inventorySystem.getItem(index);

    // アイテムがない場合は何もしない
    if (itemId == null) return;

    // 既に他のアイテムが選択されている場合は組み合わせを試行
    final selectedItem = inventorySystem.selectedItemId;
    if (selectedItem != null && inventorySystem.selectedSlotIndex != index) {
      if (inventorySystem.combineItemWithSelected(itemId)) {
        // 組み合わせ成功
        _showCombinationSuccess(selectedItem, itemId, 'master_key');
        return;
      } else {
        // 組み合わせ不可 - 普通の選択に変更
        inventorySystem.selectSlot(index);
        return;
      }
    }

    // 既に選択されているスロットを再タップした場合は詳細表示
    if (inventorySystem.selectedSlotIndex == index) {
      ItemDetailModal.show(context, itemId);
      return;
    }

    // 新しいスロットを選択
    inventorySystem.selectSlot(index);
  }

  /// 組み合わせ成功メッセージを表示
  void _showCombinationSuccess(String item1, String item2, String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          '🔧 アイテム組み合わせ成功！',
          style: TextStyle(
            color: Colors.amber[200],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '$item1 + $item2 = $result\n\n新しいアイテムが作成されました！',
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: InventorySystem(),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // 利用可能な画面幅を取得
            final screenWidth = constraints.maxWidth;

            // 全体のパディングを画面幅の比率で計算（より詰めたレイアウト）
            final horizontalPadding = screenWidth * 0.02; // 横幅の2%
            final verticalPadding = screenWidth * 0.015; // 横幅の1.5%

            // 7個のボタン/アイテム（矢印2個 + アイテム5個）のための計算
            const totalItems = 7;
            const itemSpacing = 2.0; // アイテム間のスペーシングを最小に

            // 利用可能な幅から全アイテムの幅を計算
            final availableWidth = screenWidth - (horizontalPadding * 2);
            final totalSpacing = itemSpacing * (totalItems - 1);
            final itemSize = (availableWidth - totalSpacing) / totalItems;

            // エリア全体の高さを計算（正方形サイズ + 上下パディング）
            final areaHeight = itemSize + (verticalPadding * 2);

            return Container(
              height: areaHeight,
              color: Colors.brown[100],
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 左移動ボタン（階層対応・隠し部屋では戻るボタン）
                    ListenableBuilder(
                      listenable: MultiFloorNavigationSystem(),
                      builder: (context, _) {
                        final navigationSystem = MultiFloorNavigationSystem();
                        final canReturnFromHidden = navigationSystem.canReturnFromHiddenRoom();
                        final canMoveLeft = navigationSystem.canMoveLeft;
                        
                        return _buildSquareButton(
                          icon: canReturnFromHidden ? Icons.arrow_downward : Icons.arrow_back,
                          size: itemSize,
                          onPressed: canReturnFromHidden
                              ? () => navigationSystem.returnFromHiddenRoom()
                              : (canMoveLeft ? () => navigationSystem.moveLeft() : null),
                          isEnabled: canReturnFromHidden || canMoveLeft,
                        );
                      },
                    ),

                    SizedBox(width: itemSpacing),

                    // インベントリアイテム（5個の正方形）
                    ..._buildInventoryItems(itemSize, itemSpacing),

                    SizedBox(width: itemSpacing),

                    // 右移動ボタン（階層対応・隠し部屋では戻るボタン）
                    ListenableBuilder(
                      listenable: MultiFloorNavigationSystem(),
                      builder: (context, _) {
                        final navigationSystem = MultiFloorNavigationSystem();
                        final canReturnFromHidden = navigationSystem.canReturnFromHiddenRoom();
                        final canMoveRight = navigationSystem.canMoveRight;
                        
                        return _buildSquareButton(
                          icon: canReturnFromHidden ? Icons.arrow_downward : Icons.arrow_forward,
                          size: itemSize,
                          onPressed: canReturnFromHidden
                              ? () => navigationSystem.returnFromHiddenRoom()
                              : (canMoveRight ? () => navigationSystem.moveRight() : null),
                          isEnabled: canReturnFromHidden || canMoveRight,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 正方形ボタンを構築
  Widget _buildSquareButton({
    required IconData icon,
    required double size,
    required VoidCallback? onPressed,
    bool isEnabled = true,
    Color? color,
  }) {
    return Container(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.brown[600] : Colors.grey[400],
          foregroundColor: isEnabled ? Colors.white : Colors.grey[600],
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Icon(icon, size: size * 0.5), // アイコンサイズを調整
      ),
    );
  }

  /// インベントリアイテムリストを構築
  List<Widget> _buildInventoryItems(double itemSize, double itemSpacing) {
    final items = <Widget>[];

    for (int i = 0; i < 5; i++) {
      if (i > 0) {
        items.add(SizedBox(width: itemSpacing));
      }
      items.add(_buildInventorySlot(i, itemSize));
    }

    return items;
  }

  /// インベントリスロットを構築（正方形）
  Widget _buildInventorySlot(int index, double size) {
    final inventorySystem = InventorySystem();
    final itemId = inventorySystem.getItem(index);
    final isSelected = inventorySystem.selectedSlotIndex == index;
    final canCombine =
        itemId != null && inventorySystem.canCombineWithSelected(itemId);

    return GestureDetector(
      onTap: () => _selectSlot(index),
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.orange[200] // 選択時の背景色
                  : (itemId != null
                        ? Colors.brown[50]
                        : Colors.grey[100]), // アイテム有無で背景色変更
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? Colors.orange[600]! // 選択時の枠線色
                    : (itemId != null ? Colors.brown[300]! : Colors.grey[300]!),
                width: isSelected ? 3 : 1, // 選択時の枠線太さ
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.orange[300]!.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(child: _buildSlotContent(itemId, size)),
          ),

          // 組み合わせ可能アイテムのキラキラエフェクト
          if (canCombine)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.yellow[400]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow[300]!.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.yellow[300]!,
                    size: size * 0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// スロットの内容を構築
  Widget _buildSlotContent(String? itemId, double size) {
    if (itemId == null) {
      // 空のスロット
      return Icon(
        Icons.add_circle_outline,
        color: Colors.grey[400],
        size: size * 0.4,
      );
    }

    // アイテムのアイコンマッピング
    IconData icon;
    Color color;

    switch (itemId) {
      case 'key':
        icon = Icons.key;
        color = Colors.amber[700]!;
        break;
      case 'lightbulb':
        icon = Icons.lightbulb;
        color = Colors.orange[600]!;
        break;
      case 'book':
        icon = Icons.book;
        color = Colors.brown[600]!;
        break;
      case 'coin':
        icon = Icons.monetization_on;
        color = Colors.yellow[700]!;
        break;
      case 'gem':
        icon = Icons.diamond;
        color = Colors.blue[600]!;
        break;
      case 'master_key':
        icon = Icons.vpn_key;
        color = Colors.purple[600]!;
        break;
      case 'escape_key':
        icon = Icons.key;
        color = Colors.green[600]!;
        break;
      case 'escape_cipher':
        icon = Icons.article;
        color = Colors.indigo[600]!;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey[600]!;
    }

    return Icon(icon, color: color, size: size * 0.6);
  }
}
