import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'flutter_theme_system.dart';

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

/// レスポンシブUIコンポーネント基底クラス
/// 画面サイズの変更に対応するUIコンポーネント
abstract class ResponsiveUIComponent<T> extends UIComponent<T> {
  Vector2 _baseScreenSize = Vector2.zero();
  Vector2 _currentScreenSize = Vector2.zero();
  
  ResponsiveUIComponent({
    super.position,
    super.size,
    super.themeId,
    Vector2? baseScreenSize,
  }) {
    if (baseScreenSize != null) {
      _baseScreenSize = baseScreenSize;
      _currentScreenSize = baseScreenSize;
    }
  }
  
  /// 基準画面サイズを取得
  Vector2 get baseScreenSize => _baseScreenSize;
  
  /// 現在の画面サイズを取得
  Vector2 get currentScreenSize => _currentScreenSize;
  
  /// スケール比率を取得
  double get scaleRatio {
    if (_baseScreenSize.x == 0 || _baseScreenSize.y == 0) return 1.0;
    final scaleX = _currentScreenSize.x / _baseScreenSize.x;
    final scaleY = _currentScreenSize.y / _baseScreenSize.y;
    return (scaleX + scaleY) / 2; // 平均値を使用
  }
  
  /// 画面サイズを更新
  void updateScreenSize(Vector2 newSize) {
    if (_currentScreenSize != newSize) {
      _currentScreenSize = newSize;
      onScreenSizeChanged();
    }
  }
  
  /// 画面サイズ変更時のコールバック
  void onScreenSizeChanged() {
    // サブクラスでオーバーライド
  }
  
  /// スケールされたサイズを取得
  Vector2 getScaledSize(Vector2 originalSize) {
    return originalSize * scaleRatio;
  }
  
  /// スケールされたポジションを取得
  Vector2 getScaledPosition(Vector2 originalPosition) {
    return originalPosition * scaleRatio;
  }
}