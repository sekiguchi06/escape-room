import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_audio/flame_audio.dart';

import '../game/screens/components/background_decoration.dart';
import '../game/screens/components/game_selection_header.dart';
import '../game/screens/components/bottom_navigation_bar.dart';
import '../game/screens/managers/game_selection_progress_manager.dart';
import '../game/screens/managers/game_selection_navigation_manager.dart';
import 'components/main_action_button_list.dart';

class GameSelectionScreen extends ConsumerStatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  ConsumerState<GameSelectionScreen> createState() =>
      _GameSelectionScreenState();
}

class _GameSelectionScreenState extends ConsumerState<GameSelectionScreen>
    with WidgetsBindingObserver {
  late GameSelectionProgressManager _progressManager;
  late GameSelectionNavigationManager _navigationManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _progressManager = GameSelectionProgressManager(
      onProgressChanged: () {
        if (mounted) setState(() {});
      },
    );
    _navigationManager = GameSelectionNavigationManager(
      progressManager: _progressManager,
    );
    _progressManager.initialize();
    
    // BGM開始（ループ再生）
    _startBackgroundMusic();
  }
  
  /// 公式推奨：スタート画面BGM開始
  void _startBackgroundMusic() async {
    try {
      // 公式推奨：FlameAudio.bgm.play()でBGM再生
      await FlameAudio.bgm.play('moonlight.mp3', volume: 0.5);
      debugPrint('🎵 スタート画面BGM開始: moonlight.mp3 (音量: 0.5)');
    } catch (e) {
      debugPrint('❌ BGM再生エラー: $e');
    }
  }
  
  /// BGMを停止（公式推奨：stop()のみ使用）
  void _stopBackgroundMusic() async {
    try {
      await FlameAudio.bgm.stop();
      debugPrint('🔇 スタート画面BGM停止');
    } catch (e) {
      debugPrint('❌ BGM停止エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundDecoration(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const GameSelectionHeader(),

                      MainActionButtonList(
                        progressManager: _progressManager,
                        navigationManager: _navigationManager,
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const GameBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopBackgroundMusic();
    WidgetsBinding.instance.removeObserver(this);
    _progressManager.dispose();
    super.dispose();
  }
}