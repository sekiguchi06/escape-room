import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_configuration.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_states.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SimpleGameConfig テスト', () {
    test('デフォルト設定の確認', () {
      final config = SimpleGameConfiguration.defaultConfig.config;
      
      expect(config.gameDuration, const Duration(seconds: 5));
      expect(config.stateTexts['start'], 'TAP TO START');
      expect(config.stateTexts['gameOver'], 'GAME OVER\nTAP TO RESTART');
      expect(config.stateColors['start'], isNotNull);
    });

    test('Easy設定の確認', () {
      // プリセットを初期化
      SimpleGameConfigPresets.initialize();
      final config = SimpleGameConfigPresets.getPreset('easy');
      expect(config, isNotNull);
      
      if (config != null) {
        expect(config.gameDuration, const Duration(seconds: 10));
        expect(config.stateTexts['start']?.contains('EASY'), true);
      }
    });

    test('Hard設定の確認', () {
      // プリセットを初期化
      SimpleGameConfigPresets.initialize();
      final config = SimpleGameConfigPresets.getPreset('hard');
      expect(config, isNotNull);
      
      if (config != null) {
        expect(config.gameDuration, const Duration(seconds: 3));
        expect(config.stateTexts['start']?.contains('HARD'), true);
      }
    });

    test('JSON変換テスト', () {
      final config = SimpleGameConfiguration.defaultConfig.config;
      
      // JSON変換
      final json = config.toJson();
      expect(json['gameDurationMs'], config.gameDuration.inMilliseconds);
      expect(json['stateTexts'], config.stateTexts);
      
      // JSON復元
      final restored = SimpleGameConfig.fromJson(json);
      expect(restored.gameDuration, config.gameDuration);
      expect(restored.stateTexts, config.stateTexts);
    });

    test('カスタム設定の作成', () {
      final customConfig = SimpleGameConfig(
        gameDuration: const Duration(seconds: 15),
        stateTexts: const {
          'start': 'CUSTOM GAME\\nTAP TO START',
          'playing': 'CUSTOM TIME: {time}',
          'gameOver': 'CUSTOM OVER\\nTAP TO RESTART',
        },
        stateColors: const {
          'start': Colors.purple,
          'playing': Colors.cyan,
          'gameOver': Colors.lime,
        },
        fontSizes: const {
          'small': 12.0,
          'medium': 16.0,
          'large': 24.0,
        },
        fontWeights: const {
          'normal': FontWeight.normal,
          'bold': FontWeight.bold,
        },
        enableDebugMode: false,
        enableAnalytics: true,
      );
      
      expect(customConfig.gameDuration.inSeconds, 15);
      expect(customConfig.stateTexts['start'], 'CUSTOM GAME\\nTAP TO START');
      expect(customConfig.stateColors['start'], Colors.purple);
      expect(customConfig.fontSizes['medium'], 16.0);
    });

    test('プリセット初期化と取得', () {
      SimpleGameConfigPresets.initialize();
      
      expect(SimpleGameConfigPresets.getPreset('default'), isNotNull);
      expect(SimpleGameConfigPresets.getPreset('easy'), isNotNull);
      expect(SimpleGameConfigPresets.getPreset('hard'), isNotNull);
      expect(SimpleGameConfigPresets.getPreset('nonexistent'), isNull);
    });
  });

  group('SimpleGameStateProvider テスト', () {
    test('初期状態の確認', () {
      final provider = SimpleGameStateProvider();
      
      expect(provider.currentState, isA<SimpleGameStartState>());
      expect(provider.currentState.name, 'start');
    });

    test('状態遷移の確認', () {
      final provider = SimpleGameStateProvider();
      
      // ゲーム開始
      provider.startGame(5.0);
      expect(provider.currentState, isA<SimpleGamePlayingState>());
      expect(provider.currentState.name, 'playing');
      
      // ゲーム終了（状態更新）
      provider.updateTimer(0.0);
      // タイマーが0になるとGameOver状態に遷移する
      expect(provider.currentState, isA<SimpleGameOverState>());
      expect(provider.currentState.name, 'gameOver');
      
      // 再スタート
      provider.restart(3.0);
      expect(provider.currentState, isA<SimpleGamePlayingState>());
      expect(provider.currentState.name, 'playing');
    });

    test('タイマー更新', () {
      final provider = SimpleGameStateProvider();
      provider.startGame(5.0);
      
      // タイマー更新
      provider.updateTimer(3.5);
      final playingState = provider.currentState as SimpleGamePlayingState;
      expect(playingState.timeRemaining, 3.5);
      
      // タイマーが0になるとGameOver状態に遷移
      provider.updateTimer(0.0);
      expect(provider.currentState, isA<SimpleGameOverState>());
      final gameOverState = provider.currentState as SimpleGameOverState;
      expect(gameOverState.finalTime, 0.0);
    });

    test('状態変更通知', () {
      final provider = SimpleGameStateProvider();
      bool notified = false;
      
      provider.addListener(() {
        notified = true;
      });
      
      provider.startGame(5.0);
      expect(notified, true);
    });
  });
}