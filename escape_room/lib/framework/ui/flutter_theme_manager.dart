import 'package:flutter/material.dart';
import 'ui_theme.dart';
import 'flutter_ui_theme.dart';

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