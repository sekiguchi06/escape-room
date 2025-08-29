import '../../gen/assets.gen.dart';

/// ホットスポットから取得できるアイテムのマッピングを管理するクラス
class HotspotItemMapper {
  /// ホットスポットIDからアイテムIDを取得
  static String? getItemForHotspot(String hotspotId) {
    const itemMap = {
      // 各ホットスポットが提供するアイテムID
      'left_stone_pillar': 'ancient_stone',
      'center_floor_item': 'treasure_box',
      'center_main_table': 'ancient_book',
      'right_tool_shelf': 'alchemy_tools',
      'underground_final_seal': 'main_escape_key',
      'wall_crest': 'secret_key',
      'exit_light_clue': 'light_crystal',
    };
    
    return itemMap[hotspotId];
  }

  /// アイテムIDから表示名を取得
  static String getNameForItem(String itemId) {
    const nameMap = {
      'ancient_stone': '古い石',
      'treasure_box': '宝の箱',
      'ancient_book': '古い本',
      'light_crystal': '光のクリスタル',
      'secret_key': '秘密の鍵',
      'alchemy_tools': '錬金道具',
      'main_escape_key': '脱出の鍵',
    };
    
    return nameMap[itemId] ?? 'アイテム';
  }

  /// アイテムアセットを取得
  static AssetGenImage getAssetForItem(String itemId) {
    // アイテム画像は既存のhotspotアセットを流用
    switch (itemId) {
      case 'ancient_stone': 
        return Assets.images.hotspots.libraryCandelabra;
      case 'treasure_box': 
        return Assets.images.hotspots.treasureChest;
      case 'ancient_book':
        return Assets.images.hotspots.alchemySpellbook;
      case 'light_crystal':
        return Assets.images.hotspots.libraryCandelabra;
      case 'secret_key':
        return Assets.images.items.key;
      case 'alchemy_tools':
        return Assets.images.hotspots.alchemyBottles;
      case 'main_escape_key':
        return Assets.images.items.key;
      default: 
        return Assets.images.hotspots.entranceDoor;
    }
  }

  /// アイテムの説明を取得
  static String getDescriptionForItem(String itemId) {
    const descriptionMap = {
      'ancient_stone': '古代の謎を秘めた石。何かの鍵になりそうだ。',
      'treasure_box': '美しい装飾が施された小さな宝箱。中に何かが入っている。',
      'ancient_book': '古い言語で書かれた本。重要な情報が記されている。',
      'light_crystal': '微かに光るクリスタル。暗闇を照らすのに役立つ。',
      'secret_key': '特別な場所を開くための秘密の鍵。',
      'alchemy_tools': '錬金術に使用される道具一式。',
      'main_escape_key': 'この館から脱出するための最重要アイテム。',
    };
    
    return descriptionMap[itemId] ?? 'このアイテムには特別な用途がありそうだ。';
  }
}