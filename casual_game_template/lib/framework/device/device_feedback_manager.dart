import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// シンプルなデバイスフィードバック管理クラス
class DeviceFeedbackManager {
  static final DeviceFeedbackManager _instance = DeviceFeedbackManager._internal();
  factory DeviceFeedbackManager() => _instance;
  DeviceFeedbackManager._internal();

  bool _vibrationEnabled = true;
  bool _notificationsEnabled = false; // プッシュ通知機能無効化
  bool _isInitialized = false;

  // 設定の getter/setter
  bool get vibrationEnabled => _vibrationEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  set vibrationEnabled(bool value) {
    _vibrationEnabled = value;
    _saveSettings();
  }

  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    _saveSettings();
  }

  /// 初期化処理
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _loadSettings();
      _isInitialized = true;
      debugPrint('🔔 DeviceFeedbackManager initialized successfully');
    } catch (e) {
      debugPrint('❌ DeviceFeedbackManager initialization failed: $e');
    }
  }

  /// 設定の読み込み
  Future<void> _loadSettings() async {
    try {
      // SharedPreferencesから設定を読み込み（実際の実装では必要）
      // 現在はデフォルト値を使用
      _vibrationEnabled = true;
      _notificationsEnabled = false; // プッシュ通知機能無効化
    } catch (e) {
      debugPrint('⚠️ Failed to load settings: $e');
    }
  }

  /// 設定の保存
  Future<void> _saveSettings() async {
    try {
      // SharedPreferencesに設定を保存（実際の実装では必要）
      debugPrint('💾 Settings saved: vibration=$_vibrationEnabled, notifications=$_notificationsEnabled');
    } catch (e) {
      debugPrint('❌ Failed to save settings: $e');
    }
  }

  /// バイブレーション実行（基本実装）
  Future<void> vibrate({VibrationPattern pattern = VibrationPattern.light}) async {
    if (!_vibrationEnabled) return;

    try {
      // Web対応: システムフィードバックを使用
      if (kIsWeb) {
        await _webVibrate(pattern);
        return;
      }

      // モバイル対応: HapticFeedbackを使用
      switch (pattern) {
        case VibrationPattern.light:
          await HapticFeedback.lightImpact();
          break;
        case VibrationPattern.medium:
          await HapticFeedback.mediumImpact();
          break;
        case VibrationPattern.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case VibrationPattern.success:
          await HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.lightImpact();
          break;
        case VibrationPattern.error:
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.heavyImpact();
          break;
      }
    } catch (e) {
      debugPrint('❌ Vibration failed: $e');
    }
  }

  /// Web用バイブレーション
  Future<void> _webVibrate(VibrationPattern pattern) async {
    try {
      // Web環境では軽いフィードバックのみ
      debugPrint('🌐 Web vibration: $pattern');
    } catch (e) {
      debugPrint('⚠️ Web vibration not supported: $e');
    }
  }

  /// 通知表示（無効化済み）
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // プッシュ通知機能は無効化されています
    debugPrint('📨 Notification disabled: $title - $body');
    return;
  }

  /// ゲーム固有のフィードバック
  Future<void> gameActionVibrate(GameAction action) async {
    switch (action) {
      case GameAction.buttonTap:
        await vibrate(pattern: VibrationPattern.light);
        break;
      case GameAction.itemFound:
        await vibrate(pattern: VibrationPattern.medium);
        break;
      case GameAction.puzzleSolved:
        await vibrate(pattern: VibrationPattern.success);
        break;
      case GameAction.error:
        await vibrate(pattern: VibrationPattern.error);
        break;
      case GameAction.escape:
        await vibrate(pattern: VibrationPattern.heavy);
        break;
    }
  }

  /// リソース解放
  void dispose() {
    _isInitialized = false;
  }
}

/// バイブレーションパターン
enum VibrationPattern {
  light,    // 軽いタップ
  medium,   // 中程度の振動
  heavy,    // 強い振動
  success,  // 成功パターン
  error,    // エラーパターン
}

/// ゲームアクション
enum GameAction {
  buttonTap,     // ボタンタップ
  itemFound,     // アイテム発見
  puzzleSolved,  // パズル解決
  error,         // エラー
  escape,        // 脱出成功
}

