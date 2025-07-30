import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// UIテーマの抽象基底クラス
abstract class UITheme {
  /// テキストスタイルを取得
  TextStyle getTextStyle(String styleId);
  
  /// 色を取得
  Color getColor(String colorId);
  
  /// サイズ・寸法を取得
  double getDimension(String dimensionId);
  
  /// フォントサイズを取得
  double getFontSize(String sizeId);
  
  /// フォント重みを取得
  FontWeight getFontWeight(String weightId);
  
  /// マージン・パディングを取得
  EdgeInsets getSpacing(String spacingId);
  
  /// アニメーション設定を取得
  Duration getAnimationDuration(String animationId);
}

/// デフォルトUIテーマ
class DefaultUITheme implements UITheme {
  final Map<String, TextStyle> _textStyles;
  final Map<String, Color> _colors;
  final Map<String, double> _dimensions;
  final Map<String, double> _fontSizes;
  final Map<String, FontWeight> _fontWeights;
  final Map<String, EdgeInsets> _spacings;
  final Map<String, Duration> _animationDurations;
  
  const DefaultUITheme({
    Map<String, TextStyle>? textStyles,
    Map<String, Color>? colors,
    Map<String, double>? dimensions,
    Map<String, double>? fontSizes,
    Map<String, FontWeight>? fontWeights,
    Map<String, EdgeInsets>? spacings,
    Map<String, Duration>? animationDurations,
  })  : _textStyles = textStyles ?? const {},
        _colors = colors ?? const {},
        _dimensions = dimensions ?? const {},
        _fontSizes = fontSizes ?? const {},
        _fontWeights = fontWeights ?? const {},
        _spacings = spacings ?? const {},
        _animationDurations = animationDurations ?? const {};
  
  @override
  TextStyle getTextStyle(String styleId) {
    return _textStyles[styleId] ?? TextStyle(
      fontSize: getFontSize(styleId),
      fontWeight: getFontWeight(styleId),
      color: getColor('text'),
    );
  }
  
  @override
  Color getColor(String colorId) {
    return _colors[colorId] ?? _getDefaultColor(colorId);
  }
  
  @override
  double getDimension(String dimensionId) {
    return _dimensions[dimensionId] ?? _getDefaultDimension(dimensionId);
  }
  
  @override
  double getFontSize(String sizeId) {
    return _fontSizes[sizeId] ?? _getDefaultFontSize(sizeId);
  }
  
  @override
  FontWeight getFontWeight(String weightId) {
    return _fontWeights[weightId] ?? _getDefaultFontWeight(weightId);
  }
  
  @override
  EdgeInsets getSpacing(String spacingId) {
    return _spacings[spacingId] ?? _getDefaultSpacing(spacingId);
  }
  
  @override
  Duration getAnimationDuration(String animationId) {
    return _animationDurations[animationId] ?? _getDefaultAnimationDuration(animationId);
  }
  
  Color _getDefaultColor(String colorId) {
    switch (colorId) {
      case 'primary': return Colors.blue;
      case 'secondary': return Colors.green;
      case 'danger': return Colors.red;
      case 'warning': return Colors.orange;
      case 'info': return Colors.cyan;
      case 'success': return Colors.green;
      case 'text': return Colors.white;
      case 'background': return Colors.black;
      default: return Colors.white;
    }
  }
  
  double _getDefaultDimension(String dimensionId) {
    switch (dimensionId) {
      case 'small': return 8.0;
      case 'medium': return 16.0;
      case 'large': return 24.0;
      case 'xlarge': return 32.0;
      default: return 16.0;
    }
  }
  
  double _getDefaultFontSize(String sizeId) {
    switch (sizeId) {
      case 'small': return 12.0;
      case 'medium': return 16.0;
      case 'large': return 20.0;
      case 'xlarge': return 24.0;
      case 'xxlarge': return 32.0;
      default: return 16.0;
    }
  }
  
  FontWeight _getDefaultFontWeight(String weightId) {
    switch (weightId) {
      case 'light': return FontWeight.w300;
      case 'normal': return FontWeight.w400;
      case 'medium': return FontWeight.w500;
      case 'bold': return FontWeight.w700;
      case 'heavy': return FontWeight.w900;
      default: return FontWeight.w400;
    }
  }
  
  EdgeInsets _getDefaultSpacing(String spacingId) {
    switch (spacingId) {
      case 'none': return EdgeInsets.zero;
      case 'small': return const EdgeInsets.all(8.0);
      case 'medium': return const EdgeInsets.all(16.0);
      case 'large': return const EdgeInsets.all(24.0);
      default: return const EdgeInsets.all(16.0);
    }
  }
  
  Duration _getDefaultAnimationDuration(String animationId) {
    switch (animationId) {
      case 'fast': return const Duration(milliseconds: 150);
      case 'normal': return const Duration(milliseconds: 250);
      case 'slow': return const Duration(milliseconds: 400);
      default: return const Duration(milliseconds: 250);
    }
  }
}

/// テーマ管理システム
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();
  
  final Map<String, UITheme> _themes = {};
  String _currentTheme = 'default';
  final List<void Function(String)> _listeners = [];
  
  /// テーマを登録
  void registerTheme(String id, UITheme theme) {
    _themes[id] = theme;
    
    // デフォルトテーマがない場合は最初に登録されたテーマをデフォルトに
    if (_themes.length == 1) {
      _currentTheme = id;
    }
  }
  
  /// テーマを設定
  void setTheme(String themeId) {
    if (_themes.containsKey(themeId)) {
      final oldTheme = _currentTheme;
      _currentTheme = themeId;
      
      if (oldTheme != _currentTheme) {
        _notifyListeners();
      }
    }
  }
  
  /// 現在のテーマを取得
  UITheme get currentTheme {
    return _themes[_currentTheme] ?? _getDefaultTheme();
  }
  
  /// 現在のテーマIDを取得
  String get currentThemeId => _currentTheme;
  
  /// 利用可能なテーマ一覧を取得
  List<String> getAvailableThemes() {
    return _themes.keys.toList();
  }
  
  /// テーマ変更リスナーを追加
  void addThemeChangeListener(void Function(String) listener) {
    _listeners.add(listener);
  }
  
  /// テーマ変更リスナーを削除
  void removeThemeChangeListener(void Function(String) listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_currentTheme);
    }
  }
  
  UITheme _getDefaultTheme() {
    return const DefaultUITheme();
  }
  
  /// デフォルトテーマを初期化
  void initializeDefaultThemes() {
    // ライトテーマ
    registerTheme('light', DefaultUITheme(
      colors: const {
        'primary': Colors.blue,
        'secondary': Colors.green,
        'text': Colors.black,
        'background': Colors.white,
      },
    ));
    
    // ダークテーマ
    registerTheme('dark', DefaultUITheme(
      colors: const {
        'primary': Colors.blueAccent,
        'secondary': Colors.greenAccent,
        'text': Colors.white,
        'background': Colors.black,
      },
    ));
    
    // ゲーム用テーマ
    registerTheme('game', DefaultUITheme(
      colors: const {
        'primary': Colors.orange,
        'secondary': Colors.purple,
        'text': Colors.white,
        'background': Colors.indigo,
      },
      fontSizes: const {
        'small': 14.0,
        'medium': 18.0,
        'large': 24.0,
        'xlarge': 32.0,
      },
    ));
  }
}

/// 汎用UIコンポーネント基底クラス
abstract class UIComponent<T> extends PositionComponent {
  String _themeId = 'default';
  final Map<String, dynamic> _properties = {};
  
  UIComponent({
    Vector2? position,
    Vector2? size,
    String? themeId,
  }) : super(position: position, size: size) {
    if (themeId != null) {
      _themeId = themeId;
    }
  }
  
  /// 現在のテーマを取得
  UITheme get theme => ThemeManager().currentTheme;
  
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
    Vector2? position,
    Vector2? size,
    String? themeId,
  }) : _text = text,
       _styleId = styleId,
       super(position: position, size: size, themeId: themeId);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    _textComponent = TextComponent(
      text: _text,
      textRenderer: TextPaint(style: theme.getTextStyle(_styleId)),
      position: Vector2.zero(),
    );
    
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
class ButtonUIComponent extends UIComponent<String> {
  late RectangleComponent _background;
  late TextUIComponent _textComponent;
  
  String _text = '';
  String _styleId = 'medium';
  String _colorId = 'primary';
  void Function()? onPressed;
  
  ButtonUIComponent({
    String text = '',
    String styleId = 'medium',
    String colorId = 'primary',
    this.onPressed,
    Vector2? position,
    Vector2? size,
    String? themeId,
  }) : _text = text,
       _styleId = styleId,
       _colorId = colorId,
       super(position: position, size: size ?? Vector2(120, 40), themeId: themeId);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 背景
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = theme.getColor(_colorId),
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
      _background.paint.color = theme.getColor(_colorId);
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
      _background.paint.color = theme.getColor(_colorId);
    }
  }
}

/// プログレスバーUIコンポーネント  
class ProgressBarUIComponent extends UIComponent<double> {
  late RectangleComponent _background;
  late RectangleComponent _foreground;
  
  double _progress = 0.0; // 0.0 - 1.0
  String _backgroundColorId = 'background';
  String _foregroundColorId = 'primary';
  
  ProgressBarUIComponent({
    double progress = 0.0,
    String backgroundColorId = 'background',
    String foregroundColorId = 'primary',
    Vector2? position,
    Vector2? size,
    String? themeId,
  }) : _progress = progress,
       _backgroundColorId = backgroundColorId,
       _foregroundColorId = foregroundColorId,
       super(position: position, size: size ?? Vector2(200, 20), themeId: themeId);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 背景
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = theme.getColor(_backgroundColorId),
    );
    add(_background);
    
    // プログレス
    _foreground = RectangleComponent(
      size: Vector2(size.x * _progress, size.y),
      paint: Paint()..color = theme.getColor(_foregroundColorId),
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
      _background.paint.color = theme.getColor(_backgroundColorId);
      _foreground.paint.color = theme.getColor(_foregroundColorId);
    }
  }
}

/// UIレイアウトマネージャー
class UILayoutManager {
  /// 中央配置
  static Vector2 center(Vector2 parentSize, Vector2 childSize) {
    return Vector2(
      (parentSize.x - childSize.x) / 2,
      (parentSize.y - childSize.y) / 2,
    );
  }
  
  /// 上下中央、左配置
  static Vector2 centerLeft(Vector2 parentSize, Vector2 childSize, double margin) {
    return Vector2(
      margin,
      (parentSize.y - childSize.y) / 2,
    );
  }
  
  /// 上下中央、右配置
  static Vector2 centerRight(Vector2 parentSize, Vector2 childSize, double margin) {
    return Vector2(
      parentSize.x - childSize.x - margin,
      (parentSize.y - childSize.y) / 2,
    );
  }
  
  /// 上配置、左右中央
  static Vector2 topCenter(Vector2 parentSize, Vector2 childSize, double margin) {
    return Vector2(
      (parentSize.x - childSize.x) / 2,
      margin,
    );
  }
  
  /// 下配置、左右中央
  static Vector2 bottomCenter(Vector2 parentSize, Vector2 childSize, double margin) {
    return Vector2(
      (parentSize.x - childSize.x) / 2,
      parentSize.y - childSize.y - margin,
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