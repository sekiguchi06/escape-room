import 'package:flame/components.dart';

/// 中央の部屋（room_center）のホットスポット定義
class RoomCenterHotspots {
  static List<Map<String, dynamic>> get definitions => [
    {
      'id': 'center_main_table',
      'relativePosition': Vector2(0.5, 0.6),    // 200/400, 360/600
      'relativeSize': Vector2(0.25, 0.15),      // 100/400, 90/600
      'description': '中央のテーブル',
    },
    {
      'id': 'center_bookshelf',
      'relativePosition': Vector2(0.2, 0.4),    // 80/400, 240/600
      'relativeSize': Vector2(0.15, 0.2),       // 60/400, 120/600
      'description': '古い本棚',
    },
    {
      'id': 'center_fireplace',
      'relativePosition': Vector2(0.8, 0.45),   // 320/400, 270/600
      'relativeSize': Vector2(0.15, 0.18),      // 60/400, 108/600
      'description': '暖炉',
    },
    {
      'id': 'center_carpet',
      'relativePosition': Vector2(0.5, 0.8),    // 200/400, 480/600
      'relativeSize': Vector2(0.3, 0.15),       // 120/400, 90/600
      'description': '装飾カーペット',
    },
    {
      'id': 'hidden_room_entrance_center',
      'relativePosition': Vector2(0.5, 0.25),   // 200/400, 150/600
      'relativeSize': Vector2(0.12, 0.08),      // 48/400, 48/600
      'description': '隠し部屋への入口',
    },
  ];
}