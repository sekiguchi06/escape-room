import 'package:flutter/material.dart';

/// Flutter公式ThemeData準拠のテーマシステム
/// 既存インターフェース互換性を保ちつつ、内部でFlutter公式ThemeDataを使用

/// テーマの設定値を管理するクラス（既存互換）
abstract class UITheme {
  /// テキストスタイルを取得（既存互換）
  TextStyle getTextStyle(String styleId);
  
  /// 色を取得
  Color getColor(String key);
  
  /// サイズ・寸法を取得（既存互換）
  double getDimension(String dimensionId);
  
  /// フォントサイズを取得
  double getFontSize(String key);
  
  /// フォント重みを取得（既存互換）
  FontWeight getFontWeight(String weightId);
  
  /// マージン/パディングを取得
  double getSpacing(String key);
  
  /// アニメーション設定を取得（既存互換）
  Duration getAnimationDuration(String animationId);
  
  /// Flutter公式ThemeDataに変換
  ThemeData toThemeData();
}

/// Flutter公式ThemeData準拠のデフォルトテーマ
/// Material Design準拠の実装
class FlutterUITheme implements UITheme {
  final Map<String, Color> colors;
  final Map<String, double> fontSizes;
  final Map<String, double> spacings;
  final Map<String, TextStyle> textStyles;
  final Map<String, double> dimensions;
  final Map<String, FontWeight> fontWeights;
  final Map<String, Duration> animationDurations;
  final ThemeData _themeData;
  
  /// Flutter公式ThemeData準拠のUITheme
  /// Material Design ColorSchemeを内部で使用
  const FlutterUITheme({
    this.colors = const {},
    this.fontSizes = const {},
    this.spacings = const {},
    this.textStyles = const {},
    this.dimensions = const {},
    this.fontWeights = const {},
    this.animationDurations = const {},
    required ThemeData themeData,
  }) : _themeData = themeData;
  
  /// Material Design Light準拠のテーマ作成
  factory FlutterUITheme.light({
    Map<String, Color>? customColors,
    Map<String, double>? customFontSizes,
    Map<String, double>? customSpacings,
    Map<String, TextStyle>? customTextStyles,
    Map<String, double>? customDimensions,
    Map<String, FontWeight>? customFontWeights,
    Map<String, Duration>? customAnimationDurations,
  }) {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    );
    
    final themeData = ThemeData(
      colorScheme: lightColorScheme,
      useMaterial3: true, // Material Design 3準拠
    );
    
    return FlutterUITheme(
      colors: {
        'primary': lightColorScheme.primary,
        'secondary': lightColorScheme.secondary,
        'text': lightColorScheme.onSurface,
        'background': lightColorScheme.surface,
        'error': lightColorScheme.error,
        ...?customColors,
      },
      fontSizes: {
        'small': 14.0,
        'medium': 16.0,
        'large': 18.0,
        'xlarge': 24.0,
        ...?customFontSizes,
      },
      spacings: {
        'small': 8.0,
        'medium': 16.0,
        'large': 24.0,
        'xlarge': 32.0,
        ...?customSpacings,
      },
      themeData: themeData,
    );
  }
  
  /// Material Design Dark準拠のテーマ作成
  factory FlutterUITheme.dark({
    Map<String, Color>? customColors,
    Map<String, double>? customFontSizes,
    Map<String, double>? customSpacings,
  }) {
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );
    
    final themeData = ThemeData(
      colorScheme: darkColorScheme,
      useMaterial3: true, // Material Design 3準拠
    );
    
    return FlutterUITheme(
      colors: {
        'primary': darkColorScheme.primary,
        'secondary': darkColorScheme.secondary,
        'text': darkColorScheme.onSurface,
        'background': darkColorScheme.surface,
        'error': darkColorScheme.error,
        ...?customColors,
      },
      fontSizes: {
        'small': 14.0,
        'medium': 16.0,
        'large': 18.0,
        'xlarge': 24.0,
        ...?customFontSizes,
      },
      spacings: {
        'small': 8.0,
        'medium': 16.0,
        'large': 24.0,
        'xlarge': 32.0,
        ...?customSpacings,
      },
      themeData: themeData,
    );
  }
  
  /// ゲーム用カスタムテーマ作成
  factory FlutterUITheme.game({
    Map<String, Color>? customColors,
    Map<String, double>? customFontSizes,
    Map<String, double>? customSpacings,
  }) {
    final gameColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    );
    
    final themeData = ThemeData(
      colorScheme: gameColorScheme,
      useMaterial3: true,
    );
    
    return FlutterUITheme(
      colors: {
        'primary': Colors.orange,
        'secondary': Colors.purple,
        'text': Colors.white,
        'background': Colors.indigo,
        'error': Colors.red,
        ...?customColors,
      },
      fontSizes: {
        'small': 14.0,
        'medium': 16.0,
        'large': 18.0,
        'xlarge': 24.0,
        ...?customFontSizes,
      },
      spacings: {
        'small': 8.0,
        'medium': 16.0,
        'large': 24.0,
        'xlarge': 32.0,
        ...?customSpacings,
      },
      themeData: themeData,
    );
  }
  
  @override
  Color getColor(String key) {
    return colors[key] ?? _themeData.colorScheme.primary;
  }
  
  @override
  double getFontSize(String key) {
    return fontSizes[key] ?? 16.0;
  }
  
  @override
  double getSpacing(String key) {
    return spacings[key] ?? 16.0;
  }
  
  @override
  TextStyle getTextStyle(String styleId) {
    // 既存のtextStylesマップがあれば使用、なければデフォルトスタイルを作成
    if (textStyles.containsKey(styleId)) {
      return textStyles[styleId]!;
    }
    
    // Flutter公式準拠のTextStyle作成
    return TextStyle(
      fontSize: getFontSize(styleId),
      color: getColor('text'),
      fontWeight: FontWeight.w400,
    );
  }
  
  @override
  double getDimension(String dimensionId) {
    return dimensions[dimensionId] ?? 16.0;
  }
  
  @override
  FontWeight getFontWeight(String weightId) {
    if (fontWeights.containsKey(weightId)) {
      return fontWeights[weightId]!;
    }
    
    // デフォルトのFontWeight値
    switch (weightId) {
      case 'light': return FontWeight.w300;
      case 'normal': return FontWeight.w400;
      case 'medium': return FontWeight.w500;
      case 'bold': return FontWeight.w700;
      case 'heavy': return FontWeight.w900;
      default: return FontWeight.w400;
    }
  }
  
  @override
  Duration getAnimationDuration(String animationId) {
    if (animationDurations.containsKey(animationId)) {
      return animationDurations[animationId]!;
    }
    
    // デフォルトのDuration値
    switch (animationId) {
      case 'fast': return const Duration(milliseconds: 150);
      case 'normal': return const Duration(milliseconds: 250);
      case 'slow': return const Duration(milliseconds: 400);
      default: return const Duration(milliseconds: 250);
    }
  }
  
  @override
  ThemeData toThemeData() {
    return _themeData;
  }
}

/// Flutter公式ThemeData準拠のテーマ管理システム
/// Theme.of(context)を内部で使用し、既存APIとの互換性を維持
class FlutterThemeManager {
  static final FlutterThemeManager _instance = FlutterThemeManager._internal();
  factory FlutterThemeManager() => _instance;
  FlutterThemeManager._internal();
  
  final Map<String, UITheme> _themes = {};
  String _currentTheme = 'light';
  final List<void Function(String)> _listeners = [];
  
  /// Flutter公式ThemeData準拠のテーママネージャー
  /// Material Design 3準拠のテーマ管理
  
  /// テーマを登録
  void registerTheme(String id, UITheme theme) {
    _themes[id] = theme;
    
    // デフォルトテーマがない場合は最初に登録されたテーマをデフォルトに
    if (_themes.length == 1) {
      _currentTheme = id;
    }
    
    debugPrint('🎨 Flutter公式ThemeData準拠: テーマ登録 $id');
  }
  
  /// テーマを設定
  void setTheme(String themeId) {
    if (_themes.containsKey(themeId)) {
      final oldTheme = _currentTheme;
      _currentTheme = themeId;
      
      if (oldTheme != _currentTheme) {
        _notifyListeners();
        debugPrint('🎨 Flutter公式ThemeData準拠: テーマ変更 $oldTheme → $themeId');
      }
    }
  }
  
  /// 現在のテーマを取得
  UITheme get currentTheme {
    return _themes[_currentTheme] ?? _getDefaultTheme();
  }
  
  /// 現在のテーマIDを取得
  String get currentThemeId => _currentTheme;
  
  /// 現在のFlutter公式ThemeDataを取得
  ThemeData get currentThemeData {
    return currentTheme.toThemeData();
  }
  
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
      try {
        listener(_currentTheme);
      } catch (e) {
        debugPrint('❌ ThemeManager listener error: $e');
      }
    }
  }
  
  UITheme _getDefaultTheme() {
    return FlutterUITheme.light();
  }
  
  /// Material Design 3準拠のデフォルトテーマを初期化
  void initializeDefaultThemes() {
    // Material Design Light テーマ
    registerTheme('light', FlutterUITheme.light());
    
    // Material Design Dark テーマ
    registerTheme('dark', FlutterUITheme.dark());
    
    // ゲーム用カスタムテーマ
    registerTheme('game', FlutterUITheme.game());
    
    debugPrint('🎨 Flutter公式ThemeData準拠: デフォルトテーマ初期化完了');
  }
  
  /// システムテーマモード取得（Flutter公式準拠）
  ThemeMode getSystemThemeMode() {
    // システム設定に応じた自動切り替え
    switch (_currentTheme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system; // システム設定に従う
    }
  }
  
  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'current_theme': _currentTheme,
      'available_themes': getAvailableThemes(),
      'flutter_official_compliant': true, // Flutter公式準拠であることを明示
      'material_design_3': true, // Material Design 3準拠
      'theme_data_available': true, // ThemeData利用可能
    };
  }
}

/// 後方互換性のためのエイリアス
typedef ThemeManager = FlutterThemeManager;
typedef DefaultUITheme = FlutterUITheme;

/// Flutter公式Theme.of(context)準拠のUIコンポーネント基底クラス
abstract class FlutterThemedUIComponent {
  /// Flutter公式Theme.of(context)でテーマにアクセス
  /// Material Design準拠のテーマ取得
  UITheme getTheme(BuildContext context) {
    final themeData = Theme.of(context);
    
    // ThemeDataからUIThemeに変換
    return FlutterUITheme(
      colors: {
        'primary': themeData.colorScheme.primary,
        'secondary': themeData.colorScheme.secondary,
        'text': themeData.colorScheme.onSurface,
        'background': themeData.colorScheme.surface,
        'error': themeData.colorScheme.error,
      },
      fontSizes: const {
        'small': 14.0,
        'medium': 16.0,
        'large': 18.0,
        'xlarge': 24.0,
      },
      spacings: const {
        'small': 8.0,
        'medium': 16.0,
        'large': 24.0,
        'xlarge': 32.0,
      },
      themeData: themeData,
    );
  }
}