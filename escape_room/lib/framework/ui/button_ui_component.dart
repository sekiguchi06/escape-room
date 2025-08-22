import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'ui_component_base.dart';
import 'ui_layer_priority.dart';
import 'text_ui_component.dart';

/// ボタンUIコンポーネント
class ButtonUIComponent extends UIComponent<String>
    with TapCallbacks, HasGameReference {
  late RectangleComponent _background;
  late TextUIComponent _textComponent;

  String _text = '';
  final String _styleId;
  String _colorId;
  void Function()? onPressed;

  ButtonUIComponent({
    String text = '',
    String styleId = 'medium',
    String colorId = 'primary',
    this.onPressed,
    super.position,
    Vector2? size,
    super.themeId,
  }) : _text = text,
       _styleId = styleId,
       _colorId = colorId,
       super(size: size ?? Vector2(120, 40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ボタンは高優先度でイベントを処理
    priority = UILayerPriority.ui;

    // 背景
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = getThemeColor(_colorId),
    );
    add(_background);

    // テキスト
    _textComponent = TextUIComponent(
      text: _text,
      styleId: _styleId,
      position: Vector2(size.x / 2, size.y / 2),
      themeId: themeId,
    );
    _textComponent.anchor = Anchor.center;
    add(_textComponent);
  }

  /// ボタンテキストを設定
  void setText(String text) {
    _text = text;
    _textComponent.setText(text);
  }

  /// 現在のテキストを取得
  String get text => _text;

  /// ボタンの色を設定
  void setColor(String colorId) {
    _colorId = colorId;
    if (isMounted) {
      _background.paint.color = getThemeColor(_colorId);
    }
  }

  @override
  void updateContent(String content) {
    setText(content);
  }

  @override
  void onThemeChanged() {
    super.onThemeChanged();
    if (isMounted) {
      _background.paint.color = getThemeColor(_colorId);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // ボタン押下時のビジュアルフィードバック
    if (isMounted) {
      _background.paint.color = getThemeColor(_colorId).withValues(alpha: 0.8);
    }
    // Flame公式: イベント伝播を停止（デフォルトで停止するが明示）
    // continuePropagationを設定しないことでイベント伝播を停止
  }

  @override
  void onTapUp(TapUpEvent event) {
    // ボタンを離した時の処理
    if (isMounted) {
      _background.paint.color = getThemeColor(_colorId);
      onPressed?.call();
    }
    // Flame公式: イベント伝播を停止（デフォルトで停止するが明示）
    // continuePropagationを設定しないことでイベント伝播を停止
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // タップがキャンセルされた時の処理
    if (isMounted) {
      _background.paint.color = getThemeColor(_colorId);
    }
    // Flame公式: イベント伝播を停止（デフォルトで停止）
  }

  /// ボタンを無効化
  void setEnabled(bool enabled) {
    setProperty('enabled', enabled);
    if (isMounted) {
      final alpha = enabled ? 1.0 : 0.5;
      _background.paint.color = getThemeColor(
        _colorId,
      ).withValues(alpha: alpha);
    }
  }

  /// ボタンが有効かどうか
  bool get isEnabled => getProperty<bool>('enabled') ?? true;

  /// ボタンのアニメーション（スケール）
  void animatePress({double duration = 0.1}) {
    if (isMounted) {
      add(
        ScaleEffect.to(
          Vector2.all(0.95),
          EffectController(duration: duration, reverseDuration: duration),
        ),
      );
    }
  }

  /// ボタンのホバー効果
  void setHovered(bool hovered) {
    if (isMounted) {
      final alpha = hovered ? 0.9 : 1.0;
      _background.paint.color = getThemeColor(
        _colorId,
      ).withValues(alpha: alpha);
    }
  }
}
