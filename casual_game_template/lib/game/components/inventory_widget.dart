import 'package:flutter/material.dart';
import 'item_detail_modal.dart';

/// インベントリ管理ウィジェット
class InventoryWidget extends StatefulWidget {
  const InventoryWidget({super.key});

  @override
  State<InventoryWidget> createState() => _InventoryWidgetState();
}

class _InventoryWidgetState extends State<InventoryWidget> {
  // インベントリ状態管理
  final List<String?> _inventory = List.filled(5, null); // 5個のスロット、null = 空
  int? _selectedSlotIndex; // 選択中のスロット（null = 未選択）
  
  @override
  void initState() {
    super.initState();
    // デモ用アイテムを追加
    Future.delayed(const Duration(seconds: 1), () {
      _addItemToInventory('key');
      _addItemToInventory('lightbulb');
    });
  }
  
  /// アイテムをインベントリに追加（左詰めで配置）
  void _addItemToInventory(String itemId) {
    final emptyIndex = _inventory.indexWhere((item) => item == null);
    if (emptyIndex != -1) {
      setState(() {
        _inventory[emptyIndex] = itemId;
      });
      debugPrint('🎒 Added item: $itemId to slot $emptyIndex');
    } else {
      debugPrint('🎒 Inventory full, cannot add: $itemId');
    }
  }
  
  /// アイテムを追加（外部から呼び出し用）
  void addItem(String itemId) {
    _addItemToInventory(itemId);
  }
  
  /// スロットを選択/詳細表示
  void _selectSlot(int index) {
    final itemId = _inventory[index];
    
    // アイテムがない場合は何もしない
    if (itemId == null) return;
    
    // 既に選択されているスロットを再タップした場合は詳細表示
    if (_selectedSlotIndex == index) {
      ItemDetailModal.show(context, itemId);
      return;
    }
    
    // 新しいスロットを選択
    setState(() {
      _selectedSlotIndex = index;
    });
    debugPrint('🎯 Selected slot: $_selectedSlotIndex (item: $itemId)');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 利用可能な画面幅を取得
        final screenWidth = constraints.maxWidth;
        
        // 全体のパディングを画面幅の比率で計算（より詰めたレイアウト）
        final horizontalPadding = screenWidth * 0.02; // 横幅の2%
        final verticalPadding = screenWidth * 0.015;   // 横幅の1.5%
        
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
                // 左移動ボタン（正方形）
                _buildSquareButton(
                  icon: Icons.arrow_back,
                  size: itemSize,
                  onPressed: () => debugPrint('🔙 Previous room'),
                ),
                
                SizedBox(width: itemSpacing),
                
                // インベントリアイテム（5個の正方形）
                ..._buildInventoryItems(itemSize, itemSpacing),
                
                SizedBox(width: itemSpacing),
                
                // 右移動ボタン（正方形）
                _buildSquareButton(
                  icon: Icons.arrow_forward,
                  size: itemSize,
                  onPressed: () => debugPrint('🔜 Next room'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 正方形ボタンを構築
  Widget _buildSquareButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
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
    final itemId = _inventory[index];
    final isSelected = _selectedSlotIndex == index;
    
    return GestureDetector(
      onTap: () => _selectSlot(index),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected 
            ? Colors.orange[200] // 選択時の背景色
            : (itemId != null ? Colors.brown[50] : Colors.grey[100]), // アイテム有無で背景色変更
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected 
              ? Colors.orange[600]! // 選択時の枠線色
              : (itemId != null ? Colors.brown[300]! : Colors.grey[300]!),
            width: isSelected ? 3 : 1, // 選択時の枠線太さ
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.orange[300]!.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Center(
          child: _buildSlotContent(itemId, size),
        ),
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
      default:
        icon = Icons.help_outline;
        color = Colors.grey[600]!;
    }
    
    return Icon(
      icon,
      color: color,
      size: size * 0.6,
    );
  }
}