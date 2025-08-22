import 'package:flutter/foundation.dart';
// package:webに移行（Flutter Web 3.22以降対応）
import 'package:web/web.dart' as web;

/// Web専用音響システム
/// HTML5 Audio APIを直接使用して確実な音響再生を実現
class WebAudioSystem {
  static final WebAudioSystem _instance = WebAudioSystem._internal();
  factory WebAudioSystem() => _instance;
  WebAudioSystem._internal();

  /// 基本ビープ音を生成・再生
  void playBeep({double frequency = 800.0, double duration = 0.3}) {
    if (!kIsWeb) return;

    try {
      final script =
          '''
        (function() {
          try {
            const audioContext = new (window.AudioContext || window.webkitAudioContext)();
            const oscillator = audioContext.createOscillator();
            const gainNode = audioContext.createGain();
            
            oscillator.connect(gainNode);
            gainNode.connect(audioContext.destination);
            
            oscillator.frequency.value = $frequency;
            oscillator.type = 'sine';
            
            gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
            gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + $duration);
            
            oscillator.start(audioContext.currentTime);
            oscillator.stop(audioContext.currentTime + $duration);
            
            console.log('🔊 Web beep sound played: ' + $frequency + 'Hz for ' + $duration + 's');
          } catch (e) {
            console.error('❌ Web audio error:', e);
          }
        })();
      ''';

      web.document.head?.appendChild(web.HTMLScriptElement()..text = script);
      debugPrint('🔊 WebAudioSystem: ビープ音再生 (${frequency}Hz)');
    } catch (e) {
      debugPrint('❌ WebAudioSystem エラー: $e');
    }
  }

  /// アクション別の音を再生
  void playActionSound(String actionType) {
    double frequency;
    double duration;

    switch (actionType) {
      case 'generalTap':
        frequency = 800.0;
        duration = 0.1;
        break;
      case 'uiButtonPress':
        frequency = 1000.0;
        duration = 0.15;
        break;
      case 'hotspotInteraction':
        frequency = 600.0;
        duration = 0.2;
        break;
      case 'itemAcquisition':
        frequency = 1200.0;
        duration = 0.25;
        break;
      case 'puzzleSuccess':
        frequency = 1500.0;
        duration = 0.4;
        break;
      case 'gimmickActivation':
        frequency = 700.0;
        duration = 0.3;
        break;
      case 'errorAction':
        frequency = 300.0;
        duration = 0.5;
        break;
      case 'gameCleared':
        frequency = 2000.0;
        duration = 1.0;
        break;
      default:
        frequency = 800.0;
        duration = 0.2;
    }

    playBeep(frequency: frequency, duration: duration);
  }
}
