import 'package:flame/components.dart';

/// 地下部屋のホットスポット定義
class UndergroundHotspots {
  /// 地下左部屋のホットスポット定義
  static List<Map<String, dynamic>> get undergroundLeftDefinitions => [
    {
      'id': 'underground_crystal_formation',
      'relativePosition': Vector2(0.3, 0.4),
      'relativeSize': Vector2(0.2, 0.133),
      'description': '地下左：闇のクリスタル',
    },
    {
      'id': 'hidden_room_entrance_c',
      'relativePosition': Vector2(0.85, 0.3),
      'relativeSize': Vector2(0.125, 0.083),
      'description': '隠し部屋C入口',
    },
  ];
  
  /// 地下右部屋のホットスポット定義
  static List<Map<String, dynamic>> get undergroundRightDefinitions => [
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
  
  /// 地下左奥のホットスポット定義
  static List<Map<String, dynamic>> get undergroundLeftmostDefinitions => [
    {
      'id': 'underground_ancient_altar',
      'relativePosition': Vector2(0.5, 0.45),
      'relativeSize': Vector2(0.2, 0.133),
      'description': '地下左奥：古代祭壇',
    },
  ];

  /// 地下右奥のホットスポット定義
  static List<Map<String, dynamic>> get undergroundRightmostDefinitions => [
    {
      'id': 'underground_final_seal',
      'relativePosition': Vector2(0.5, 0.5),
      'relativeSize': Vector2(0.25, 0.167),
      'description': '地下右奥：最終封印',
    },
    {
      'id': 'floor1_return_stairs_rightmost',
      'relativePosition': Vector2(0.1, 0.8),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '1階右奥への階段（デバッグ用解放済み）',
    },
  ];
}