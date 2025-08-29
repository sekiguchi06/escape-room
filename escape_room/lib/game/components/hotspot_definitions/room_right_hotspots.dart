import 'base_hotspot_helpers.dart';

/// 錬金術室（room_right.png）のホットスポット定義
class RoomRightHotspots {
  static List<Map<String, dynamic>> get definitions => [
    // 1. 薬草・瓶エリア（L字型）
    BaseHotspotHelpers.createPolygonHotspot(
      id: 'left_herb_shelf',
      description: '薬草・瓶エリア（L字型）',
      gridCoordinates: [
        [0, 4],   // 左上
        [2, 4],   // 右上
        [2, 6],   // 右中
        [1, 6],   // 中央
        [1, 7],   // 中下
        [0, 7],   // 左下
      ],
    ),
    
    // 2. メイン操作エリア（六角形）
    BaseHotspotHelpers.createPolygonHotspot(
      id: 'center_main_shelf',
      description: 'メイン操作エリア（六角形）',
      gridCoordinates: [
        [3, 2],   // 上左
        [5, 2],   // 上右
        [6, 4],   // 右
        [5, 6],   // 下右
        [3, 6],   // 下左
        [2, 4],   // 左
      ],
    ),
    
    // 3. 器具・道具エリア（三角形）
    BaseHotspotHelpers.createPolygonHotspot(
      id: 'right_tool_shelf',
      description: '器具・道具エリア（三角形）',
      gridCoordinates: [
        [6, 6],   // 左下
        [8, 6],   // 右下
        [7, 8],   // 頂点
      ],
    ),
    
    // 4. 隠し部屋入口（円形近似）
    ...() {
      return [BaseHotspotHelpers.createPolygonHotspot(
        id: 'hidden_room_entrance_b',
        description: '隠し部屋B入口（円形）',
        gridCoordinates: [
          [6.5, 2],    // 上
          [7.3, 2.3],  // 右上
          [7.5, 3],    // 右
          [7.3, 3.7],  // 右下
          [6.5, 4],    // 下
          [5.7, 3.7],  // 左下
          [5.5, 3],    // 左
          [5.7, 2.3],  // 左上
        ],
      )];
    }(),
    
    // 5. 開かれた魔法書（指定された四角形）
    BaseHotspotHelpers.createPolygonHotspot(
      id: 'open_magic_book',
      description: '開かれた魔法書（カスタム四角形）',
      gridCoordinates: [
        [1, 8],     // 0,7の右下 → (1/8, 8/12)
        [1, 11],    // 0,11の右上 → (1/8, 11/12)
        [7.5, 8.5], // 7,8の中央 → (7.5/8, 8.5/12)
        [5.5, 7],   // 5,6の中央下 → (5.5/8, 7/12)
      ],
    ),
  ];
}