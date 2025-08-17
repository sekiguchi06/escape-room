import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'ui_component_base.dart';
import 'japanese_message_system.dart';

/// テキスト表示UIコンポーネント
class TextUIComponent extends UIComponent<String> {
  late TextComponent _textComponent;
  String _text = '';
  String _styleId = 'medium';
  
  TextUIComponent({
    String text = '',
    String styleId = 'medium',
    super.position,
    super.size,
    super.themeId,
  }) : _text = text,
       _styleId = styleId;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _textComponent = TextComponent(
      text: _text,
      textRenderer: JapaneseFontSystem.getTextPaint(18, Colors.black),
      position: Vector2.zero(),
    );
    _textComponent.anchor = Anchor.center;
    
    add(_textComponent);
  }
  
  /// テキストを設定
  void setText(String text, {String? styleId}) {
    _text = text;
    if (styleId != null) {
      _styleId = styleId;
    }
    
    if (isMounted) {
      _textComponent.text = _text;
      _textComponent.textRenderer = JapaneseFontSystem.getTextPaint(18, Colors.black);
    }
  }
  
  /// スタイルを適用
  void applyTextStyle(String styleId) {
    _styleId = styleId;
    if (isMounted) {
      _textComponent.textRenderer = JapaneseFontSystem.getTextPaint(18, Colors.black);
    }
  }
  
  /// 現在のテキストを取得
  String get text => _text;
  
  /// 現在のスタイルIDを取得
  String get styleId => _styleId;
  
  @override
  void updateContent(String content) {
    setText(content);
  }
  
  @override
  void onThemeChanged() {
    super.onThemeChanged();
    if (isMounted) {
      _textComponent.textRenderer = JapaneseFontSystem.getTextPaint(18, Colors.black);
    }
  }
  
  /// テキストの色を動的に変更
  void setTextColor(Color color) {
    if (isMounted) {
      _textComponent.textRenderer = JapaneseFontSystem.getTextPaint(18, color);
    }
  }
  
  /// テキストサイズを動的に変更
  void setTextSize(double size) {
    if (isMounted) {
      _textComponent.textRenderer = JapaneseFontSystem.getTextPaint(size, Colors.black);
    }
  }
  
  /// テキストの境界を取得
  Vector2 getTextBounds() {
    if (isMounted) {
      return _textComponent.size;
    }
    return Vector2.zero();
  }
  
  /// 複数行テキストを設定
  void setMultilineText(List<String> lines, {double lineSpacing = 1.2}) {
    final combinedText = lines.join('\n');
    setText(combinedText);
  }
  
  /// テキストのアニメーション（フェードイン）
  void fadeIn({double duration = 0.5}) {
    _textComponent.add(
      OpacityEffect.to(
        1.0,
        EffectController(duration: duration),
      ),
    );
  }
  
  /// テキストのアニメーション（フェードアウト）
  void fadeOut({double duration = 0.5}) {
    _textComponent.add(
      OpacityEffect.to(
        0.0,
        EffectController(duration: duration),
      ),
    );
  }
}