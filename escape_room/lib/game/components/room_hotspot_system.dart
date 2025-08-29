import 'package:flutter/material.dart';
import 'inventory_system.dart';
import 'room_hotspot_definitions.dart';
import '../../gen/assets.gen.dart';
import '../../framework/ui/multi_floor_navigation_system.dart';
import '../../framework/escape_room/core/room_types.dart';
import 'rooms/underground_rooms.dart';
import 'rooms/remaining_room_hotspots.dart';
import 'models/hotspot_models.dart';

/// パズルモーダル表示要求のコールバック関数型
typedef PuzzleModalCallback =
    void Function({
      required String hotspotId,
      required String title,
      required String description,
      required String correctAnswer,
      required String rewardItemId,
      required String rewardItemName,
      required String rewardDescription,
      required AssetGenImage rewardAsset,
    });

/// 部屋別ホットスポットシステム
class RoomHotspotSystem extends ChangeNotifier {
  static final RoomHotspotSystem _instance = RoomHotspotSystem._internal();
  factory RoomHotspotSystem() => _instance;
  RoomHotspotSystem._internal();

  /// アイテム発見モーダル表示用コールバック
  ItemDiscoveryCallback? _onItemDiscovered;

  /// 操作されたホットスポットのID記録
  final Set<String> _interactedHotspots = <String>{};

  /// アイテム発見コールバックを設定
  void setItemDiscoveryCallback(ItemDiscoveryCallback? callback) {
    _onItemDiscovered = callback;
    debugPrint('🎊 Item discovery callback set: ${callback != null}');
  }

  /// アイテム発見を通知
  void notifyItemDiscovered({
    required String itemId,
    required String itemName,
    required String description,
    required AssetGenImage itemAsset,
  }) {
    _onItemDiscovered?.call(
      itemId: itemId,
      itemName: itemName,
      description: description,
      itemAsset: itemAsset,
    );
  }

  /// ホットスポット操作を記録
  void recordHotspotInteraction(String hotspotId) {
    _interactedHotspots.add(hotspotId);
    // デバッグメッセージを削除して重複を防止
  }

  /// 操作されたホットスポットのリストを取得
  List<String> getInteractedHotspots() {
    return _interactedHotspots.toList();
  }

  /// 特定のホットスポットが操作されたかチェック
  bool hasInteractedWith(String hotspotId) {
    return _interactedHotspots.contains(hotspotId);
  }

  /// 現在の部屋のホットスポットを取得
  List<HotspotData> getCurrentRoomHotspots({required BuildContext context}) {
    final navigation = MultiFloorNavigationSystem();
    final currentRoom = navigation.currentRoom;

    switch (currentRoom) {
      // 1階の部屋
      case RoomType.leftmost:
        return _getHotspotsFromDefinitions('room_leftmost');
      case RoomType.left:
        return _getHotspotsFromDefinitions('room_left');
      case RoomType.center:
        return _getHotspotsFromDefinitions('room_center'); // 中央の部屋
      case RoomType.right:
        return _getHotspotsFromDefinitions('room_right');
      case RoomType.rightmost:
        return TreasureHotspots.getHotspots(
          recordInteraction: recordHotspotInteraction,
          context: context,
        );
      case RoomType.testRoom:
        return _getTestRoomHotspots();
        
      // 地下の部屋
      case RoomType.undergroundLeftmost:
        return UndergroundRoomConfig.getUndergroundHotspots(
          onItemDiscovered: _onItemDiscovered,
        )[RoomType.undergroundLeftmost] ?? [];
      case RoomType.undergroundLeft:
        return UndergroundRoomConfig.getUndergroundHotspots(
          onItemDiscovered: _onItemDiscovered,
        )[RoomType.undergroundLeft] ?? [];
      case RoomType.undergroundCenter:
        return UndergroundRoomConfig.getUndergroundHotspots(
          onItemDiscovered: _onItemDiscovered,
        )[RoomType.undergroundCenter] ?? [];
      case RoomType.undergroundRight:
        return UndergroundRoomConfig.getUndergroundHotspots(
          onItemDiscovered: _onItemDiscovered,
        )[RoomType.undergroundRight] ?? [];
      case RoomType.undergroundRightmost:
        return UndergroundRoomConfig.getUndergroundHotspots(
          onItemDiscovered: _onItemDiscovered,
        )[RoomType.undergroundRightmost] ?? [];
        
      // 隠し部屋
      case RoomType.hiddenA:
        return _getHotspotsFromDefinitions('hidden_room_a');
      case RoomType.hiddenB:
        return _getHotspotsFromDefinitions('hidden_room_b');
      case RoomType.hiddenC:
        return _getHotspotsFromDefinitions('hidden_room_c');
      case RoomType.hiddenD:
        return _getHotspotsFromDefinitions('hidden_room_d');
      case RoomType.hiddenE:
        return _getHotspotsFromDefinitions('hidden_room_e');
      case RoomType.hiddenF:
        return _getHotspotsFromDefinitions('hidden_room_f');
      case RoomType.hiddenG:
        return _getHotspotsFromDefinitions('hidden_room_g');
        
      // 最終謎部屋
      case RoomType.finalPuzzle:
        return []; // プレースホルダー（最終謎部屋のホットスポット未定義）
    }
  }

  /// RoomHotspotDefinitionsから新しいホットスポットデータを生成
  List<HotspotData> _getHotspotsFromDefinitions(String roomType) {
    final definitions = RoomHotspotDefinitions.getHotspotsForRoom(roomType);
    
    return definitions.asMap().entries.map((entry) {
      final index = entry.key;
      final definition = entry.value;
      
      return HotspotData(
        id: definition['id'],
        asset: _getAssetForHotspot(definition['id']),
        name: _getNameForHotspot(definition['id']),
        description: definition['description'] ?? '調べることができる場所',
        position: Offset(
          definition['relativePosition'].x,
          definition['relativePosition'].y,
        ),
        size: Size(
          definition['relativeSize'].x,
          definition['relativeSize'].y,
        ),
        onTap: (tapPosition) {
          recordHotspotInteraction(definition['id']);
          _handleHotspotTap(definition['id']);
        },
        hotspotNumber: index + 1, // 1から始まる番号を付与
      );
    }).toList();
  }

  /// ホットスポットIDに基づいてアセットを取得
  AssetGenImage _getAssetForHotspot(String hotspotId) {
    // 新しいホットスポットのアセットマッピング
    const assetMap = {
      // room_left (回廊)
      'left_stone_pillar': 'library_candelabra', // 代替アセット
      'center_floor_item': 'treasure_chest',
      'right_wall_switch': 'entrance_door',
      'back_light_source': 'library_desk',
      
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
    };
    
    final assetName = assetMap[hotspotId] ?? 'entrance_door';
    
    switch (assetName) {
      case 'library_candelabra': return Assets.images.hotspots.libraryCandelabra;
      case 'treasure_chest': return Assets.images.hotspots.treasureChest;
      case 'entrance_door': return Assets.images.hotspots.entranceDoor;
      case 'library_desk': return Assets.images.hotspots.libraryDesk;
      case 'alchemy_bottles': return Assets.images.hotspots.alchemyBottles;
      case 'alchemy_cauldron': return Assets.images.hotspots.alchemyCauldron;
      case 'alchemy_spellbook': return Assets.images.hotspots.alchemySpellbook;
      case 'entrance_emblem': return Assets.images.hotspots.entranceEmblem;
      case 'prison_bucket': return Assets.images.hotspots.prisonBucket;
      case 'treasure_goblet': return Assets.images.hotspots.treasureGoblet;
      case 'treasure_crown': return Assets.images.hotspots.treasureCrown;
      default: return Assets.images.hotspots.entranceDoor;
    }
  }

  /// ホットスポットIDに基づいて名前を取得
  String _getNameForHotspot(String hotspotId) {
    const nameMap = {
      // room_left (回廊)
      'left_stone_pillar': '石の柱',
      'center_floor_item': '床のアイテム',
      'right_wall_switch': '壁のスイッチ',
      'back_light_source': '光源',
      
      // room_right (錬金術室)
      'left_herb_shelf': '薬草棚',
      'center_main_shelf': 'メイン作業台',
      'right_tool_shelf': '道具棚',
      
      // room_leftmost (地下通路)
      'left_wall_secret': '壁の秘密',
      'passage_center_trap': '通路の仕掛け',
      'exit_light_clue': '出口の手がかり',
      
      // room_rightmost (宝物庫)
      'table_left_vase': '装飾の壺',
      'table_right_treasure': '宝箱',
      'wall_crest': '壁の紋章',
    };
    
    return nameMap[hotspotId] ?? '調べられる場所';
  }

  /// ホットスポットタップ時の処理
  void _handleHotspotTap(String hotspotId) {
    debugPrint('🎯 新しいホットスポット「$hotspotId」がタップされました');
    
    // デバッグ情報を表示
    _showHotspotDebugInfo(hotspotId);
    
    // インベントリシステムと連携してアイテム取得
    final inventory = InventorySystem();
    final itemId = _getItemForHotspot(hotspotId);
    
    if (itemId.isNotEmpty) {
      final success = inventory.acquireItemFromHotspot(hotspotId, itemId);
      if (success) {
        debugPrint('✅ アイテム「$itemId」を取得しました');
        // アイテム発見通知
        notifyItemDiscovered(
          itemId: itemId,
          itemName: _getNameForItem(itemId),
          description: 'ホットスポット「$hotspotId」で発見',
          itemAsset: _getAssetForItem(itemId),
        );
      }
    }
  }

  /// ホットスポットのデバッグ情報を表示
  void _showHotspotDebugInfo(String hotspotId) {
    debugPrint('🐛 === ホットスポットデバッグ情報 ===');
    debugPrint('🆔 ID: $hotspotId');
    debugPrint('📛 名前: ${_getNameForHotspot(hotspotId)}');
    debugPrint('🏷️ 説明: ${_getDescriptionForHotspot(hotspotId)}');
    debugPrint('🎁 アイテム: ${_getItemForHotspot(hotspotId)}');
    debugPrint('👆 操作履歴: ${hasInteractedWith(hotspotId) ? "済み" : "未操作"}');
    debugPrint('🔧 デバッグモード: 有効');
    debugPrint('================================');
  }

  /// ホットスポットの説明を取得
  String _getDescriptionForHotspot(String hotspotId) {
    const descriptionMap = {
      // room_left (回廊)
      'left_stone_pillar': '古い石の柱。何かが刻まれている',
      'center_floor_item': '床に落ちているアイテム。取得可能',
      'right_wall_switch': '壁に設置されたスイッチ。押せそうだ',
      'back_light_source': '部屋の奥にある光源。調べてみよう',
      
      // room_right (錬金術室)
      'left_herb_shelf': '薬草や瓶が並ぶ棚。錬金術の材料か',
      'center_main_shelf': 'メインの作業台。重要そうな装置がある',
      'right_tool_shelf': '錬金術の道具が置かれた棚',
      
      // room_leftmost (地下通路)
      'left_wall_secret': '壁面に隠された秘密がありそうだ',
      'passage_center_trap': '通路の中央にある仕掛け。慎重に',
      'exit_light_clue': '出口への手がかりとなる光源',
      
      // room_rightmost (宝物庫)
      'table_left_vase': '装飾の施された美しい壺',
      'table_right_treasure': '宝箱が置かれている。開けられるか？',
      'wall_crest': '壁に刻まれた紋章。重要な意味がありそうだ',

      // room_center (中央の部屋)
      'center_main_table': '部屋の中央にある大きなテーブル',
      'center_bookshelf': '古い本が並ぶ本棚。何か手がかりが？',
      'center_fireplace': '暖炉。火は消えているが何かありそう',
      'center_carpet': '装飾カーペット。下に何かが？',
      'hidden_room_entrance_center': '隠し部屋への入口らしき場所',
    };
    
    return descriptionMap[hotspotId] ?? '調べることができる場所';
  }


  /// ホットスポットから取得できるアイテムIDを取得
  String _getItemForHotspot(String hotspotId) {
    // 最大5個制限に合わせて主要アイテムのみ配置
    const itemMap = {
      'left_stone_pillar': 'ancient_stone',      // 1個目: 古い石
      'back_light_source': 'light_crystal',      // 2個目: 光のクリスタル  
      'left_wall_secret': 'secret_key',          // 3個目: 秘密の鍵
      'center_main_shelf': 'alchemy_tools',      // 4個目: 錬金道具
      'table_right_treasure': 'treasure_box',    // 5個目: 宝箱
      
      // その他のホットスポットはアイテムなし（探索のみ）
      'center_floor_item': '',
      'right_wall_switch': '',
      'left_herb_shelf': '',
      'right_tool_shelf': '',
      'passage_center_trap': '',
      'exit_light_clue': '',
      'table_left_vase': '',
      'wall_crest': '',
    };
    
    return itemMap[hotspotId] ?? '';
  }

  /// アイテム名を取得
  String _getNameForItem(String itemId) {
    const nameMap = {
      'ancient_stone': '古い石',
      'light_crystal': '光のクリスタル',
      'secret_key': '秘密の鍵',
      'alchemy_tools': '錬金道具',
      'treasure_box': '宝の箱',
      'main_escape_key': '脱出の鍵',
    };
    
    return nameMap[itemId] ?? 'アイテム';
  }

  /// アイテムアセットを取得
  AssetGenImage _getAssetForItem(String itemId) {
    // アイテム画像は既存のhotspotアセットを流用
    switch (itemId) {
      case 'ancient_stone': return Assets.images.hotspots.libraryCandelabra;
      case 'treasure_box': return Assets.images.hotspots.treasureChest;
      default: return Assets.images.hotspots.entranceDoor;
    }
  }

  /// パズル解決成功時の処理
  void onPuzzleSolved({
    required String hotspotId,
    required String rewardItemId,
    required String rewardItemName,
    required String rewardDescription,
    required AssetGenImage rewardAsset,
  }) {
    // アイテム取得機能（重複取得防止付き）
    final success = InventorySystem().acquireItemFromHotspot(
      hotspotId,
      rewardItemId,
    );
    if (success) {
      debugPrint('✨ パズル解決！ $rewardItemNameを手に入れました！');
      // itemDiscovery モーダルを表示
      _onItemDiscovered?.call(
        itemId: rewardItemId,
        itemName: rewardItemName,
        description: rewardDescription,
        itemAsset: rewardAsset,
      );
    }
  }

  /// テスト部屋のホットスポット
  List<HotspotData> _getTestRoomHotspots() {
    return [
      HotspotData(
        id: 'test_button',
        asset: Assets.images.hotspots.entranceDoor, // テスト用にドアアセット使用
        name: 'テストボタン',
        description: 'テスト用のインタラクティブボタン',
        position: const Offset(0.3, 0.5),
        size: const Size(0.2, 0.15),
        onTap: (tapPosition) {
          debugPrint('🧪 テストボタンがタップされました');
        },
      ),
      HotspotData(
        id: 'test_object',
        asset: Assets.images.hotspots.treasureChest, // テスト用に宝箱アセット使用
        name: 'テストオブジェクト',
        description: 'テスト用のオブジェクト',
        position: const Offset(0.6, 0.4),
        size: const Size(0.15, 0.2),
        onTap: (tapPosition) {
          debugPrint('🔍 テストオブジェクトを調査中...');
        },
      ),
    ];
  }
}
