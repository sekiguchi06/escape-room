import 'package:flame/components.dart';
import 'package:flame/events.dart';

/// 最小限の基底ゲームオブジェクト
/// 🎯 目的: Flame PositionComponent拡張の基底クラス
abstract class BaseGameObject extends PositionComponent with TapCallbacks {
  final String objectId;
  
  BaseGameObject({required this.objectId});
  
  /// オブジェクトの現在状態を取得
  Map<String, dynamic> getState() {
    return {
      'objectId': objectId,
      'position': {'x': position.x, 'y': position.y},
      'size': {'width': size.x, 'height': size.y},
    };
  }
  
  @override
  String toString() {
    return '$runtimeType(id: $objectId)';
  }
}