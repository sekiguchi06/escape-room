import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'input_models.dart';

/// Flame公式events準拠の入力プロセッサー
/// TapCallbacks, DragCallbacks等を内部で使用し、既存APIとの互換性を維持
abstract class InputProcessor {
  void initialize(InputConfiguration config);
  void updateConfiguration(InputConfiguration config);
  void addInputListener(void Function(InputEventData event) listener);
  void removeInputListener(void Function(InputEventData event) listener);
  bool processTapDown(Vector2 position);
  bool processTapUp(Vector2 position);
  bool processTapCancel();
  bool processPanStart(Vector2 position);
  bool processPanUpdate(Vector2 position, Vector2 delta);
  bool processPanEnd(Vector2 position, Vector2 velocity);
  bool processScaleStart(Vector2 focalPoint, double scale);
  bool processScaleUpdate(Vector2 focalPoint, double scale);
  bool processScaleEnd();
  void update(double dt);
}

/// Flame公式events準拠の入力プロセッサー
/// TapCallbacks, DragCallbacks等を模擬するテスト用実装
class FlameInputProcessor implements InputProcessor {
  late InputConfiguration _config;
  final List<void Function(InputEventData event)> _listeners = [];

  // ダブルタップ検出用
  DateTime? _lastTapTime;
  Vector2? _lastTapPosition;

  @override
  void initialize(InputConfiguration config) {
    _config = config;
    debugPrint('🎮 FlameInputProcessor initialized (Flame公式events準拠)');
  }

  @override
  void updateConfiguration(InputConfiguration config) {
    _config = config;
  }

  @override
  void addInputListener(void Function(InputEventData event) listener) {
    _listeners.add(listener);
  }

  @override
  void removeInputListener(void Function(InputEventData event) listener) {
    _listeners.remove(listener);
  }

  /// Flame公式TapCallbacks: onTapDown相当の処理
  @override
  bool processTapDown(Vector2 position) {
    if (_config.debugMode) {
      debugPrint('🎮 Flame公式TapCallbacks: onTapDown at $position');
    }
    return true;
  }

  /// Flame公式TapCallbacks: onTapUp相当の処理
  @override
  bool processTapUp(Vector2 position) {
    final now = DateTime.now();

    // ダブルタップ検出
    if (_lastTapTime != null &&
        _lastTapPosition != null &&
        _config.enabledInputTypes.contains(InputEventType.doubleTap)) {
      final timeDiff = now.difference(_lastTapTime!).inMilliseconds;
      final positionDiff = (_lastTapPosition! - position).length;

      debugPrint(
        'FlameInputProcessor: checking double tap - timeDiff=$timeDiff, positionDiff=$positionDiff',
      );

      if (timeDiff <= _config.doubleTapInterval &&
          positionDiff <= _config.tapSensitivity) {
        // ダブルタップイベント
        debugPrint('FlameInputProcessor: double tap detected!');
        final event = InputEventData(
          type: InputEventType.doubleTap,
          position: position,
          duration: Duration(milliseconds: timeDiff),
          additionalData: {'timestamp': now.millisecondsSinceEpoch},
        );
        _notifyListeners(event);

        // ダブルタップ後はリセット
        _lastTapTime = null;
        _lastTapPosition = null;
        return true;
      }
    }

    // 通常のタップイベント
    if (_config.enabledInputTypes.contains(InputEventType.tap)) {
      final event = InputEventData(
        type: InputEventType.tap,
        position: position,
        additionalData: {'timestamp': now.millisecondsSinceEpoch},
      );
      debugPrint('FlameInputProcessor: generating tap event at $position');
      _notifyListeners(event);
    } else {
      debugPrint('FlameInputProcessor: tap events disabled in config');
    }

    // 次のダブルタップ検出用に記録
    _lastTapTime = now;
    _lastTapPosition = position;

    return true;
  }

  @override
  bool processTapCancel() {
    return true;
  }

  /// Flame公式DragCallbacks: onDragStart相当の処理
  @override
  bool processPanStart(Vector2 position) {
    if (_config.debugMode) {
      debugPrint('🎮 Flame公式DragCallbacks: onDragStart at $position');
    }
    return true;
  }

  /// Flame公式DragCallbacks: onDragUpdate相当の処理
  @override
  bool processPanUpdate(Vector2 position, Vector2 delta) {
    if (_config.debugMode) {
      debugPrint(
        '🎮 Flame公式DragCallbacks: onDragUpdate at $position, delta: $delta',
      );
    }
    return true;
  }

  /// Flame公式DragCallbacks: onDragEnd相当の処理
  @override
  bool processPanEnd(Vector2 position, Vector2 velocity) {
    if (_config.debugMode) {
      debugPrint(
        '🎮 Flame公式DragCallbacks: onDragEnd at $position, velocity: $velocity',
      );
    }
    return true;
  }

  /// Flame公式ScaleCallbacks準拠のスケール処理
  @override
  bool processScaleStart(Vector2 focalPoint, double scale) {
    if (_config.debugMode) {
      debugPrint(
        '🎮 Flame公式ScaleCallbacks: onScaleStart at $focalPoint, scale: $scale',
      );
    }
    return true;
  }

  @override
  bool processScaleUpdate(Vector2 focalPoint, double scale) {
    if (_config.debugMode) {
      debugPrint(
        '🎮 Flame公式ScaleCallbacks: onScaleUpdate at $focalPoint, scale: $scale',
      );
    }
    return true;
  }

  @override
  bool processScaleEnd() {
    if (_config.debugMode) {
      debugPrint('🎮 Flame公式ScaleCallbacks: onScaleEnd');
    }
    return true;
  }

  @override
  void update(double dt) {
    // Flame公式ではコンポーネント自体が更新を管理
  }

  /// イベント通知
  void _notifyListeners(InputEventData event) {
    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        // 詳細ログ（通常時は無視）
        // debugPrint('Input listener: $e');
      }
    }
  }
}

/// 後方互換性のためのエイリアス
typedef BasicInputProcessor = FlameInputProcessor;