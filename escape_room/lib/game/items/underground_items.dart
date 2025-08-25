import '../../../framework/escape_room/core/room_types.dart';

/// 地下アイテムの設定クラス
class UndergroundItems {
  /// 地下アイテムの定義
  static const Map<String, UndergroundItemConfig> items = {
    'dark_crystal': UndergroundItemConfig(
      id: 'dark_crystal',
      nameKey: 'item_dark_crystal_name',
      descriptionKey: 'item_dark_crystal_description',
      imagePath: 'images/items/dark_crystal.png',
      hotspotId: 'underground_crystal_formation',
      roomType: RoomType.undergroundLeftmost,
    ),
    'ritual_stone': UndergroundItemConfig(
      id: 'ritual_stone',
      nameKey: 'item_ritual_stone_name',
      descriptionKey: 'item_ritual_stone_description',
      imagePath: 'images/items/ritual_stone.png',
      hotspotId: 'underground_ancient_altar',
      roomType: RoomType.undergroundLeft,
    ),
    'pure_water': UndergroundItemConfig(
      id: 'pure_water',
      nameKey: 'item_pure_water_name',
      descriptionKey: 'item_pure_water_description',
      imagePath: 'images/items/pure_water.png',
      hotspotId: 'underground_water_source',
      roomType: RoomType.undergroundCenter,
    ),
    'ancient_rune': UndergroundItemConfig(
      id: 'ancient_rune',
      nameKey: 'item_ancient_rune_name',
      descriptionKey: 'item_ancient_rune_description',
      imagePath: 'images/items/ancient_rune.png',
      hotspotId: 'underground_rune_wall',
      roomType: RoomType.undergroundRight,
    ),
    'underground_key': UndergroundItemConfig(
      id: 'underground_key',
      nameKey: 'item_underground_key_name',
      descriptionKey: 'item_underground_key_description',
      imagePath: 'images/items/underground_key.png',
      hotspotId: 'underground_treasure_vault',
      roomType: RoomType.undergroundRightmost,
    ),
  };
  
  /// 地下組み合わせルール
  static const List<UndergroundCombinationRule> combinations = [
    UndergroundCombinationRule(
      inputs: ['dark_crystal', 'ritual_stone', 'pure_water'],
      output: 'underground_master_key',
      nameKey: 'combination_underground_master_key',
      descriptionKey: 'combination_underground_master_key_description',
    ),
  ];
  
  /// 地下アイテムのリストを取得
  static List<String> getItemIds() {
    return items.keys.toList();
  }
  
  /// 指定された部屋のアイテムリストを取得
  static List<String> getItemsForRoom(RoomType roomType) {
    return items.entries
        .where((entry) => entry.value.roomType == roomType)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// アイテムが地下アイテムかチェック
  static bool isUndergroundItem(String itemId) {
    return items.containsKey(itemId);
  }
  
  /// 地下マスターキーの作成に必要なアイテムをすべて持っているかチェック
  static bool hasAllMasterKeyIngredients(List<String> inventoryItems) {
    const requiredItems = ['dark_crystal', 'ritual_stone', 'pure_water'];
    return requiredItems.every((item) => inventoryItems.contains(item));
  }
}

/// 地下アイテム設定クラス
class UndergroundItemConfig {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final String imagePath;
  final String hotspotId;
  final RoomType roomType;
  
  const UndergroundItemConfig({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.imagePath,
    required this.hotspotId,
    required this.roomType,
  });
  
  /// コピーを作成
  UndergroundItemConfig copyWith({
    String? id,
    String? nameKey,
    String? descriptionKey,
    String? imagePath,
    String? hotspotId,
    RoomType? roomType,
  }) {
    return UndergroundItemConfig(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      imagePath: imagePath ?? this.imagePath,
      hotspotId: hotspotId ?? this.hotspotId,
      roomType: roomType ?? this.roomType,
    );
  }
}

/// 地下組み合わせルール設定クラス
class UndergroundCombinationRule {
  final List<String> inputs;
  final String output;
  final String nameKey;
  final String descriptionKey;
  
  const UndergroundCombinationRule({
    required this.inputs,
    required this.output,
    required this.nameKey,
    required this.descriptionKey,
  });
  
  /// 組み合わせ可能かチェック
  bool canCombine(List<String> availableItems) {
    return inputs.every((input) => availableItems.contains(input));
  }
  
  /// コピーを作成
  UndergroundCombinationRule copyWith({
    List<String>? inputs,
    String? output,
    String? nameKey,
    String? descriptionKey,
  }) {
    return UndergroundCombinationRule(
      inputs: inputs ?? this.inputs,
      output: output ?? this.output,
      nameKey: nameKey ?? this.nameKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
    );
  }
}