import 'package:flame/components.dart';
import 'base_hotspot_helpers.dart';

/// 左右端の部屋のホットスポット定義
class RoomExtremesHotspots {
  /// 地下通路（room_leftmost.png）のホットスポット定義
  static List<Map<String, dynamic>> get roomLeftmostDefinitions => [
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
  ];

  /// 宝物庫（room_rightmost.png）のホットスポット定義
  static List<Map<String, dynamic>> get roomRightmostDefinitions => [
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
    BaseHotspotHelpers.createPolygonHotspot(
      id: 'underground_entrance',
      gridCoordinates: [
        [4.8, 10.9],
        [6.0, 11.0],
        [6.5, 10.5],
        [5.5, 10.2],
      ],
      description: '地下への階段',
    ),
    {
      'id': 'hidden_room_entrance_b',
      'relativePosition': Vector2(0.85, 0.4),    // 340/400, 240/600
      'relativeSize': Vector2(0.125, 0.083),     // 50/400, 50/600
      'description': '隠し部屋B入口',
    },
  ];
}