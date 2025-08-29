import '../../gen/assets.gen.dart';

/// ホットスポットのアセットマッピングを管理するクラス
class HotspotAssetMapper {
  /// ホットスポットIDに基づいてアセットを取得
  static AssetGenImage getAssetForHotspot(String hotspotId) {
    // 新しいホットスポットのアセットマッピング
    const assetMap = {
      // room_left (回廊)
      'left_stone_pillar': 'library_candelabra', // 代替アセット
      'center_floor_item': 'treasure_chest',
      'right_wall_switch': 'entrance_door',
      'back_light_source': 'library_desk',
      
      // room_center (中央の部屋)
      'center_main_table': 'library_desk',
      'center_bookshelf': 'library_spellbook',
      'center_fireplace': 'library_candelabra',
      'center_carpet': 'entrance_door',
      'hidden_room_entrance_center': 'entrance_emblem',
      
      // room_right (錬金術室)
      'left_herb_shelf': 'alchemy_bottles',
      'center_main_shelf': 'alchemy_cauldron',
      'right_tool_shelf': 'alchemy_spellbook',
      
      // room_leftmost (地下通路)
      'left_wall_secret': 'entrance_emblem',
      'passage_center_trap': 'prison_bucket',
      'exit_light_clue': 'library_candelabra',
      
      // room_rightmost (宝物庫)
      'table_left_vase': 'treasure_goblet',
      'table_right_treasure': 'treasure_chest',
      'wall_crest': 'treasure_crown',
      'underground_entrance': 'wooden_stairs', // 地下入口の木製階段
      
      // 地下右奥
      'underground_final_seal': 'treasure_crown', // 最終封印
      'floor1_return_stairs_rightmost': 'entrance_door', // 1階帰還階段
      
      // 隠し部屋入口（地下）
      'hidden_room_entrance_a': 'entrance_emblem',
      'hidden_room_entrance_b': 'entrance_emblem',
      'hidden_room_entrance_c': 'entrance_emblem',
      'hidden_room_entrance_d': 'entrance_emblem',
      
      // 隠し部屋A
      'hidden_a_main_object': 'library_desk',
      'hidden_a_secondary': 'library_candelabra',
      'hidden_a_exit': 'entrance_door',
      
      // 隠し部屋B
      'hidden_b_main_object': 'alchemy_cauldron',
      'hidden_b_secondary': 'alchemy_bottles',
      'hidden_b_exit': 'entrance_door',
      
      // 隠し部屋C
      'hidden_c_main_object': 'treasure_chest',
      'hidden_c_secondary': 'treasure_goblet',
      'hidden_c_exit': 'entrance_door',
      
      // 隠し部屋D
      'hidden_d_main_object': 'prison_bucket',
      'hidden_d_secondary': 'library_spellbook',
      'hidden_d_exit': 'entrance_door',
    };

    final assetName = assetMap[hotspotId] ?? 'entrance_door';
    return _getAssetByName(assetName);
  }

  /// アセット名からAssetGenImageを取得
  static AssetGenImage _getAssetByName(String assetName) {
    switch (assetName) {
      case 'entrance_door':
        return Assets.images.hotspots.entranceDoor;
      case 'entrance_emblem':
        return Assets.images.hotspots.entranceEmblem;
      case 'entrance_key':
        return Assets.images.items.key;
      case 'library_spellbook':
        return Assets.images.hotspots.alchemySpellbook;
      case 'library_candelabra':
        return Assets.images.hotspots.libraryCandelabra;
      case 'library_desk':
        return Assets.images.hotspots.libraryDesk;
      case 'alchemy_bottles':
        return Assets.images.hotspots.alchemyBottles;
      case 'alchemy_cauldron':
        return Assets.images.hotspots.alchemyCauldron;
      case 'alchemy_spellbook':
        return Assets.images.hotspots.alchemySpellbook;
      case 'prison_cell_key':
        return Assets.images.items.key;
      case 'prison_bucket':
        return Assets.images.hotspots.prisonBucket;
      case 'treasure_chest':
        return Assets.images.hotspots.treasureChest;
      case 'treasure_crown':
        return Assets.images.hotspots.treasureCrown;
      case 'treasure_goblet':
        return Assets.images.hotspots.treasureGoblet;
      case 'wooden_stairs':
        return Assets.images.items.woodenStairs;
      default:
        return Assets.images.hotspots.entranceDoor; // デフォルトアセット
    }
  }

  /// ホットスポットIDに基づいて名前を取得
  static String getNameForHotspot(String hotspotId) {
    const nameMap = {
      // room_left (回廊)
      'left_stone_pillar': '石の柱',
      'center_floor_item': '床の物',
      'right_wall_switch': '壁のスイッチ',
      'back_light_source': '光源',
      
      // room_center (中央の部屋)
      'center_main_table': 'メインテーブル',
      'center_bookshelf': '本棚',
      'center_fireplace': '暖炉',
      'center_carpet': 'カーペット',
      'hidden_room_entrance_center': '隠し部屋の入口',
      
      // room_right (錬金術室)
      'left_herb_shelf': '薬草棚',
      'center_main_shelf': '中央の棚',
      'right_tool_shelf': '道具棚',
      
      // room_leftmost (地下通路)
      'left_wall_secret': '壁の秘密',
      'passage_center_trap': '通路の仕掛け',
      'exit_light_clue': '出口の光の手がかり',
      
      // room_rightmost (宝物庫)
      'table_left_vase': '左の花瓶',
      'table_right_treasure': '右の宝物',
      'wall_crest': '壁の紋章',
      'underground_entrance': '地下への入口',
      
      // 地下右奥
      'underground_final_seal': '最終封印',
      'floor1_return_stairs_rightmost': '1階への階段',
      
      // 隠し部屋入口（地下）
      'hidden_room_entrance_a': '隠し部屋Aの入口',
      'hidden_room_entrance_b': '隠し部屋Bの入口',
      'hidden_room_entrance_c': '隠し部屋Cの入口',
      'hidden_room_entrance_d': '隠し部屋Dの入口',
      
      // 隠し部屋A
      'hidden_a_main_object': '謎めいた物体',
      'hidden_a_secondary': '古い燭台',
      'hidden_a_exit': '出口',
      
      // 隠し部屋B
      'hidden_b_main_object': '古い大釜',
      'hidden_b_secondary': '薬瓶コレクション',
      'hidden_b_exit': '出口',
      
      // 隠し部屋C
      'hidden_c_main_object': '装飾された箱',
      'hidden_c_secondary': '金色の杯',
      'hidden_c_exit': '出口',
      
      // 隠し部屋D
      'hidden_d_main_object': '古いバケツ',
      'hidden_d_secondary': '魔術書',
      'hidden_d_exit': '出口',
    };

    return nameMap[hotspotId] ?? '調べられる物';
  }
}