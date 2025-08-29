import 'package:flutter/material.dart';
import 'ui_theme.dart';

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
      textStyles: customTextStyles ?? const {},
      dimensions: customDimensions ?? const {},
      fontWeights: customFontWeights ?? const {},
      animationDurations: customAnimationDurations ?? const {},
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
      case 'light':
        return FontWeight.w300;
      case 'normal':
        return FontWeight.w400;
      case 'medium':
        return FontWeight.w500;
      case 'bold':
        return FontWeight.w700;
      case 'heavy':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  @override
  Duration getAnimationDuration(String animationId) {
    if (animationDurations.containsKey(animationId)) {
      return animationDurations[animationId]!;
    }

    // デフォルトのDuration値
    switch (animationId) {
      case 'fast':
        return const Duration(milliseconds: 150);
      case 'normal':
        return const Duration(milliseconds: 250);
      case 'slow':
        return const Duration(milliseconds: 400);
      default:
        return const Duration(milliseconds: 250);
    }
  }

  @override
  ThemeData toThemeData() {
    return _themeData;
  }
}