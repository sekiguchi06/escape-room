import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_states.dart';
import 'package:casual_game_template/game/framework_integration/simple_game_configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('フレームワークシミュレーションテスト', () {
    test('ゲーム完全サイクル シミュレーション', () {
      print('🎮 ゲーム完全サイクル シミュレーションを開始...');
      
      // セットアップ
      final stateProvider = SimpleGameStateProvider();
      print('✅ StateProvider初期化完了');
      
      // Step 1: 初期状態確認
      expect(stateProvider.isInState<SimpleGameStartState>(), isTrue);
      print('📍 初期状態: ${stateProvider.currentState.name}');
      
      // Step 2: ゲーム開始
      print('🚀 ゲーム開始...');
      final startSuccess = stateProvider.startGame(5.0);
      expect(startSuccess, isTrue);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      final playingState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
      expect(playingState.timeRemaining, equals(5.0));
      expect(playingState.sessionNumber, equals(1));
      print('📍 プレイ中状態: 残り時間 ${playingState.timeRemaining}秒, セッション ${playingState.sessionNumber}');
      
      // Step 3: ゲーム進行シミュレーション
      print('⏱️ ゲーム進行シミュレーション...');
      final timeSteps = [4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5];
      
      for (final time in timeSteps) {
        stateProvider.updateTimer(time);
        final currentState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
        expect(currentState.timeRemaining, equals(time));
        print('  ⏰ 残り時間: ${time}秒');
      }
      
      // Step 4: ゲームオーバー
      print('💀 ゲームオーバー...');
      stateProvider.updateTimer(0.0);
      expect(stateProvider.isInState<SimpleGameOverState>(), isTrue);
      
      final gameOverState = stateProvider.getStateAs<SimpleGameOverState>()!;
      expect(gameOverState.sessionNumber, equals(1));
      print('📍 ゲームオーバー状態: セッション ${gameOverState.sessionNumber} 完了');
      
      // Step 5: リスタート
      print('🔄 ゲームリスタート...');
      final restartSuccess = stateProvider.restart(5.0);
      expect(restartSuccess, isTrue);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      final newPlayingState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
      expect(newPlayingState.sessionNumber, equals(2));
      print('📍 リスタート完了: セッション ${newPlayingState.sessionNumber}');
      
      // Step 6: セッション統計確認
      final stats = stateProvider.getStatistics();
      expect(stats.sessionCount, greaterThanOrEqualTo(2));
      expect(stats.totalStateChanges, greaterThan(0));
      print('📊 統計情報:');
      print('  - セッション数: ${stats.sessionCount}');
      print('  - 総状態変更数: ${stats.totalStateChanges}');
      print('  - セッション時間: ${stats.sessionDuration.inMilliseconds}ms');
      print('  - 最多訪問状態: ${stats.mostVisitedState}');
      print('  - セッション平均遷移数: ${stats.averageStateTransitionsPerSession.toStringAsFixed(2)}');
      
      print('🎉 ゲーム完全サイクル シミュレーション完了！');
    });
    
    test('複数プリセット設定テスト', () {
      print('🎨 複数プリセット設定テストを開始...');
      
      SimpleGameConfigPresets.initialize();
      final presets = ['default', 'easy', 'hard'];
      
      for (final presetName in presets) {
        print('📦 プリセット「$presetName」をテスト中...');
        
        final config = SimpleGameConfigPresets.getPreset(presetName)!;
        final configuration = SimpleGameConfigPresets.getConfigurationPreset(presetName);
        
        expect(configuration.isValid(), isTrue);
        
        print('  - ゲーム時間: ${config.gameDuration.inSeconds}秒');
        print('  - 開始テキスト: "${config.getStateText('start')}"');
        print('  - 開始色: ${config.getStateColor('start')}');
        print('  - フォントサイズ: ${config.getFontSize('start')}');
        
        // バリデーション実行
        final validator = SimpleGameConfigValidator();
        final validationResult = validator.validate(config);
        expect(validationResult.isValid, isTrue);
        
        if (validationResult.warnings.isNotEmpty) {
          print('  ⚠️ 警告: ${validationResult.warnings.join(', ')}');
        } else {
          print('  ✅ バリデーション成功');
        }
      }
      
      print('🎉 複数プリセット設定テスト完了！');
    });
    
    test('設定駆動ゲーム動作テスト', () {
      print('⚙️ 設定駆動ゲーム動作テストを開始...');
      
      // カスタム設定作成
      const customConfig = SimpleGameConfig(
        gameDuration: Duration(seconds: 3),
        stateTexts: {
          'start': '⚡ 超高速モード\nタップで開始',
          'playing': '🔥 残り {time}秒！',
          'gameOver': '💥 終了\nもう一度？',
        },
        stateColors: {
          'start': Colors.yellow,
          'playing': Colors.red,
          'gameOver': Colors.purple,
        },
        fontSizes: {
          'start': 18.0,
          'playing': 20.0,
          'gameOver': 16.0,
        },
        fontWeights: {
          'start': FontWeight.w800,
          'playing': FontWeight.w900,
          'gameOver': FontWeight.w600,
        },
        enableDebugMode: true,
        enableAnalytics: true,
      );
      
      print('📝 カスタム設定:');
      print('  - 時間: ${customConfig.gameDuration.inSeconds}秒');
      print('  - デバッグモード: ${customConfig.enableDebugMode}');
      print('  - アナリティクス: ${customConfig.enableAnalytics}');
      
      // 設定バリデーション
      final validator = SimpleGameConfigValidator();
      final validationResult = validator.validate(customConfig);
      expect(validationResult.isValid, isTrue);
      
      if (validationResult.warnings.isNotEmpty) {
        print('  ⚠️ 警告: ${validationResult.warnings.join(', ')}');
      }
      
      // ゲーム実行シミュレーション
      final stateProvider = SimpleGameStateProvider();
      
      // 短時間ゲームのシミュレーション
      stateProvider.startGame(customConfig.gameDuration.inMilliseconds / 1000.0);
      
      // 高速タイマー更新
      final timeSteps = [2.5, 2.0, 1.5, 1.0, 0.5, 0.0];
      for (final time in timeSteps) {
        stateProvider.updateTimer(time);
        
        if (time > 0) {
          final state = stateProvider.getStateAs<SimpleGamePlayingState>()!;
          final dynamicText = customConfig.getStateText('playing', timeRemaining: time);
          final dynamicColor = customConfig.getDynamicColor('playing', timeRemaining: time);
          
          print('  ⏰ ${time}秒: "$dynamicText" (色: $dynamicColor)');
        }
      }
      
      expect(stateProvider.isInState<SimpleGameOverState>(), isTrue);
      print('  🏁 カスタム設定ゲーム完了');
      
      print('🎉 設定駆動ゲーム動作テスト完了！');
    });
    
    test('A/Bテスト設定シミュレーション', () {
      print('🧪 A/Bテスト設定シミュレーションを開始...');
      
      final configuration = SimpleGameConfiguration.defaultConfig;
      
      // バリアントA: イージーモード
      final variantA = configuration.getConfigForVariant('easy');
      expect(variantA.gameDuration.inSeconds, equals(10));
      print('📊 バリアントA (easy): ${variantA.gameDuration.inSeconds}秒');
      
      // バリアントB: ハードモード
      final variantB = configuration.getConfigForVariant('hard');
      expect(variantB.gameDuration.inSeconds, equals(3));
      print('📊 バリアントB (hard): ${variantB.gameDuration.inSeconds}秒');
      
      // 各バリアントでゲームシミュレーション実行
      for (final variant in [
        {'name': 'easy', 'config': variantA},
        {'name': 'hard', 'config': variantB},
      ]) {
        print('🎯 バリアント「${variant['name']}」をテスト中...');
        
        final config = variant['config'] as SimpleGameConfig;
        final stateProvider = SimpleGameStateProvider();
        
        // ゲーム実行
        stateProvider.startGame(config.gameDuration.inMilliseconds / 1000.0);
        
        // 中間点まで進行
        final midTime = config.gameDuration.inMilliseconds / 2000.0;
        stateProvider.updateTimer(midTime);
        
        final midState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
        print('  ⏱️ 中間点: ${midState.timeRemaining}秒');
        
        // ゲーム完了
        stateProvider.updateTimer(0.0);
        expect(stateProvider.isInState<SimpleGameOverState>(), isTrue);
        print('  ✅ バリアント完了');
      }
      
      print('🎉 A/Bテスト設定シミュレーション完了！');
    });
    
    test('エラーハンドリング・エッジケーステスト', () {
      print('🚨 エラーハンドリング・エッジケーステスト開始...');
      
      final stateProvider = SimpleGameStateProvider();
      
      // エッジケース1: 負の時間でゲーム開始を試行
      print('🧪 負の時間でゲーム開始テスト...');
      final negativeStartResult = stateProvider.startGame(-1.0);
      expect(negativeStartResult, isTrue); // 内部で正の値に調整される想定
      
      // エッジケース2: 異常に大きな時間値
      print('🧪 異常に大きな時間値テスト...');
      stateProvider.resetToState(SimpleGameStateFactory.createStartState());
      stateProvider.startGame(999999.0);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      // エッジケース3: 不正な状態遷移の試行
      print('🧪 不正な状態遷移テスト...');
      stateProvider.resetToState(SimpleGameStateFactory.createStartState());
      final invalidRestartResult = stateProvider.restart(5.0); // start状態からrestartは無効
      expect(invalidRestartResult, isFalse);
      expect(stateProvider.isInState<SimpleGameStartState>(), isTrue);
      
      // エッジケース4: 設定バリデーション失敗ケース
      print('🧪 設定バリデーション失敗ケーステスト...');
      const invalidConfig = SimpleGameConfig(
        gameDuration: Duration.zero, // 無効な時間
        stateTexts: {}, // 空のテキスト
        stateColors: {}, // 空の色
        fontSizes: {},
        fontWeights: {},
      );
      
      final validator = SimpleGameConfigValidator();
      final validationResult = validator.validate(invalidConfig);
      expect(validationResult.isValid, isFalse);
      expect(validationResult.errors.length, greaterThan(0));
      print('  ❌ 想定通りバリデーション失敗: ${validationResult.errors.length}個のエラー');
      print('  エラー内容: ${validationResult.errors.join(', ')}');
      
      print('🎉 エラーハンドリング・エッジケーステスト完了！');
    });
  });
}