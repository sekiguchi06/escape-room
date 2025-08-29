import 'package:flame/components.dart';

/// 入力イベントの種類（既存互換）
enum InputEventType {
  tap,
  doubleTap,
  longPress,
  swipeUp,
  swipeDown,
  swipeLeft,
  swipeRight,
  pinchIn,
  pinchOut,
  multiTouch,
}

/// 入力イベントデータ（既存互換）
class InputEventData {
  final InputEventType type;
  final Vector2? position;
  final Vector2? startPosition;
  final Vector2? endPosition;
  final double? distance;
  final double? velocity;
  final Duration? duration;
  final int? fingerCount;
  final Map<String, dynamic> additionalData;

  const InputEventData({
    required this.type,
    this.position,
    this.startPosition,
    this.endPosition,
    this.distance,
    this.velocity,
    this.duration,
    this.fingerCount,
    this.additionalData = const {},
  });

  @override
  String toString() {
    return 'InputEventData(type: $type, position: $position, distance: $distance, velocity: $velocity)';
  }
}

/// 入力設定の基底クラス（既存互換）
abstract class InputConfiguration {
  double get tapSensitivity;
  int get doubleTapInterval;
  int get longPressDuration;
  double get swipeMinDistance;
  int get swipeMaxDuration;
  double get pinchSensitivity;
  Set<InputEventType> get enabledInputTypes;
  bool get debugMode;
}

/// デフォルト入力設定（既存互換）
class DefaultInputConfiguration implements InputConfiguration {
  @override
  final double tapSensitivity;

  @override
  final int doubleTapInterval;

  @override
  final int longPressDuration;

  @override
  final double swipeMinDistance;

  @override
  final int swipeMaxDuration;

  @override
  final double pinchSensitivity;

  @override
  final Set<InputEventType> enabledInputTypes;

  @override
  final bool debugMode;

  const DefaultInputConfiguration({
    this.tapSensitivity = 10.0,
    this.doubleTapInterval = 300,
    this.longPressDuration = 500,
    this.swipeMinDistance = 50.0,
    this.swipeMaxDuration = 500,
    this.pinchSensitivity = 0.1,
    this.enabledInputTypes = const {
      InputEventType.tap,
      InputEventType.doubleTap,
      InputEventType.longPress,
      InputEventType.swipeUp,
      InputEventType.swipeDown,
      InputEventType.swipeLeft,
      InputEventType.swipeRight,
    },
    this.debugMode = false,
  });
}