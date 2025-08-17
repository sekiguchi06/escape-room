import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

/// 音声再生コンポーネント
/// 🎯 目的: 音声管理機能を提供
class AudioComponent extends Component {
  final Map<String, String> _soundPaths = {};
  
  /// 音声セット読み込み
  Future<void> loadSounds(Map<String, String> soundPaths) async {
    _soundPaths.addAll(soundPaths);
  }
  
  /// 音声再生
  void play(String soundKey) {
    if (_soundPaths.containsKey(soundKey)) {
      // スケルトン実装: 実際の音声再生は後フェーズ
      debugPrint('Playing sound: $soundKey');
    }
  }
  
  /// アクティベーション音再生
  void playActivationSound() {
    play('activate');
  }
  
  /// リソース解放
  void dispose() {
    _soundPaths.clear();
  }
}