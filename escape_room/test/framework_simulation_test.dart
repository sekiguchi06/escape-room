import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:escape_room/game/framework_integration/simple_game_states.dart';
import 'package:escape_room/game/framework_integration/simple_game_configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('フレームワークシミュレーションテスト', () {
    test('ゲーム完全サイクル シミュレーション', () {
      debugPrint('🎮 ゲーム完全サイクル シミュレーションを開始...');
      
      // セットアップ
      final stateProvider = SimpleGameStateProvider();
      debugPrint('✅ StateProvider初期化完了');
      
      // Step 1: 初期状態確認
      expect(stateProvider.isInState<SimpleGameStartState>(), isTrue);
      debugPrint('📍 初期状態: ${stateProvider.currentState.name}');
      
      // Step 2: ゲーム開始
      debugPrint('🚀 ゲーム開始...');
      final startSuccess = stateProvider.startGame(5.0);
      expect(startSuccess, isTrue);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      final playingState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
      expect(playingState.timeRemaining, equals(5.0));
      expect(playingState.sessionNumber, equals(1));
      debugPrint('📍 プレイ中状態: 残り時間 ${playingState.timeRemaining}秒, セッション ${playingState.sessionNumber}');
      
      // Step 3: ゲーム進行シミュレーション
      debugPrint('⏱️ ゲーム進行シミュレーション...');
      final timeSteps = [4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5];
      
      for (final time in timeSteps) {
        stateProvider.updateTimer(time);
        final currentState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
        expect(currentState.timeRemaining, equals(time));
        debugPrint('  ⏰ 残り時間: $time秒');
      }
      
      // Step 4: ゲームオーバー
      debugPrint('💀 ゲームオーバー...');
      stateProvider.updateTimer(0.0);
      expect(stateProvider.isInState<SimpleGameOverState>(), isTrue);
      
      final gameOverState = stateProvider.getStateAs<SimpleGameOverState>()!;
      expect(gameOverState.sessionNumber, equals(1));
      debugPrint('📍 ゲームオーバー状態: セッション ${gameOverState.sessionNumber} 完了');
      
      // Step 5: リスタート
      debugPrint('🔄 ゲームリスタート...');
      final restartSuccess = stateProvider.restart(5.0);
      expect(restartSuccess, isTrue);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      final newPlayingState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
      expect(newPlayingState.sessionNumber, equals(2));
      debugPrint('📍 リスタート完了: セッション ${newPlayingState.sessionNumber}');
      
      // Step 6: セッション統計確認
      final stats = stateProvider.getStatistics();
      expect(stats.sessionCount, greaterThanOrEqualTo(2));
      expect(stats.totalStateChanges, greaterThan(0));
      debugPrint('📊 統計情報:');
      debugPrint('  - セッション数: ${stats.sessionCount}');
      debugPrint('  - 総状態変更数: ${stats.totalStateChanges}');
      debugPrint('  - セッション時間: ${stats.sessionDuration.inMilliseconds}ms');
      debugPrint('  - 最多訪問状態: ${stats.mostVisitedState}');
      debugPrint('  - セッション平均遷移数: ${stats.averageStateTransitionsPerSession.toStringAsFixed(2)}');
      
      debugPrint('🎉 ゲーム完全サイクル シミュレーション完了！');
    });
    
    test('複数プリセット設定テスト', () {
      debugPrint('🎨 複数プリセット設定テストを開始...');
      
      SimpleGameConfigPresets.initialize();
      final presets = ['default', 'easy', 'hard'];
      
      for (final presetName in presets) {
        debugPrint('📦 プリセット「$presetName」をテスト中...');
        
        final config = SimpleGameConfigPresets.getPreset(presetName)!;
        final configuration = SimpleGameConfigPresets.getConfigurationPreset(presetName);
        
        expect(configuration.isValid(), isTrue);
        
        debugPrint('  - ゲーム時間: ${config.gameDuration.inSeconds}秒');
        debugPrint('  - 開始テキスト: "${config.getStateText('start')}"');
        debugPrint('  - 開始色: ${config.getStateColor('start')}');
        debugPrint('  - フォントサイズ: ${config.getFontSize('start')}');
        
        // バリデーション実行
        final validator = SimpleGameConfigValidator();
        final validationResult = validator.validate(config);
        expect(validationResult.isValid, isTrue);
        
        if (validationResult.warnings.isNotEmpty) {
          debugPrint('  ⚠️ 警告: ${validationResult.warnings.join(', ')}');
        } else {
          debugPrint('  ✅ バリデーション成功');
        }
      }
      
      debugPrint('🎉 複数プリセット設定テスト完了！');
    });
    
    test('設定駆動ゲーム動作テスト', () {
      debugPrint('⚙️ 設定駆動ゲーム動作テストを開始...');
      
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
      
      debugPrint('📝 カスタム設定:');
      debugPrint('  - 時間: ${customConfig.gameDuration.inSeconds}秒');
      debugPrint('  - デバッグモード: ${customConfig.enableDebugMode}');
      debugPrint('  - アナリティクス: ${customConfig.enableAnalytics}');
      
      // 設定バリデーション
      final validator = SimpleGameConfigValidator();
      final validationResult = validator.validate(customConfig);
      expect(validationResult.isValid, isTrue);
      
      if (validationResult.warnings.isNotEmpty) {
        debugPrint('  ⚠️ 警告: ${validationResult.warnings.join(', ')}');
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
          
          // 変数の使用確認テスト
          expect(state.timeRemaining, equals(time));
          expect(dynamicText, isNotNull);
          expect(dynamicColor, isNotNull);
          
          debugPrint('  ⏰ $time秒: "$dynamicText" (色: $dynamicColor)');
        }
      }
      
      expect(stateProvider.isInState<SimpleGameOverState>(), isTrue);
      debugPrint('  🏁 カスタム設定ゲーム完了');
      
      debugPrint('🎉 設定駆動ゲーム動作テスト完了！');
    });
    
    test('A/Bテスト設定シミュレーション', () {
      debugPrint('🧪 A/Bテスト設定シミュレーションを開始...');
      
      final configuration = SimpleGameConfiguration.defaultConfig;
      
      // バリアントA: イージーモード
      final variantA = configuration.getConfigForVariant('easy');
      expect(variantA.gameDuration.inSeconds, equals(15));
      debugPrint('📊 バリアントA (easy): ${variantA.gameDuration.inSeconds}秒');
      
      // バリアントB: ハードモード
      final variantB = configuration.getConfigForVariant('hard');
      expect(variantB.gameDuration.inSeconds, equals(5));
      debugPrint('📊 バリアントB (hard): ${variantB.gameDuration.inSeconds}秒');
      
      // 各バリアントでゲームシミュレーション実行
      for (final variant in [
        {'name': 'easy', 'config': variantA},
        {'name': 'hard', 'config': variantB},
      ]) {
        debugPrint('🎯 バリアント「${variant['name']}」をテスト中...');
        
        final config = variant['config'] as SimpleGameConfig;
        final stateProvider = SimpleGameStateProvider();
        
        // ゲーム実行
        stateProvider.startGame(config.gameDuration.inMilliseconds / 1000.0);
        
        // 中間点まで進行
        final midTime = config.gameDuration.inMilliseconds / 2000.0;
        stateProvider.updateTimer(midTime);
        
        final midState = stateProvider.getStateAs<SimpleGamePlayingState>()!;
        debugPrint('  ⏱️ 中間点: ${midState.timeRemaining}秒');
        
        // ゲーム完了
        stateProvider.updateTimer(0.0);
        expect(stateProvider.isInState<SimpleGameOverState>(), isTrue);
        debugPrint('  ✅ バリアント完了');
      }
      
      debugPrint('🎉 A/Bテスト設定シミュレーション完了！');
    });
    
    test('エラーハンドリング・エッジケーステスト', () {
      debugPrint('🚨 エラーハンドリング・エッジケーステスト開始...');
      
      final stateProvider = SimpleGameStateProvider();
      
      // エッジケース1: 負の時間でゲーム開始を試行
      debugPrint('🧪 負の時間でゲーム開始テスト...');
      final negativeStartResult = stateProvider.startGame(-1.0);
      expect(negativeStartResult, isTrue); // 内部で正の値に調整される想定
      
      // エッジケース2: 異常に大きな時間値
      debugPrint('🧪 異常に大きな時間値テスト...');
      stateProvider.resetToState(SimpleGameStateFactory.createStartState());
      stateProvider.startGame(999999.0);
      expect(stateProvider.isInState<SimpleGamePlayingState>(), isTrue);
      
      // エッジケース3: 不正な状態遷移の試行
      debugPrint('🧪 不正な状態遷移テスト...');
      stateProvider.resetToState(SimpleGameStateFactory.createStartState());
      final invalidRestartResult = stateProvider.restart(5.0); // start状態からrestartは無効
      expect(invalidRestartResult, isFalse);
      expect(stateProvider.isInState<SimpleGameStartState>(), isTrue);
      
      // エッジケース4: 設定バリデーション失敗ケース
      debugPrint('🧪 設定バリデーション失敗ケーステスト...');
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
      debugPrint('  ❌ 想定通りバリデーション失敗: ${validationResult.errors.length}個のエラー');
      debugPrint('  エラー内容: ${validationResult.errors.join(', ')}');
      
      debugPrint('🎉 エラーハンドリング・エッジケーステスト完了！');
    });
  });
}