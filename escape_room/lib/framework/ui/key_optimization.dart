/// Key最適化ユーティリティ
/// 
/// 動的リスト・ウィジェットでのパフォーマンス最適化のためのKey管理
library key_optimization;

import 'package:flutter/material.dart';

/// Key最適化のためのユーティリティクラス
class KeyOptimization {
  /// ID文字列からValueKeyを生成
  static ValueKey<String> valueKey(String id) => ValueKey(id);
  
  /// インデックスからValueKeyを生成
  static ValueKey<int> indexKey(int index) => ValueKey(index);
  
  /// オブジェクトのHashCodeからObjectKeyを生成
  static ObjectKey objectKey(Object object) => ObjectKey(object);
  
  /// ユニークな文字列IDからGlobalKeyを生成
  static GlobalKey globalKey([String? debugLabel]) => GlobalKey(debugLabel: debugLabel);
  
  /// リスト要素用の最適化されたKey生成
  static Key listItemKey(String baseId, int index) => ValueKey('${baseId}_$index');
  
  /// 動的なウィジェット用のユニークKey生成
  static Key uniqueKey(String prefix) => ValueKey('${prefix}_${DateTime.now().millisecondsSinceEpoch}');
}

/// Key最適化のためのMixin
/// 
/// リスト・動的ウィジェットで使用してパフォーマンスを最適化
mixin KeyOptimizedWidget {
  /// リスト要素のKey生成
  Key generateListKey(String identifier, int index) {
    return KeyOptimization.listItemKey(identifier, index);
  }
  
  /// ユニークなKey生成
  Key generateUniqueKey(String prefix) {
    return KeyOptimization.uniqueKey(prefix);
  }
  
  /// 条件付きKey生成
  Key? conditionalKey(bool condition, String identifier) {
    return condition ? KeyOptimization.valueKey(identifier) : null;
  }
}

/// 最適化されたリスト用ウィジェット基底クラス
abstract class OptimizedListWidget extends StatelessWidget with KeyOptimizedWidget {
  const OptimizedListWidget({super.key});
  
  /// リストアイテムのビルダー
  Widget buildListItem(BuildContext context, int index, dynamic item);
  
  /// リストデータの取得
  List<dynamic> get listData;
  
  /// リストのユニーク識別子
  String get listIdentifier;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        listData.length,
        (index) => KeyedSubtree(
          key: generateListKey(listIdentifier, index),
          child: buildListItem(context, index, listData[index]),
        ),
      ),
    );
  }
}

/// ホットスポット表示用の最適化されたウィジェット
class OptimizedHotspotDisplay extends StatelessWidget with KeyOptimizedWidget {
  final List<Map<String, dynamic>> hotspots;
  final Widget Function(Map<String, dynamic> hotspot, int index) itemBuilder;
  
  const OptimizedHotspotDisplay({
    super.key,
    required this.hotspots,
    required this.itemBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: hotspots.asMap().entries.map((entry) {
        final index = entry.key;
        final hotspot = entry.value;
        final hotspotId = hotspot['id']?.toString() ?? 'hotspot_$index';
        
        return KeyedSubtree(
          key: generateListKey('hotspot', index),
          child: itemBuilder(hotspot, index),
        );
      }).toList(),
    );
  }
}

/// インベントリ用の最適化されたウィジェット
class OptimizedInventoryDisplay extends StatelessWidget with KeyOptimizedWidget {
  final List<dynamic> items;
  final Widget Function(dynamic item, int index) itemBuilder;
  final int maxItems;
  
  const OptimizedInventoryDisplay({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.maxItems = 5,
  });
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> slots = [];
    
    for (int i = 0; i < maxItems; i++) {
      final hasItem = i < items.length;
      final item = hasItem ? items[i] : null;
      
      slots.add(
        KeyedSubtree(
          key: generateListKey('inventory_slot', i),
          child: itemBuilder(item, i),
        ),
      );
    }
    
    return Row(children: slots);
  }
}

/// ルームインジケーター用の最適化されたウィジェット
class OptimizedRoomIndicator extends StatelessWidget with KeyOptimizedWidget {
  final int currentRoom;
  final int totalRooms;
  final Widget Function(int roomIndex, bool isActive) roomBuilder;
  
  const OptimizedRoomIndicator({
    super.key,
    required this.currentRoom,
    required this.totalRooms,
    required this.roomBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalRooms, (index) {
        final isActive = index == currentRoom;
        return KeyedSubtree(
          key: generateListKey('room_indicator', index),
          child: roomBuilder(index, isActive),
        );
      }),
    );
  }
}