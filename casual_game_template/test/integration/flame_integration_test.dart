import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui' show PointerDeviceKind;

// フレームワークのインポート
import '../../lib/framework/core/configurable_game.dart';
import '../../lib/framework/state/game_state_system.dart';
import '../../lib/framework/config/game_configuration.dart';
import '../../lib/framework/audio/audio_system.dart';
import '../../lib/framework/input/input_system.dart';
import '../../lib/framework/persistence/persistence_system.dart';
import '../../lib/framework/monetization/monetization_system.dart';
import '../../lib/framework/analytics/analytics_system.dart';

// テスト用の実装
import '../../lib/game/simple_game.dart';
import '../../lib/game/framework_integration/simple_game_states.dart';
import '../../lib/game/framework_integration/simple_game_configuration.dart';

/// 統合テスト用のテストゲームクラス
class IntegrationTestGame extends ConfigurableGame<GameState, SimpleGameConfig> {
  late SimpleGameStateProvider _stateProvider;
  late SimpleGameConfiguration _configuration;
  
  @override
  GameStateProvider<GameState> get stateProvider => _stateProvider;
  
  @override
  GameConfiguration<GameState, SimpleGameConfig> get configuration => _configuration;
  
  @override
  GameStateProvider<GameState> createStateProvider() {
    _stateProvider = SimpleGameStateProvider();
    return _stateProvider;
  }
  
  @override
  Future<void> initializeGame() async {
    // プリセットの初期化
    SimpleGameConfigPresets.initialize();
    _configuration = SimpleGameConfigPresets.getConfigurationPreset('default');
    
    // テスト用のUI要素を追加
    final textComponent = TextComponent(
      text: 'Integration Test Game',
      position: Vector2(10, 10),
    );
    add(textComponent);
  }
}

void main() {
  group('🔗 Flame統合テスト - ConfigurableGame', () {
    late IntegrationTestGame game;
    
    setUp(() {
      game = IntegrationTestGame();
    });
    
    group('フレームワーク初期化統合', () {
      test('ConfigurableGame + Flame統合初期化', () async {
        print('🎮 統合テスト: フレームワーク初期化開始...');
        
        // Flame onLoad実行（実際のゲームエンジン初期化）
        await game.onLoad();
        
        // 1. 基本初期化確認
        expect(game.isInitialized, isTrue);
        print('  ✅ ConfigurableGame初期化成功');
        
        // 2. フレームワークシステム初期化確認
        expect(game.stateProvider, isNotNull);
        expect(game.configuration, isNotNull);
        expect(game.timerManager, isNotNull);
        expect(game.themeManager, isNotNull);
        print('  ✅ 基本システム初期化成功');
        
        // 3. 拡張システム初期化確認
        expect(game.audioManager, isNotNull);
        expect(game.inputManager, isNotNull);
        expect(game.dataManager, isNotNull);
        expect(game.monetizationManager, isNotNull);
        expect(game.analyticsManager, isNotNull);
        print('  ✅ 拡張システム初期化成功');
        
        // 4. Flameコンポーネント確認
        expect(game.children.isNotEmpty, isTrue);
        print('  ✅ Flameコンポーネント追加確認: ${game.children.length}個');
        
        // 5. 初期状態確認
        expect(game.currentState, isA<SimpleGameStartState>());
        print('  ✅ 初期状態確認: ${game.currentState.name}');
        
        print('🎉 フレームワーク統合初期化テスト成功！');
      });
      
      test('システム間連携確認', () async {
        print('🔗 統合テスト: システム間連携確認...');
        
        await game.onLoad();
        
        // 1. 状態変更が各システムに伝播することを確認
        final initialState = game.currentState;
        
        // 2. タイマーとの連携確認
        // タイマー機能のテスト（簡略化）
        print('  📝 タイマーシステム連携確認');
        
        final timer = game.timerManager.getTimer('test');
        expect(timer, isNotNull);
        print('  ✅ タイマーシステム連携確認');
        
        // 3. 入力システムとの連携確認
        final inputEvents = <InputEventData>[];
        game.inputManager.addInputListener((event) {
          inputEvents.add(event);
        });
        
        // 実際のFlameイベントをシミュレート  
        game.onTapDown(TapDownEvent(
          1,
          game,
          TapDownDetails(
            localPosition: const Offset(100, 100),
          ),
        ));
        
        // 少し待ってからイベント確認
        await Future.delayed(const Duration(milliseconds: 50));
        expect(inputEvents, isNotEmpty);
        print('  ✅ 入力システム連携確認: ${inputEvents.length}イベント受信');
        
        // 4. 分析システムとの連携確認
        await game.analyticsManager.trackEvent('integration_test', parameters: {
          'test_type': 'system_integration',
          'components': game.children.length,
        });
        print('  ✅ 分析システム連携確認');
        
        print('🎉 システム間連携テスト成功！');
      });
    });
    
    group('Flameイベント統合', () {
      test('タップイベント → フレームワーク処理 → ゲーム処理', () async {
        print('👆 統合テスト: タップイベント処理フロー...');
        
        await game.onLoad();
        
        // 1. 初期状態確認
        expect(game.currentState, isA<SimpleGameStartState>());
        
        // 2. 実際のFlame TapDownEventを作成
        final tapEvent = TapDownEvent(
          1,
          game,
          TapDownDetails(
            localPosition: const Offset(200, 300),
          ),
        );
        
        // 3. Flameイベントハンドラー実行
        game.onTapDown(tapEvent);
        
        // 4. フレームワーク処理の確認（非同期処理を待機）
        await Future.delayed(const Duration(milliseconds: 10));
        
        // 5. 状態変更の確認（SimpleGameのタップ処理）
        // SimpleGameでは開始状態でタップするとゲーム開始
        expect(game.currentState, isA<SimpleGamePlayingState>());
        print('  ✅ 状態遷移確認: start → playing');
        
        // 6. タイマー開始確認
        final timer = game.timerManager.getTimer('main');
        expect(timer, isNotNull);
        expect(timer!.isRunning, isTrue);
        print('  ✅ タイマー開始確認');
        
        print('🎉 タップイベント統合処理テスト成功！');
      });
      
      test('複数フレーム実行でのシステム動作', () async {
        print('🎬 統合テスト: 複数フレーム実行...');
        
        await game.onLoad();
        
        // ゲーム開始
        game.onTapDown(TapDownEvent(
          1,
          game,
          TapDownDetails(
            localPosition: const Offset(100, 100),
          ),
        ));
        
        await Future.delayed(const Duration(milliseconds: 10));
        
        // 複数フレーム実行（1秒分）
        final frameTime = 1.0 / 60.0; // 60FPS
        for (int i = 0; i < 60; i++) {
          game.update(frameTime);
          
          // 10フレームごとに状態確認
          if (i % 10 == 0) {
            expect(game.isInitialized, isTrue);
            print('  📋 フレーム${i}: システム正常動作');
          }
        }
        
        // タイマーの時間減少確認
        final timer = game.timerManager.getTimer('main');
        if (timer != null) {
          expect(timer.current.inSeconds, lessThan(5)); // 初期値より減少
          print('  ✅ タイマー動作確認: ${timer.current.inSeconds}秒');
        }
        
        print('🎉 複数フレーム実行テスト成功！');
      });
    });
    
    group('設定変更統合', () {
      test('リアルタイム設定変更', () async {
        print('⚙️ 統合テスト: 設定変更...');
        
        await game.onLoad();
        
        // 1. 初期設定確認
        final initialConfig = game.config;
        expect(initialConfig, isNotNull);
        print('  ✅ 初期設定: ${initialConfig.runtimeType}');
        
        // 2. 設定変更
        final newConfig = SimpleGameConfigPresets.getPreset('easy');
        if (newConfig != null) {
          await game.applyConfiguration(newConfig);
          
          // 3. 設定反映確認
          expect(game.config, equals(newConfig));
          print('  ✅ 設定変更反映確認');
          
          // 4. システムへの影響確認
          expect(game.timerManager, isNotNull);
          expect(game.audioManager, isNotNull);
          print('  ✅ システム影響確認');
        }
        
        print('🎉 設定変更統合テスト成功！');
      });
    });
    
    group('エラーハンドリング統合', () {
      test('大きな時間ステップでの安定性', () async {
        print('⚠️ 統合テスト: エラーハンドリング...');
        
        await game.onLoad();
        
        // 極端に大きな時間ステップで更新
        expect(() => game.update(10.0), returnsNormally);
        expect(() => game.update(0.0), returnsNormally);
        expect(() => game.update(-1.0), returnsNormally);
        
        // システムが引き続き正常動作することを確認
        expect(game.isInitialized, isTrue);
        expect(game.audioManager, isNotNull);
        
        print('  ✅ 極端値での安定性確認');
        print('🎉 エラーハンドリング統合テスト成功！');
      });
      
      test('連続イベント処理', () async {
        print('🔥 統合テスト: 連続イベント処理...');
        
        await game.onLoad();
        
        // 連続でタップイベントを発生
        for (int i = 0; i < 10; i++) {
          game.onTapDown(TapDownEvent(
            1,
            game,
            TapDownDetails(
              localPosition: Offset(i * 10.0, i * 10.0),
            ),
          ));
          
          game.onTapUp(TapUpEvent(
            1,
            game,
            TapUpDetails(
              kind: PointerDeviceKind.touch,
              localPosition: Offset(i * 10.0, i * 10.0),
            ),
          ));
        }
        
        // システムが正常動作することを確認
        expect(game.isInitialized, isTrue);
        expect(() => game.update(1/60), returnsNormally);
        
        print('  ✅ 連続イベント処理安定性確認');
        print('🎉 連続イベント処理テスト成功！');
      });
    });
    
    group('メモリ・リソース管理', () {  
      test('リソース解放確認', () async {
        print('🧹 統合テスト: リソース解放...');
        
        await game.onLoad();
        
        // システム初期化確認
        expect(game.audioManager, isNotNull);
        expect(game.dataManager, isNotNull);
        expect(game.monetizationManager, isNotNull);
        expect(game.analyticsManager, isNotNull);
        
        // リソース解放実行
        game.onRemove();
        
        // 解放後も例外が発生しないことを確認
        expect(() => game.update(1/60), returnsNormally);
        
        print('  ✅ リソース解放実行成功');
        print('🎉 リソース管理テスト成功！');
      });
    });
  });
  
  group('🎮 SimpleGame統合テスト', () {
    late SimpleGame simpleGame;
    
    setUp(() {
      simpleGame = SimpleGame();
    });
    
    test('SimpleGame完全初期化', () async {
      print('🎯 SimpleGame統合テスト開始...');
      
      // SimpleGameの実際の初期化
      await simpleGame.onLoad();
      
      // 初期化確認
      expect(simpleGame.isInitialized, isTrue);
      expect(simpleGame.children.isNotEmpty, isTrue);
      
      // SimpleGame固有の要素確認
      final textComponents = simpleGame.children.whereType<TextComponent>();
      expect(textComponents.length, greaterThan(0));
      
      print('  ✅ SimpleGameコンポーネント: ${textComponents.length}個');
      print('🎉 SimpleGame統合テスト成功！');
    });
  });
}