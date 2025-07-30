import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:casual_game_template/game/config/game_config.dart';
import 'package:casual_game_template/game/providers/game_state_provider.dart';

void main() {
  group('GameConfig テスト', () {
    test('デフォルト設定の確認', () {
      const config = GameConfig.defaultConfig;
      
      expect(config.gameDuration, const Duration(seconds: 5));
      expect(config.stateTexts[SimpleGameState.start], 'TAP TO START');
      expect(config.stateColors[SimpleGameState.start], Colors.white);
      expect(config.isValid(), true);
    });

    test('Easy設定の確認', () {
      const config = GameConfig.easyConfig;
      
      expect(config.gameDuration, const Duration(seconds: 10));
      expect(config.stateTexts[SimpleGameState.start], '🎮 EASY MODE\nTAP TO START');
      expect(config.stateColors[SimpleGameState.start], Colors.green);
      expect(config.isValid(), true);
    });

    test('Hard設定の確認', () {
      const config = GameConfig.hardConfig;
      
      expect(config.gameDuration, const Duration(seconds: 3));
      expect(config.stateTexts[SimpleGameState.start], '🔥 HARD MODE\nTAP TO START');
      expect(config.stateColors[SimpleGameState.start], Colors.red);
      expect(config.isValid(), true);
    });

    test('状態テキスト取得（プレースホルダー対応）', () {
      const config = GameConfig.defaultConfig;
      
      // プレースホルダーなし
      expect(config.getStateText(SimpleGameState.start), 'TAP TO START');
      expect(config.getStateText(SimpleGameState.gameOver), 'GAME OVER\nTAP TO RESTART');
      
      // プレースホルダーあり
      expect(config.getStateText(SimpleGameState.playing, time: 3.7), 'TIME: 3.7');
      expect(config.getStateText(SimpleGameState.playing, time: 1.0), 'TIME: 1.0');
    });

    test('動的タイマー色の取得', () {
      const config = GameConfig.defaultConfig;
      
      // 通常時（80%以上）
      expect(config.getDynamicTimerColor(5.0), Colors.white);
      expect(config.getDynamicTimerColor(4.0), Colors.white);
      
      // 注意時（40-20%）
      expect(config.getDynamicTimerColor(2.0), Colors.orange);
      expect(config.getDynamicTimerColor(1.5), Colors.orange);
      
      // 警告時（20%以下）
      expect(config.getDynamicTimerColor(1.0), Colors.red);
      expect(config.getDynamicTimerColor(0.5), Colors.red);
    });

    test('JSON変換機能', () {
      const originalConfig = GameConfig.defaultConfig;
      final json = originalConfig.toJson();
      final restoredConfig = GameConfig.fromJson(json);
      
      expect(restoredConfig.gameDuration, originalConfig.gameDuration);
      expect(restoredConfig.timerUpdateInterval, originalConfig.timerUpdateInterval);
      expect(restoredConfig.isValid(), true);
    });

    test('copyWith機能', () {
      const originalConfig = GameConfig.defaultConfig;
      final modifiedConfig = originalConfig.copyWith(
        gameDuration: const Duration(seconds: 8),
        stateColors: {
          SimpleGameState.start: Colors.blue,
          SimpleGameState.playing: Colors.green,
          SimpleGameState.gameOver: Colors.purple,
        },
      );
      
      expect(modifiedConfig.gameDuration, const Duration(seconds: 8));
      expect(modifiedConfig.stateColors[SimpleGameState.start], Colors.blue);
      expect(modifiedConfig.stateTexts, originalConfig.stateTexts); // 変更されていない
      expect(modifiedConfig.isValid(), true);
    });

    test('設定の妥当性チェック', () {
      // 正常な設定
      expect(GameConfig.defaultConfig.isValid(), true);
      
      // 異常な設定（0秒以下のゲーム時間）
      final invalidConfig = GameConfig.defaultConfig.copyWith(
        gameDuration: const Duration(seconds: 0),
      );
      expect(invalidConfig.isValid(), false);
    });

    test('ゲーム時間の秒数変換', () {
      expect(GameConfig.defaultConfig.gameDurationInSeconds, 5.0);
      expect(GameConfig.easyConfig.gameDurationInSeconds, 10.0);
      expect(GameConfig.hardConfig.gameDurationInSeconds, 3.0);
    });
  });

  group('GameUIConfig テスト', () {
    test('デフォルト設定', () {
      const config = GameUIConfig.defaultConfig;
      
      expect(config.fontSize, 24.0);
      expect(config.fontWeight, FontWeight.bold);
      expect(config.screenMargin, 20.0);
      expect(config.showDebugInfo, false);
    });

    test('JSON変換', () {
      const original = GameUIConfig.defaultConfig;
      final json = original.toJson();
      final restored = GameUIConfig.fromJson(json);
      
      expect(restored.fontSize, original.fontSize);
      expect(restored.fontWeight, original.fontWeight);
      expect(restored.screenMargin, original.screenMargin);
      expect(restored.showDebugInfo, original.showDebugInfo);
    });
  });

  group('GameDebugConfig テスト', () {
    test('デフォルト設定', () {
      const config = GameDebugConfig.defaultConfig;
      
      expect(config.enableLogs, true);
      expect(config.showPerformanceMetrics, false);
      expect(config.showStateTransitions, true);
    });

    test('JSON変換', () {
      const original = GameDebugConfig.defaultConfig;
      final json = original.toJson();
      final restored = GameDebugConfig.fromJson(json);
      
      expect(restored.enableLogs, original.enableLogs);
      expect(restored.showPerformanceMetrics, original.showPerformanceMetrics);
      expect(restored.showStateTransitions, original.showStateTransitions);
    });
  });

  group('設定駆動化統合テスト', () {
    test('GameStateProviderとの統合', () {
      final provider = GameStateProvider();
      
      // 初期状態確認
      expect(provider.gameConfig.gameDurationInSeconds, 5.0);
      expect(provider.getStateDescription(), 'TAP TO START');
      
      // Easy設定に変更
      provider.updateGameConfig(GameConfig.easyConfig);
      expect(provider.gameConfig.gameDurationInSeconds, 10.0);
      expect(provider.getStateDescription(), '🎮 EASY MODE\nTAP TO START');
      
      // Hard設定に変更
      provider.updateGameConfig(GameConfig.hardConfig);
      expect(provider.gameConfig.gameDurationInSeconds, 3.0);
      expect(provider.getStateDescription(), '🔥 HARD MODE\nTAP TO START');
    });

    test('プレイ中の設定変更', () {
      final provider = GameStateProvider();
      
      // ゲーム開始
      provider.setPlayingState();
      expect(provider.currentState, SimpleGameState.playing);
      
      // Easy設定に変更（プレイ中は時間変更しない）
      final originalTimer = provider.gameTimer;
      provider.updateGameConfig(GameConfig.easyConfig);
      expect(provider.gameTimer, originalTimer); // 時間は変わらない
      expect(provider.gameConfig.gameDurationInSeconds, 10.0); // 設定は変わる
    });

    test('カスタム設定の作成と適用', () {
      final customConfig = GameConfig.defaultConfig.copyWith(
        gameDuration: const Duration(seconds: 7),
        stateTexts: {
          SimpleGameState.start: 'CUSTOM GAME\nTAP TO START',
          SimpleGameState.playing: 'CUSTOM TIME: {time}',
          SimpleGameState.gameOver: 'CUSTOM OVER\nTAP TO RESTART',
        },
        stateColors: {
          SimpleGameState.start: Colors.purple,
          SimpleGameState.playing: Colors.cyan,
          SimpleGameState.gameOver: Colors.lime,
        },
      );

      final provider = GameStateProvider();
      provider.updateGameConfig(customConfig);
      
      expect(provider.gameConfig.gameDurationInSeconds, 7.0);
      expect(provider.getStateDescription(), 'CUSTOM GAME\nTAP TO START');
      expect(provider.getStateColor(), Colors.purple);
      
      // プレイ中の表示
      provider.setPlayingState();
      provider.updateTimer(4.2);
      expect(provider.getStateDescription(), 'CUSTOM TIME: 4.2');
      expect(provider.getStateColor(), Colors.cyan);
    });
  });
}