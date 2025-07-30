import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'dart:math' as math;

/// 入力イベントの種類
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

/// 入力イベントデータ
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

/// 入力設定の基底クラス
abstract class InputConfiguration {
  /// タップ感度 (ピクセル単位での最大移動距離)
  double get tapSensitivity;
  
  /// ダブルタップ間隔 (ミリ秒)
  int get doubleTapInterval;
  
  /// 長押し時間 (ミリ秒)
  int get longPressDuration;
  
  /// スワイプ最小距離 (ピクセル)
  double get swipeMinDistance;
  
  /// スワイプ最大時間 (ミリ秒)
  int get swipeMaxDuration;
  
  /// ピンチ感度
  double get pinchSensitivity;
  
  /// 有効な入力タイプ
  Set<InputEventType> get enabledInputTypes;
  
  /// デバッグモード
  bool get debugMode;
}

/// デフォルト入力設定
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
    this.swipeMaxDuration = 1000,
    this.pinchSensitivity = 1.0,
    this.enabledInputTypes = const {
      InputEventType.tap,
      InputEventType.swipeUp,
      InputEventType.swipeDown,
      InputEventType.swipeLeft,
      InputEventType.swipeRight,
    },
    this.debugMode = false,
  });
  
  DefaultInputConfiguration copyWith({
    double? tapSensitivity,
    int? doubleTapInterval,
    int? longPressDuration,
    double? swipeMinDistance,
    int? swipeMaxDuration,
    double? pinchSensitivity,
    Set<InputEventType>? enabledInputTypes,
    bool? debugMode,
  }) {
    return DefaultInputConfiguration(
      tapSensitivity: tapSensitivity ?? this.tapSensitivity,
      doubleTapInterval: doubleTapInterval ?? this.doubleTapInterval,
      longPressDuration: longPressDuration ?? this.longPressDuration,
      swipeMinDistance: swipeMinDistance ?? this.swipeMinDistance,
      swipeMaxDuration: swipeMaxDuration ?? this.swipeMaxDuration,
      pinchSensitivity: pinchSensitivity ?? this.pinchSensitivity,
      enabledInputTypes: enabledInputTypes ?? this.enabledInputTypes,
      debugMode: debugMode ?? this.debugMode,
    );
  }
}

/// 入力プロセッサーの抽象インターフェース
abstract class InputProcessor {
  /// 初期化
  void initialize(InputConfiguration config);
  
  /// タップダウンイベント処理
  bool processTapDown(Vector2 position);
  
  /// タップアップイベント処理
  bool processTapUp(Vector2 position);
  
  /// タップキャンセルイベント処理
  bool processTapCancel();
  
  /// ドラッグ開始イベント処理
  bool processPanStart(Vector2 position);
  
  /// ドラッグ更新イベント処理
  bool processPanUpdate(Vector2 position, Vector2 delta);
  
  /// ドラッグ終了イベント処理
  bool processPanEnd(Vector2 position, Vector2 velocity);
  
  /// スケール開始イベント処理
  bool processScaleStart(Vector2 focalPoint);
  
  /// スケール更新イベント処理
  bool processScaleUpdate(Vector2 focalPoint, double scale);
  
  /// スケール終了イベント処理
  bool processScaleEnd();
  
  /// フレーム更新処理
  void update(double deltaTime);
  
  /// 入力イベントリスナー登録
  void addInputListener(void Function(InputEventData event) listener);
  
  /// 入力イベントリスナー削除
  void removeInputListener(void Function(InputEventData event) listener);
  
  /// 設定更新
  void updateConfiguration(InputConfiguration config);
  
  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo();
}

/// 基本入力プロセッサー
class BasicInputProcessor implements InputProcessor {
  InputConfiguration _config = const DefaultInputConfiguration();
  final List<void Function(InputEventData)> _listeners = [];
  
  // タップ関連
  Vector2? _tapDownPosition;
  DateTime? _tapDownTime;
  DateTime? _lastTapTime;
  Vector2? _lastTapPosition;
  
  // ドラッグ関連
  Vector2? _panStartPosition;
  DateTime? _panStartTime;
  bool _isPanning = false;
  
  // スケール関連
  Vector2? _scaleStartFocalPoint;
  double _scaleStartScale = 1.0;
  bool _isScaling = false;
  
  @override
  void initialize(InputConfiguration config) {
    _config = config;
    debugPrint('BasicInputProcessor initialized');
  }
  
  @override
  bool processTapDown(Vector2 position) {
    _tapDownPosition = position;
    _tapDownTime = DateTime.now();
    
    if (_config.debugMode) {
      debugPrint('Tap down at: $position');
    }
    
    return true;
  }
  
  @override
  bool processTapUp(Vector2 position) {
    if (_tapDownPosition == null || _tapDownTime == null) return false;
    
    final distance = (_tapDownPosition! - position).length;
    final duration = DateTime.now().difference(_tapDownTime!);
    
    // タップ判定
    if (distance <= _config.tapSensitivity) {
      _handleTapEvent(position, duration);
    }
    
    _tapDownPosition = null;
    _tapDownTime = null;
    
    return true;
  }
  
  @override
  bool processTapCancel() {
    _tapDownPosition = null;
    _tapDownTime = null;
    return true;
  }
  
  @override
  bool processPanStart(Vector2 position) {
    _panStartPosition = position;
    _panStartTime = DateTime.now();
    _isPanning = true;
    
    if (_config.debugMode) {
      debugPrint('Pan start at: $position');
    }
    
    return true;
  }
  
  @override
  bool processPanUpdate(Vector2 position, Vector2 delta) {
    if (!_isPanning) return false;
    
    if (_config.debugMode) {
      debugPrint('Pan update at: $position, delta: $delta');
    }
    
    return true;
  }
  
  @override
  bool processPanEnd(Vector2 position, Vector2 velocity) {
    if (!_isPanning || _panStartPosition == null || _panStartTime == null) {
      return false;
    }
    
    final distance = (_panStartPosition! - position).length;
    final duration = DateTime.now().difference(_panStartTime!);
    
    // スワイプ判定
    if (distance >= _config.swipeMinDistance && 
        duration.inMilliseconds <= _config.swipeMaxDuration) {
      _handleSwipeEvent(_panStartPosition!, position, velocity, duration);
    }
    
    _isPanning = false;
    _panStartPosition = null;
    _panStartTime = null;
    
    return true;
  }
  
  @override
  bool processScaleStart(Vector2 focalPoint) {
    _scaleStartFocalPoint = focalPoint;
    _scaleStartScale = 1.0;
    _isScaling = true;
    
    if (_config.debugMode) {
      debugPrint('Scale start at: $focalPoint');
    }
    
    return true;
  }
  
  @override
  bool processScaleUpdate(Vector2 focalPoint, double scale) {
    if (!_isScaling) return false;
    
    final scaleDelta = scale - _scaleStartScale;
    
    if (scaleDelta.abs() > _config.pinchSensitivity) {
      final eventType = scaleDelta > 0 ? InputEventType.pinchOut : InputEventType.pinchIn;
      
      if (_config.enabledInputTypes.contains(eventType)) {
        _notifyListeners(InputEventData(
          type: eventType,
          position: focalPoint,
          additionalData: {'scale': scale, 'scaleDelta': scaleDelta},
        ));
      }
      
      _scaleStartScale = scale;
    }
    
    return true;
  }
  
  @override
  bool processScaleEnd() {
    _isScaling = false;
    _scaleStartFocalPoint = null;
    _scaleStartScale = 1.0;
    
    return true;
  }
  
  @override
  void update(double deltaTime) {
    // 長押し判定
    if (_tapDownPosition != null && _tapDownTime != null) {
      final duration = DateTime.now().difference(_tapDownTime!);
      
      if (duration.inMilliseconds >= _config.longPressDuration &&
          _config.enabledInputTypes.contains(InputEventType.longPress)) {
        
        _notifyListeners(InputEventData(
          type: InputEventType.longPress,
          position: _tapDownPosition,
          duration: duration,
        ));
        
        // 長押しイベント発火後はタップ状態をクリア
        _tapDownPosition = null;
        _tapDownTime = null;
      }
    }
  }
  
  void _handleTapEvent(Vector2 position, Duration duration) {
    final now = DateTime.now();
    
    // ダブルタップ判定
    if (_lastTapTime != null && _lastTapPosition != null) {
      final timeDiff = now.difference(_lastTapTime!).inMilliseconds;
      final positionDiff = (_lastTapPosition! - position).length;
      
      if (timeDiff <= _config.doubleTapInterval && 
          positionDiff <= _config.tapSensitivity &&
          _config.enabledInputTypes.contains(InputEventType.doubleTap)) {
        
        _notifyListeners(InputEventData(
          type: InputEventType.doubleTap,
          position: position,
          duration: duration,
        ));
        
        _lastTapTime = null;
        _lastTapPosition = null;
        return;
      }
    }
    
    // 通常のタップ
    if (_config.enabledInputTypes.contains(InputEventType.tap)) {
      _notifyListeners(InputEventData(
        type: InputEventType.tap,
        position: position,
        duration: duration,
      ));
    }
    
    _lastTapTime = now;
    _lastTapPosition = position;
  }
  
  void _handleSwipeEvent(Vector2 startPos, Vector2 endPos, Vector2 velocity, Duration duration) {
    final delta = endPos - startPos;
    final distance = delta.length;
    final velocityMagnitude = velocity.length;
    
    // スワイプ方向判定
    InputEventType? swipeType;
    
    if (delta.x.abs() > delta.y.abs()) {
      // 横方向のスワイプ
      swipeType = delta.x > 0 ? InputEventType.swipeRight : InputEventType.swipeLeft;
    } else {
      // 縦方向のスワイプ
      swipeType = delta.y > 0 ? InputEventType.swipeDown : InputEventType.swipeUp;
    }
    
    if (_config.enabledInputTypes.contains(swipeType)) {
      _notifyListeners(InputEventData(
        type: swipeType,
        startPosition: startPos,
        endPosition: endPos,
        position: endPos,
        distance: distance,
        velocity: velocityMagnitude,
        duration: duration,
        additionalData: {'delta': delta},
      ));
    }
  }
  
  void _notifyListeners(InputEventData event) {
    if (_config.debugMode) {
      debugPrint('Input event: $event');
    }
    
    for (final listener in _listeners) {
      listener(event);
    }
  }
  
  @override
  void addInputListener(void Function(InputEventData event) listener) {
    _listeners.add(listener);
  }
  
  @override
  void removeInputListener(void Function(InputEventData event) listener) {
    _listeners.remove(listener);
  }
  
  @override
  void updateConfiguration(InputConfiguration config) {
    _config = config;
  }
  
  @override
  Map<String, dynamic> getDebugInfo() {
    return {
      'processor': runtimeType.toString(),
      'is_panning': _isPanning,
      'is_scaling': _isScaling,
      'listeners_count': _listeners.length,
      'enabled_input_types': _config.enabledInputTypes.map((e) => e.name).toList(),
      'tap_sensitivity': _config.tapSensitivity,
      'swipe_min_distance': _config.swipeMinDistance,
      'debug_mode': _config.debugMode,
    };
  }
}

/// 入力マネージャー
class InputManager {
  InputProcessor _processor;
  InputConfiguration _configuration;
  
  InputManager({
    required InputProcessor processor,
    required InputConfiguration configuration,
  }) : _processor = processor, _configuration = configuration;
  
  /// 現在のプロセッサー
  InputProcessor get processor => _processor;
  
  /// 現在の設定
  InputConfiguration get configuration => _configuration;
  
  /// 初期化
  void initialize() {
    _processor.initialize(_configuration);
  }
  
  /// プロセッサー変更
  void setProcessor(InputProcessor newProcessor) {
    _processor = newProcessor;
    _processor.initialize(_configuration);
  }
  
  /// 設定更新
  void updateConfiguration(InputConfiguration newConfiguration) {
    _configuration = newConfiguration;
    _processor.updateConfiguration(_configuration);
  }
  
  /// 入力イベントリスナー登録
  void addInputListener(void Function(InputEventData event) listener) {
    _processor.addInputListener(listener);
  }
  
  /// 入力イベントリスナー削除
  void removeInputListener(void Function(InputEventData event) listener) {
    _processor.removeInputListener(listener);
  }
  
  /// フレーム更新
  void update(double deltaTime) {
    _processor.update(deltaTime);
  }
  
  /// 入力イベント統合（Vector2で処理）
  bool handleTapDown(Vector2 position) {
    return _processor.processTapDown(position);
  }
  
  bool handleTapUp(Vector2 position) {
    return _processor.processTapUp(position);
  }
  
  bool handleTapCancel() {
    return _processor.processTapCancel();
  }
  
  bool handlePanStart(Vector2 position) {
    return _processor.processPanStart(position);
  }
  
  bool handlePanUpdate(Vector2 position, Vector2 delta) {
    return _processor.processPanUpdate(position, delta);
  }
  
  bool handlePanEnd(Vector2 position, Vector2 velocity) {
    return _processor.processPanEnd(position, velocity);
  }
  
  bool handleScaleStart(Vector2 focalPoint) {
    return _processor.processScaleStart(focalPoint);
  }
  
  bool handleScaleUpdate(Vector2 focalPoint, double scale) {
    return _processor.processScaleUpdate(focalPoint, scale);
  }
  
  bool handleScaleEnd() {
    return _processor.processScaleEnd();
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'manager': runtimeType.toString(),
      'configuration': _configuration.runtimeType.toString(),
      'processor_info': _processor.getDebugInfo(),
    };
  }
}

