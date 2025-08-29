import 'package:flame/components.dart';
import 'base_hotspot_helpers.dart';

/// 回廊（room_left.png）のホットスポット定義
class RoomLeftHotspots {
  static List<Map<String, dynamic>> get definitions => [
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
    BaseHotspotHelpers.createPolygonHotspot(
      id: 'back_light_source',
      gridCoordinates: [
        [3.0, 4.0],
        [3.0, 6.3],
        [5.0, 6.3],
        [5.0, 4.0],
        [4.0, 3.4],
      ],
      description: '光源調査ポイント',
    ),
    {
      'id': 'hidden_room_entrance_a',
      'relativePosition': Vector2(0.15, 0.4),  // 60/400, 240/600
      'relativeSize': Vector2(0.125, 0.083),   // 50/400, 50/600
      'description': '隠し部屋A入口',
    },
  ];
}