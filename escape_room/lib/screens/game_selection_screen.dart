import 'dart:async';
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
    
    // BGM開始（画面表示後に確実実行）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _forceResetBGM();
    });
    
    // 定期的にBGMをチェックして修正
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play('moonlight.mp3', volume: 0.5);
      }
    });
  }
  
  /// FlameAudio公式実装：BGMリセット
  void _forceResetBGM() async {
    try {
      // 公式実装：play()のみ（自動で前のBGMが停止される）
      await FlameAudio.bgm.play('moonlight.mp3', volume: 0.5);
      debugPrint('✅ スタート画面BGM設定完了（公式実装）');
    } catch (e) {
      debugPrint('❌ BGM設定エラー: $e');
    }
  }

  /// 公式推奨：スタート画面BGM開始
  void _startBackgroundMusic() async {
    try {
      // 公式実装：直接BGMを再生（自動で前のBGMが停止）
      await FlameAudio.bgm.play('moonlight.mp3', volume: 0.5);
      debugPrint('🎵 スタート画面BGM開始: moonlight.mp3');
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