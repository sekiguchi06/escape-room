import 'package:flutter/foundation.dart';

/// Web以外プラットフォーム用のスタブ実装
class WebAudioSystem {
  static final WebAudioSystem _instance = WebAudioSystem._internal();
  factory WebAudioSystem() => _instance;
  WebAudioSystem._internal();

  /// ビープ音を生成（スタブ - 何もしない）
  void playBeep({double frequency = 800.0, double duration = 0.3}) {
    if (kIsWeb) {
      // Web環境では実装されない（条件付きインポートエラー回避）
      debugPrint('⚠️ WebAudioSystem: Web以外でのplayBeep呼び出し');
    }
  }

  /// アクション別の音を再生（スタブ - 何もしない）
  void playActionSound(String actionType) {
    if (kIsWeb) {
      // Web環境では実装されない（条件付きインポートエラー回避）
      debugPrint('⚠️ WebAudioSystem: Web以外でのplayActionSound呼び出し');
    }
  }
}
