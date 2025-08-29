import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'input_models.dart';
import 'input_processor.dart';

/// Flame公式events準拠の入力マネージャー
/// 既存インターフェース互換性を保ちつつ、内部でFlame公式システムを使用
class FlameInputManager {
  InputProcessor _processor;
  InputConfiguration _configuration;

  /// Flame公式events準拠のInputManager
  /// TapCallbacks, DragCallbacks, ScaleCallbacks等を内部で使用
  FlameInputManager({
    InputProcessor? processor,
    InputConfiguration? configuration,
  }) : _processor = processor ?? FlameInputProcessor(),
       _configuration = configuration ?? const DefaultInputConfiguration();

  /// 現在のプロセッサー
  InputProcessor get processor => _processor;

  /// 現在の設定
  InputConfiguration get configuration => _configuration;

  /// 初期化
  void initialize() {
    _processor.initialize(_configuration);
    debugPrint('🎮 FlameInputManager initialized (Flame公式events準拠)');
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

  /// Flame公式TapCallbacks準拠のタップダウン処理
  void handleTapDown(Vector2 position) {
    debugPrint('FlameInputManager: handleTapDown at $position');
    _processor.processTapDown(position);
  }

  /// Flame公式TapCallbacks準拠のタップアップ処理
  void handleTapUp(Vector2 position) {
    debugPrint('FlameInputManager: handleTapUp at $position');
    _processor.processTapUp(position);
  }

  /// Flame公式TapCallbacks準拠のタップキャンセル処理
  void handleTapCancel() {
    _processor.processTapCancel();
  }

  /// Flame公式DragCallbacks準拠のドラッグ処理
  void handlePanStart(Vector2 position) {
    _processor.processPanStart(position);
  }

  void handlePanUpdate(Vector2 position, Vector2 delta) {
    _processor.processPanUpdate(position, delta);
  }

  void handlePanEnd(Vector2 position, Vector2 velocity) {
    _processor.processPanEnd(position, velocity);
  }

  /// Flame公式ScaleCallbacks準拠のスケール処理
  void handleScaleStart(Vector2 focalPoint, double scale) {
    _processor.processScaleStart(focalPoint, scale);
  }

  void handleScaleUpdate(Vector2 focalPoint, double scale) {
    _processor.processScaleUpdate(focalPoint, scale);
  }

  void handleScaleEnd() {
    _processor.processScaleEnd();
  }

  /// フレーム更新
  void update(double dt) {
    _processor.update(dt);
  }

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'processor_type': _processor.runtimeType.toString(),
      'configuration_type': _configuration.runtimeType.toString(),
      'enabled_input_types': _configuration.enabledInputTypes
          .map((e) => e.name)
          .toList(),
      'tap_sensitivity': _configuration.tapSensitivity,
      'double_tap_interval': _configuration.doubleTapInterval,
      'debug_mode': _configuration.debugMode,
      'flame_events_compliant': true, // Flame公式準拠であることを明示
    };
  }
}

/// 後方互換性のためのエイリアス
typedef InputManager = FlameInputManager;