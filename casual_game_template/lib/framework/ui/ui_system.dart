import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'flutter_theme_system.dart';

/// UI階層の優先度定義
class UILayerPriority {
  static const int background = 0;
  static const int gameContent = 100;
  static const int ui = 200;
  static const int modal = 300;
  static const int overlay = 400;
  static const int tooltip = 500;
}

/// UIレイアウトマネージャー
/// 画面サイズに応じたUI要素の配置を管理
class UILayoutManager {
  /// 右寄せ配置（マージン付き）
  static Vector2 topRight(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      screenSize.x - componentSize.x - margin,
      margin,
    );
  }
  
  /// 左寄せ配置（マージン付き）
  static Vector2 topLeft(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(margin, margin);
  }
  
  /// 中央配置
  static Vector2 center(Vector2 screenSize, Vector2 componentSize) {
    return Vector2(
      (screenSize.x - componentSize.x) / 2,
      (screenSize.y - componentSize.y) / 2,
    );
  }
  
  /// 下部中央配置（マージン付き）
  static Vector2 bottomCenter(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      (screenSize.x - componentSize.x) / 2,
      screenSize.y - componentSize.y - margin,
    );
  }
  
  /// 右寄せ中央配置（マージン付き） - 互換性のため残す
  static Vector2 centerRight(Vector2 screenSize, Vector2 componentSize, double margin) {
    return topRight(screenSize, componentSize, margin);
  }
  
  /// 上下中央、左配置
  static Vector2 centerLeft(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      margin,
      (screenSize.y - componentSize.y) / 2,
    );
  }
  
  /// 上配置、左右中央
  static Vector2 topCenter(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      (screenSize.x - componentSize.x) / 2,
      margin,
    );
  }
  
  /// グリッドレイアウト
  static List<Vector2> grid(
    Vector2 parentSize,
    Vector2 childSize,
    int columns,
    int rows, {
    EdgeInsets padding = EdgeInsets.zero,
    double spacing = 8.0,
  }) {
    final positions = <Vector2>[];
    final availableWidth = parentSize.x - padding.left - padding.right - (spacing * (columns - 1));
    final availableHeight = parentSize.y - padding.top - padding.bottom - (spacing * (rows - 1));
    
    final cellWidth = availableWidth / columns;
    final cellHeight = availableHeight / rows;
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final x = padding.left + col * (cellWidth + spacing) + (cellWidth - childSize.x) / 2;
        final y = padding.top + row * (cellHeight + spacing) + (cellHeight - childSize.y) / 2;
        positions.add(Vector2(x, y));
      }
    }
    
    return positions;
  }
}





/// 汎用UIコンポーネント基底クラス（Flutter公式ThemeData準拠）
/// FlutterThemeManagerを内部で使用し、Material Design準拠のテーマシステムを利用
abstract class UIComponent<T> extends PositionComponent {
  String _themeId = 'default';
  final Map<String, dynamic> _properties = {};
  
  UIComponent({
    super.position,
    super.size,
    String? themeId,
  }) : super() {
    if (themeId != null) {
      _themeId = themeId;
    }
  }
  
  /// 現在のテーマを取得（Flutter公式ThemeData準拠）
  /// Material Design準拠の色・スタイル取得
  UITheme get theme => FlutterThemeManager().currentTheme;
  Color getThemeColor(String key) => theme.getColor(key);
  double getThemeFontSize(String key) => theme.getFontSize(key);
  double getThemeSpacing(String key) => theme.getSpacing(key);
  
  /// テーマIDを取得
  String get themeId => _themeId;
  
  /// テーマを更新
  void updateTheme(String newThemeId) {
    if (_themeId != newThemeId) {
      _themeId = newThemeId;
      onThemeChanged();
    }
  }
  
  /// プロパティを設定
  void setProperty(String key, dynamic value) {
    _properties[key] = value;
    onPropertyChanged(key, value);
  }
  
  /// プロパティを取得
  U? getProperty<U>(String key) {
    final value = _properties[key];
    return value is U ? value : null;
  }
  
  /// すべてのプロパティを取得
  Map<String, dynamic> getAllProperties() {
    return Map.unmodifiable(_properties);
  }
  
  /// テーマ変更時のコールバック
  void onThemeChanged() {
    // サブクラスでオーバーライド
  }
  
  /// プロパティ変更時のコールバック
  void onPropertyChanged(String key, dynamic value) {
    // サブクラスでオーバーライド
  }
  
  /// コンテンツを更新（サブクラスで実装）
  void updateContent(T content);
}

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
      textRenderer: TextPaint(style: theme.getTextStyle(_styleId)),
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
      _textComponent.textRenderer = TextPaint(style: theme.getTextStyle(_styleId));
    }
  }
  
  /// スタイルを適用
  void applyTextStyle(String styleId) {
    _styleId = styleId;
    if (isMounted) {
      _textComponent.textRenderer = TextPaint(style: theme.getTextStyle(_styleId));
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
      _textComponent.textRenderer = TextPaint(style: theme.getTextStyle(_styleId));
    }
  }
  
  /// テキストの色を動的に変更
  void setTextColor(Color color) {
    if (isMounted) {
      final currentStyle = theme.getTextStyle(_styleId);
      _textComponent.textRenderer = TextPaint(
        style: currentStyle.copyWith(color: color),
      );
    }
  }
  
  /// テキストサイズを動的に変更
  void setTextSize(double size) {
    if (isMounted) {
      final currentStyle = theme.getTextStyle(_styleId);
      _textComponent.textRenderer = TextPaint(
        style: currentStyle.copyWith(fontSize: size),
      );
    }
  }
}

/// ボタンUIコンポーネント
class ButtonUIComponent extends UIComponent<String> with TapCallbacks, HasGameReference {
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
}

/// 設定メニューUIコンポーネント
/// ゲーム設定の変更を提供するモーダルメニュー
class SettingsMenuComponent extends PositionComponent {
  late RectangleComponent _background;
  late TextUIComponent _titleText;
  final List<ButtonUIComponent> _buttons = [];
  
  final void Function(String difficulty)? onDifficultyChanged;
  final void Function()? onClosePressed;
  
  SettingsMenuComponent({
    this.onDifficultyChanged,
    this.onClosePressed,
  }) {
    size = Vector2(300, 400);
    // 設定メニューはモーダル内コンテンツとして高優先度
    priority = UILayerPriority.modal + 1;
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 背景（不透明な白）
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    add(_background);
    
    // タイトル
    _titleText = TextUIComponent(
      text: 'Settings',
      styleId: 'large',
      position: Vector2(size.x / 2, 40),
    );
    _titleText.anchor = Anchor.center;
    _titleText.setTextColor(Colors.black);
    add(_titleText);
    
    // 難易度変更ボタン
    _createDifficultyButtons();
    
    // 閉じるボタン
    final closeButton = ButtonUIComponent(
      text: 'Close',
      colorId: 'danger',
      position: Vector2(size.x / 2 - 60, size.y - 60),
      size: Vector2(120, 40),
      onPressed: () => onClosePressed?.call(),
    );
    _buttons.add(closeButton);
    add(closeButton);
  }
  
  void _createDifficultyButtons() {
    final difficulties = ['Easy', 'Default', 'Hard'];
    final buttonWidth = 80.0;
    final buttonHeight = 40.0;
    final spacing = 10.0;
    final totalWidth = difficulties.length * buttonWidth + (difficulties.length - 1) * spacing;
    final startX = (size.x - totalWidth) / 2;
    
    for (int i = 0; i < difficulties.length; i++) {
      final difficulty = difficulties[i];
      final button = ButtonUIComponent(
        text: difficulty,
        colorId: 'secondary',
        position: Vector2(
          startX + i * (buttonWidth + spacing),
          150,
        ),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () => onDifficultyChanged?.call(difficulty.toLowerCase()),
      );
      _buttons.add(button);
      add(button);
    }
  }
  
  @override
  void onRemove() {
    // ボタンのクリーンアップ
    for (final button in _buttons) {
      if (button.isMounted) {
        button.removeFromParent();
      }
    }
    _buttons.clear();
    super.onRemove();
  }
}


/// プログレスバーUIコンポーネント  
class ProgressBarUIComponent extends UIComponent<double> {
  late RectangleComponent _background;
  late RectangleComponent _foreground;
  
  double _progress = 0.0; // 0.0 - 1.0
  final String _backgroundColorId;
  final String _foregroundColorId;
  
  ProgressBarUIComponent({
    double progress = 0.0,
    String backgroundColorId = 'background',
    String foregroundColorId = 'primary',
    super.position,
    Vector2? size,
    super.themeId,
  }) : _progress = progress,
       _backgroundColorId = backgroundColorId,
       _foregroundColorId = foregroundColorId,
       super(size: size ?? Vector2(200, 20));
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 背景
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = getThemeColor(_backgroundColorId),
    );
    add(_background);
    
    // プログレス
    _foreground = RectangleComponent(
      size: Vector2(size.x * _progress, size.y),
      paint: Paint()..color = getThemeColor(_foregroundColorId),
    );
    add(_foreground);
  }
  
  /// プログレスを設定（0.0 - 1.0）
  void setProgress(double progress) {
    _progress = progress.clamp(0.0, 1.0);
    if (isMounted) {
      _foreground.size = Vector2(size.x * _progress, size.y);
    }
  }
  
  /// 現在のプログレスを取得
  double get progress => _progress;
  
  @override
  void updateContent(double content) {
    setProgress(content);
  }
  
  @override
  void onThemeChanged() {
    super.onThemeChanged();
    if (isMounted) {
      _background.paint.color = getThemeColor(_backgroundColorId);
      _foreground.paint.color = getThemeColor(_foregroundColorId);
    }
  }
}