import 'package:flame/components.dart';

/// 隠し部屋のホットスポット定義
class HiddenRoomHotspots {
  /// 隠し部屋A
  static List<Map<String, dynamic>> get hiddenRoomADefinitions => [
    {
      'id': 'hidden_emblem_a_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋A：紋章A',
    },
  ];
  
  /// 隠し部屋B
  static List<Map<String, dynamic>> get hiddenRoomBDefinitions => [
    {
      'id': 'hidden_emblem_b_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋B：紋章B',
    },
  ];
  
  /// 隠し部屋C
  static List<Map<String, dynamic>> get hiddenRoomCDefinitions => [
    {
      'id': 'hidden_seal_c_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋C：封印C',
    },
  ];
  
  /// 隠し部屋D
  static List<Map<String, dynamic>> get hiddenRoomDDefinitions => [
    {
      'id': 'hidden_seal_d_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋D：封印D',
    },
  ];
  
  /// 隠し部屋E
  static List<Map<String, dynamic>> get hiddenRoomEDefinitions => [
    {
      'id': 'hidden_artifact_e_location',
      'relativePosition': Vector2(0.5, 0.4),
      'relativeSize': Vector2(0.15, 0.1),
      'description': '隠し部屋E：古代遺物E',
    },
  ];
}