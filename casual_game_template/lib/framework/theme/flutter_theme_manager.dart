import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Flutter Guideに基づくテーママネージャー
/// システム設定と連動するダークモード対応を提供
class FlutterThemeManager extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSystemDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isSystemDarkMode => _isSystemDarkMode;
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return _isSystemDarkMode;
    }
  }

  /// 初期化処理
  /// システム設定とユーザー設定を読み込み
  Future<void> initialize() async {
    await _loadThemeMode();
    await _detectSystemTheme();
    
    // システムテーマ変更の監視
    _listenToSystemThemeChanges();
  }

  /// システムのダークモード設定を検出
  Future<void> _detectSystemTheme() async {
    try {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _isSystemDarkMode = brightness == Brightness.dark;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to detect system theme: $e');
      _isSystemDarkMode = false;
    }
  }

  /// システムテーマ変更の監視
  void _listenToSystemThemeChanges() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      _detectSystemTheme();
    };
  }

  /// 保存されたテーマモードを読み込み
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];
    } catch (e) {
      debugPrint('Failed to load theme mode: $e');
      _themeMode = ThemeMode.system;
    }
  }

  /// テーマモードを設定して保存
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
    } catch (e) {
      debugPrint('Failed to save theme mode: $e');
    }
  }

  /// ライトテーマに切り替え
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// ダークテーマに切り替え
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// システム設定に従う
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// テーマの切り替え（ライト ↔ ダーク）
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setDarkTheme();
        break;
      case ThemeMode.dark:
        await setLightTheme();
        break;
      case ThemeMode.system:
        // システムテーマの場合は現在の表示に基づいて切り替え
        if (_isSystemDarkMode) {
          await setLightTheme();
        } else {
          await setDarkTheme();
        }
        break;
    }
  }

  /// システムテーマ変更の強制チェック
  /// デバッグ用途やテスト用途で使用
  Future<void> refreshSystemTheme() async {
    await _detectSystemTheme();
  }
}

/// グローバルなテーママネージャーインスタンス
final FlutterThemeManager themeManager = FlutterThemeManager();