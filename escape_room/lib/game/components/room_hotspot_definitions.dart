import 'package:flame/components.dart';
import '../../framework/components/responsive_hotspot_component.dart';
import 'hotspot_definitions/hidden_room_hotspots.dart';

/// 各部屋のホットスポット座標定義
/// 400x600統一背景サイズに対する相対座標
class RoomHotspotDefinitions {
  /// 回廊（room_left.png）のホットスポット定義
  static List<Map<String, dynamic>> get roomLeftHotspots => [
    {
      'id': 'left_stone_pillar',
      'relativePosition': Vector2(0.2, 0.33),  // 80/400, 200/600
      'relativeSize': Vector2(0.15, 0.1),      // 60/400, 60/600
      'description': '石柱のヒントオブジェクト',
    },
    {
      'id': 'center_floor_item',
      'relativePosition': Vector2(0.5, 0.75),  // 200/400, 450/600
      'relativeSize': Vector2(0.2, 0.133),     // 80/400, 80/600
      'description': 'アイテム落下位置',
    },
    {
      'id': 'right_wall_switch',
      'relativePosition': Vector2(0.8, 0.417), // 320/400, 250/600
      'relativeSize': Vector2(0.175, 0.117),   // 70/400, 70/600
      'description': '壁面スイッチ',
    },
    {
      'id': 'back_light_source',
      'relativePosition': Vector2(0.5, 0.25),  // 200/400, 150/600
      'relativeSize': Vector2(0.125, 0.083),   // 50/400, 50/600
      'description': '光源調査ポイント',
    },
    {
      'id': 'hidden_room_entrance_a',
      'relativePosition': Vector2(0.15, 0.4),  // 60/400, 240/600
      'relativeSize': Vector2(0.125, 0.083),   // 50/400, 50/600
      'description': '隠し部屋A入口',
    },
  ];

  /// 錬金術室（room_right.png）のホットスポット定義
  static List<Map<String, dynamic>> get roomRightHotspots => [
    {
      'id': 'left_herb_shelf',
      'relativePosition': Vector2(0.125, 0.5), // 50/400, 300/600
      'relativeSize': Vector2(0.2, 0.133),     // 80/400, 80/600
      'description': '薬草・瓶エリア',
    },
    {
      'id': 'center_main_shelf',
      'relativePosition': Vector2(0.5, 0.333),  // 200/400, 200/600
      'relativeSize': Vector2(0.25, 0.167),     // 100/400, 100/600
      'description': 'メイン操作エリア',
    },
    {
      'id': 'right_tool_shelf',
      'relativePosition': Vector2(0.825, 0.583), // 330/400, 350/600
      'relativeSize': Vector2(0.175, 0.117),     // 70/400, 70/600
      'description': '器具・道具エリア',
    },
  ];

  /// 地下通路（room_leftmost.png）のホットスポット定義
  static List<Map<String, dynamic>> get roomLeftmostHotspots => [
    {
      'id': 'left_wall_secret',
      'relativePosition': Vector2(0.15, 0.417), // 60/400, 250/600
      'relativeSize': Vector2(0.175, 0.117),    // 70/400, 70/600
      'description': '壁面の秘密',
    },
    {
      'id': 'passage_center_trap',
      'relativePosition': Vector2(0.5, 0.667),  // 200/400, 400/600
      'relativeSize': Vector2(0.2, 0.133),      // 80/400, 80/600
      'description': '床の仕掛け',
    },
    {
      'id': 'exit_light_clue',
      'relativePosition': Vector2(0.5, 0.25),   // 200/400, 150/600
      'relativeSize': Vector2(0.15, 0.1),       // 60/400, 60/600
      'description': '出口への手がかり',
    },
    {
      'id': 'hidden_room_entrance_e',
      'relativePosition': Vector2(0.85, 0.35),  // 340/400, 210/600
      'relativeSize': Vector2(0.125, 0.083),    // 50/400, 50/600
      'description': '隠し部屋E入口',
    },
  ];

  /// 宝物庫（room_rightmost.png）のホットスポット定義
  static List<Map<String, dynamic>> get roomRightmostHotspots => [
    {
      'id': 'table_left_vase',
      'relativePosition': Vector2(0.375, 0.583), // 150/400, 350/600
      'relativeSize': Vector2(0.2, 0.133),       // 80/400, 80/600
      'description': '装飾壺',
    },
    {
      'id': 'table_right_treasure',
      'relativePosition': Vector2(0.625, 0.583), // 250/400, 350/600
      'relativeSize': Vector2(0.2, 0.133),       // 80/400, 80/600
      'description': '宝箱エリア',
    },
    {
      'id': 'wall_crest',
      'relativePosition': Vector2(0.5, 0.333),   // 200/400, 200/600
      'relativeSize': Vector2(0.175, 0.117),     // 70/400, 70/600
      'description': '壁面の紋章',
    },
    {
      'id': 'hidden_room_entrance_b',
      'relativePosition': Vector2(0.85, 0.4),    // 340/400, 240/600
      'relativeSize': Vector2(0.125, 0.083),     // 50/400, 50/600
      'description': '隠し部屋B入口',
    },
  ];

  /// 地下部屋用ホットスポット定義を追加
  static List<Map<String, dynamic>> get undergroundLeftHotspots => [
    {
      'id': 'underground_crystal_formation',
      'relativePosition': Vector2(0.3, 0.4),
      'relativeSize': Vector2(0.2, 0.133),
      'description': '地下左：闇のクリスタル',
    },
    {
      'id': 'hidden_room_entrance_c',
      'relativePosition': Vector2(0.1, 0.5),
      'relativeSize': Vector2(0.125, 0.083),
      'description': '隠し部屋C入口',
    },
    {
      'id': 'hidden_room_entrance_f',
      'relativePosition': Vector2(0.85, 0.3),
      'relativeSize': Vector2(0.125, 0.083),
      'description': '隠し部屋F入口',
    },
  ];
  
  static List<Map<String, dynamic>> get undergroundRightHotspots => [
    {
      'id': 'underground_treasure_vault',
      'relativePosition': Vector2(0.6, 0.6),
      'relativeSize': Vector2(0.2, 0.133),
      'description': '地下右：地下の鍵',
    },
    {
      'id': 'hidden_room_entrance_d',
      'relativePosition': Vector2(0.9, 0.5),
      'relativeSize': Vector2(0.125, 0.083),
      'description': '隠し部屋D入口',
    },
  ];
  
  /// 地下左奥のホットスポット定義を追加
  static List<Map<String, dynamic>> get undergroundLeftmostHotspots => [
    {
      'id': 'underground_ancient_altar',
      'relativePosition': Vector2(0.5, 0.45),
      'relativeSize': Vector2(0.2, 0.133),
      'description': '地下左奥：古代祭壇',
    },
    {
      'id': 'hidden_room_entrance_g',
      'relativePosition': Vector2(0.15, 0.3),
      'relativeSize': Vector2(0.125, 0.083),
      'description': '隠し部屋G入口',
    },
  ];
  
  /// 隠し部屋用ホットスポット定義（戻るホットスポットを削除）
  static List<Map<String, dynamic>> get hiddenRoomAHotspots => [
    {
      'id': 'hidden_emblem_a_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋A：紋章A',
    },
  ];
  
  static List<Map<String, dynamic>> get hiddenRoomBHotspots => [
    {
      'id': 'hidden_emblem_b_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋B：紋章B',
    },
  ];
  
  static List<Map<String, dynamic>> get hiddenRoomCHotspots => [
    {
      'id': 'hidden_seal_c_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋C：封印C',
    },
  ];
  
  static List<Map<String, dynamic>> get hiddenRoomDHotspots => [
    {
      'id': 'hidden_seal_d_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋D：封印D',
    },
  ];
  
  static List<Map<String, dynamic>> get hiddenRoomEHotspots => [
    {
      'id': 'hidden_artifact_e_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋E：古代遺物E',
    },
  ];
  
  static List<Map<String, dynamic>> get hiddenRoomFHotspots => [
    {
      'id': 'hidden_artifact_f_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋F：古代遺物F',
    },
  ];
  
  static List<Map<String, dynamic>> get hiddenRoomGHotspots => [
    {
      'id': 'hidden_artifact_g_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋G：古代遺物G',
    },
  ];

  /// 部屋タイプに応じたホットスポット定義を取得
  static List<Map<String, dynamic>> getHotspotsForRoom(String roomType) {
    switch (roomType) {
      case 'room_left':
        return roomLeftHotspots;
      case 'room_right':
        return roomRightHotspots;
      case 'room_leftmost':
        return roomLeftmostHotspots;
      case 'room_rightmost':
        return roomRightmostHotspots;
      case 'undergroundLeft':
        return undergroundLeftHotspots;
      case 'undergroundRight':
        return undergroundRightHotspots;
      case 'undergroundLeftmost':
        return undergroundLeftmostHotspots;
      case 'hidden_room_a':
        return hiddenRoomAHotspots;
      case 'hidden_room_b':
        return hiddenRoomBHotspots;
      case 'hidden_room_c':
        return hiddenRoomCHotspots;
      case 'hidden_room_d':
        return hiddenRoomDHotspots;
      case 'hidden_room_e':
        return hiddenRoomEHotspots;
      case 'hidden_room_f':
        return hiddenRoomFHotspots;
      case 'hidden_room_g':
        return hiddenRoomGHotspots;
      default:
        return [];
    }
  }

  /// ResponsiveHotspotComponentリストを生成
  static List<ResponsiveHotspotComponent> createHotspotsForRoom(
    String roomType,
    Function(String) onTap,
  ) {
    final definitions = getHotspotsForRoom(roomType);
    
    return definitions.map((definition) {
      return ResponsiveHotspotComponent(
        id: definition['id'],
        onTap: onTap,
        relativePosition: definition['relativePosition'],
        relativeSize: definition['relativeSize'],
        invisible: true,  // デフォルトで透明（デバッグ時にfalse）
        debugMode: false, // デバッグ時にtrue
      );
    }).toList();
  }
}