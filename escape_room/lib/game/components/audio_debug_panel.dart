import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import '../../framework/audio/optimized_audio_system.dart';
import '../../framework/audio/integrated_audio_manager.dart';
import '../../framework/audio/enhanced_sfx_system.dart';

/// 音響デバッグパネル
class AudioDebugPanel extends StatelessWidget {
  const AudioDebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔊 音響デバッグ',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),

          // OptimizedAudioSystem 直接テスト
          ElevatedButton(
            onPressed: () async {
              try {
                final system = OptimizedAudioSystem();
                await system.initialize();
                await system.playActionSound(
                  GameActionType.generalTap,
                  volume: 1.0,
                );
                debugPrint('🔊 OptimizedAudioSystem: generalTap 再生');
              } catch (e) {
                debugPrint('❌ OptimizedAudioSystem テスト失敗: $e');
              }
            },
            child: const Text('直接音響テスト'),
          ),

          const SizedBox(height: 8),

          // IntegratedAudioManager 経由テスト
          ElevatedButton(
            onPressed: () async {
              try {
                final manager = IntegratedAudioManager();
                await manager.playUserActionSound(UserActionType.uiButtonPress);
                debugPrint('🔊 IntegratedAudioManager: uiButtonPress 再生');
              } catch (e) {
                debugPrint('❌ IntegratedAudioManager テスト失敗: $e');
              }
            },
            child: const Text('統合管理経由テスト'),
          ),

          const SizedBox(height: 8),

          // システム状態確認
          ElevatedButton(
            onPressed: () {
              final system = OptimizedAudioSystem();
              final status = system.getSystemStatus();
              debugPrint('🔍 音響システム状態: $status');
            },
            child: const Text('システム状態確認'),
          ),

          const SizedBox(height: 8),

          // 音響ファイル存在確認
          ElevatedButton(
            onPressed: () async {
              try {
                // FlameAudio直接テスト（assets/audioディレクトリから）
                await FlameAudio.play('menu.mp3', volume: 1.0);
                debugPrint('🔊 FlameAudio直接再生テスト実行: menu.mp3');
              } catch (e) {
                debugPrint('❌ FlameAudio直接テスト失敗: $e');
              }
            },
            child: const Text('FlameAudio直接テスト'),
          ),

          // BGMテスト
          ElevatedButton(
            onPressed: () async {
              try {
                // BGM再生テスト
                await FlameAudio.bgm.play('menu.mp3', volume: 0.5);
                debugPrint('🎵 BGMテスト開始: menu.mp3');
              } catch (e) {
                debugPrint('❌ BGMテスト失敗: $e');
              }
            },
            child: const Text('BGM再生テスト'),
          ),

          // BGM停止
          ElevatedButton(
            onPressed: () async {
              try {
                await FlameAudio.bgm.stop();
                debugPrint('🔇 BGM停止');
              } catch (e) {
                debugPrint('❌ BGM停止失敗: $e');
              }
            },
            child: const Text('BGM停止'),
          ),
        ],
      ),
    );
  }
}

/// デバッグパネルを表示するFloatingActionButton
class AudioDebugButton extends StatefulWidget {
  const AudioDebugButton({super.key});

  @override
  State<AudioDebugButton> createState() => _AudioDebugButtonState();
}

class _AudioDebugButtonState extends State<AudioDebugButton> {
  bool _showPanel = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showPanel) ...[
          const AudioDebugPanel(),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: () {
            setState(() {
              _showPanel = !_showPanel;
            });
          },
          backgroundColor: _showPanel ? Colors.red : Colors.blue,
          child: Icon(_showPanel ? Icons.close : Icons.volume_up),
        ),
      ],
    );
  }
}
