import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../../framework/transitions/fade_page_route.dart';
import '../../escape_room.dart';
import 'game_selection_progress_manager.dart';

/// Manages navigation operations for the game selection screen
class GameSelectionNavigationManager {
  final GameSelectionProgressManager progressManager;

  GameSelectionNavigationManager({required this.progressManager});

  Future<void> startNewGame(BuildContext context) async {
    // FlameAudio公式：画面遷移前にBGMを停止（単純なstop()使用）
    debugPrint('🎵 GameSelectionNavigationManager: Stopping start screen BGM before game start');
    await FlameAudio.bgm.stop();
    
    await progressManager.startNewGame();

    if (context.mounted) {
      Navigator.of(context).pushFade(const EscapeRoom()).then((_) {
        progressManager.refreshProgressState();
      });
    }
  }

  Future<void> loadSavedGame(BuildContext context) async {
    try {
      final progress = await progressManager.loadSavedGame();

      if (progress != null) {
        // FlameAudio公式：BGMを停止してから画面遷移
        await FlameAudio.bgm.stop();
        
        if (context.mounted) {
          Navigator.of(context).pushFade(const EscapeRoom()).then((_) {
            progressManager.refreshProgressState();
          });
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('セーブデータの読み込みに失敗しました')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
      }
    }
  }
}
