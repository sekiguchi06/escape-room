import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

import 'package:flame/components.dart';

// フレームワークのインポート
import 'package:escape_room/framework/core/configurable_game.dart';
import 'package:escape_room/framework/state/game_state_system.dart';
import 'package:escape_room/framework/config/game_configuration.dart';
import 'package:escape_room/framework/input/flame_input_system.dart';
import 'package:escape_room/framework/timer/flame_timer_system.dart';
import 'package:escape_room/framework/effects/particle_system.dart';
import 'package:escape_room/framework/animation/animation_system.dart';

// RouterComponent用のインポート

// テスト用の実装
import 'package:escape_room/game/simple_game.dart';
import 'package:escape_room/game/framework_integration/simple_game_states.dart'
    as simple_states;
import 'package:escape_room/game/framework_integration/simple_game_states.dart';
import 'package:escape_room/game/framework_integration/simple_game_configuration.dart';

/// 統合テスト用のテストゲームクラス
class IntegrationTestGame
    extends ConfigurableGameBase<SimpleGameState, SimpleGameConfig> {
  late SimpleGameStateProvider _stateProvider;
  late SimpleGameConfiguration _configuration;

  IntegrationTestGame() : super(debugMode: true);

  GameStateProvider<SimpleGameState> get stateProvider => _stateProvider;

  @override
  GameConfiguration<SimpleGameState, SimpleGameConfig> get configuration =>
      _configuration;

  @override
  GameStateProvider<SimpleGameState> createStateProvider() {
    _stateProvider = SimpleGameStateProvider();
    return _stateProvider;
  }

  @override
  Future<void> initializeGame() async {
    // プリセットの初期化
    SimpleGameConfigPresets.initialize();
    _configuration = SimpleGameConfigPresets.getConfigurationPreset('default');

    // 状態変更リスナーを追加（直接状態変更でもタイマー管理）
    _stateProvider.addListener(_onStateChanged);

    // テスト用のUI要素を追加
    final textComponent = TextComponent(
      text: 'Integration Test Game',
      position: Vector2(10, 10),
    );
    add(textComponent);
  }

  void _onStateChanged() {
    final currentState = _stateProvider.currentState;

    if (currentState is simple_states.SimpleGamePlayingState) {
      // プレイ状態に変更された時、mainタイマーがなければ作成
      if (!timerManager.hasTimer('main')) {
        timerManager.addTimer(
          'main',
          TimerConfiguration(
            duration: config.gameDuration,
            type: TimerType.countdown,
            onComplete: () {
              final gameOverState = simple_states.SimpleGameOverState();
              stateProvider.transitionTo(gameOverState);
            },
          ),
        );
        timerManager.startTimer('main');
      }
    }
  }

  /// 入力イベント処理をオーバーライドしてテスト用の状態遷移を実装
  @override
  void onInputEvent(InputEventData event) {
    super.onInputEvent(event);

    if (event.type == InputEventType.tap) {
      // SimpleGameと同様の状態遷移ロジック
      final currentState = this.currentState;
      if (currentState is simple_states.SimpleGameStartState) {
        // ゲーム開始
        final playingState = simple_states.SimpleGamePlayingState(
          timeRemaining: config.gameDuration.inSeconds.toDouble(),
        );
        stateProvider.transitionTo(playingState);

        // メインタイマーを開始
        timerManager.addTimer(
          'main',
          TimerConfiguration(
            duration: config.gameDuration,
            type: TimerType.countdown,
            onComplete: () {
              final gameOverState = simple_states.SimpleGameOverState();
              stateProvider.transitionTo(gameOverState);
            },
          ),
        );
        timerManager.startTimer('main');
      } else if (currentState is simple_states.SimpleGameOverState) {
        // リスタート
        final startState = simple_states.SimpleGameStartState();
        stateProvider.transitionTo(startState);
      }
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🔗 Flame統合テスト - ConfigurableGame', () {
    late IntegrationTestGame game;

    setUp(() {
      game = IntegrationTestGame();
    });

    group('フレームワーク初期化統合', () {
      test('ConfigurableGame + Flame統合初期化', () async {
        debugPrint('🎮 統合テスト: フレームワーク初期化開始...');

        // Flame onLoad実行（実際のゲームエンジン初期化）
        await game.onLoad();

        // 1. 基本初期化確認
        expect(game.isInitialized, isTrue);
        debugPrint('  ✅ ConfigurableGame初期化成功');

        // 2. フレームワークシステム初期化確認
        expect(game.stateProvider, isNotNull);
        expect(game.configuration, isNotNull);
        expect(game.timerManager, isNotNull);
        expect(game.managers.themeManager, isNotNull);
        debugPrint('  ✅ 基本システム初期化成功');

        // 3. 拡張システム初期化確認
        expect(game.managers.audioManager, isNotNull);
        expect(game.managers.inputManager, isNotNull);
        expect(game.managers.dataManager, isNotNull);
        expect(game.managers.monetizationManager, isNotNull);
        expect(game.managers.analyticsManager, isNotNull);
        debugPrint('  ✅ 拡張システム初期化成功');

        // 4. Flameコンポーネント確認
        expect(game.children.isNotEmpty, isTrue);
        debugPrint('  ✅ Flameコンポーネント追加確認: ${game.children.length}個');

        // 5. 初期状態確認
        expect(game.currentState, isA<simple_states.SimpleGameStartState>());
        debugPrint('  ✅ 初期状態確認: ${game.currentState.name}');

        debugPrint('🎉 フレームワーク統合初期化テスト成功！');
      });

      test('システム間連携確認', () async {
        debugPrint('🔗 統合テスト: システム間連携確認...');

        await game.onLoad();

        // 1. 状態変更が各システムに伝播することを確認
        final initialState = game.currentState;
        expect(initialState, isNotNull);
        debugPrint('  📊 初期状態確認: ${initialState.runtimeType}');

        // 2. タイマーとの連携確認
        // タイマー機能のテスト（デフォルトタイマーを作成）
        debugPrint('  📝 タイマーシステム連携確認');

        // テスト用タイマーを作成
        game.timerManager.addTimer(
          'test',
          TimerConfiguration(
            duration: const Duration(seconds: 1),
            type: TimerType.countdown,
          ),
        );

        final timer = game.timerManager.getTimer('test');
        expect(timer, isNotNull);
        debugPrint('  ✅ タイマーシステム連携確認');

        // 3. 入力システムとの連携確認
        final inputEvents = <InputEventData>[];
        game.managers.inputManager.addInputListener((event) {
          inputEvents.add(event);
        });

        // 実際のFlameイベントをシミュレート
        final tapPosition = Vector2(100, 100);
        game.managers.inputManager.handleTapDown(tapPosition);
        game.managers.inputManager.handleTapUp(tapPosition);

        // 少し待ってからイベント確認
        await Future.delayed(const Duration(milliseconds: 50));
        expect(inputEvents, isNotEmpty);
        debugPrint('  ✅ 入力システム連携確認: ${inputEvents.length}イベント受信');

        // 4. 分析システムとの連携確認
        await game.managers.analyticsManager.trackEvent(
          'integration_test',
          parameters: {
            'test_type': 'system_integration',
            'components': game.children.length,
          },
        );
        debugPrint('  ✅ 分析システム連携確認');

        debugPrint('🎉 システム間連携テスト成功！');
      });
    });

    group('Flameイベント統合', () {
      test('タップイベント → フレームワーク処理 → ゲーム処理', () async {
        debugPrint('👆 統合テスト: タップイベント処理フロー...');

        await game.onLoad();

        // 1. 初期状態確認
        expect(game.currentState, isA<simple_states.SimpleGameStartState>());

        // 2. タップ位置の定義
        final tapPosition = Vector2(200, 300);

        // 3. 入力マネージャー経由でタップ処理（Flameイベント回避）
        game.managers.inputManager.handleTapDown(tapPosition);
        game.managers.inputManager.handleTapUp(tapPosition);

        // 4. フレームワーク処理の確認（非同期処理を待機）
        await Future.delayed(const Duration(milliseconds: 10));

        // 5. 状態変更の確認（SimpleGameのタップ処理）
        // SimpleGameでは開始状態でタップするとゲーム開始
        expect(game.currentState, isA<simple_states.SimpleGamePlayingState>());
        debugPrint('  ✅ 状態遷移確認: start → playing');

        // 6. タイマー開始確認
        final timer = game.timerManager.getTimer('main');
        expect(timer, isNotNull);
        expect(timer!.isRunning, isTrue);
        debugPrint('  ✅ タイマー開始確認');

        debugPrint('🎉 タップイベント統合処理テスト成功！');
      });

      test('複数フレーム実行でのシステム動作', () async {
        debugPrint('🎬 統合テスト: 複数フレーム実行...');

        await game.onLoad();

        // ゲーム開始
        final startPosition = Vector2(100, 100);
        game.managers.inputManager.handleTapDown(startPosition);
        game.managers.inputManager.handleTapUp(startPosition);

        await Future.delayed(const Duration(milliseconds: 10));

        // 複数フレーム実行（1秒分）
        final frameTime = 1.0 / 60.0; // 60FPS
        for (int i = 0; i < 60; i++) {
          game.update(frameTime);

          // 10フレームごとに状態確認
          if (i % 10 == 0) {
            expect(game.isInitialized, isTrue);
            debugPrint('  📋 フレーム$i: システム正常動作');
          }
        }

        // タイマーの時間減少確認
        final timer = game.timerManager.getTimer('main');
        if (timer != null) {
          expect(timer.current.inSeconds, lessThan(10)); // 初期値(10秒)より減少
          debugPrint('  ✅ タイマー動作確認: ${timer.current.inSeconds}秒');
        }

        debugPrint('🎉 複数フレーム実行テスト成功！');
      });
    });

    group('設定変更統合', () {
      test('リアルタイム設定変更', () async {
        debugPrint('⚙️ 統合テスト: 設定変更...');

        await game.onLoad();

        // 1. 初期設定確認
        final initialConfig = game.config;
        expect(initialConfig, isNotNull);
        debugPrint('  ✅ 初期設定: ${initialConfig.runtimeType}');

        // 2. 設定変更
        final newConfig = SimpleGameConfigPresets.getPreset('easy');
        if (newConfig != null) {
          await game.applyConfiguration(newConfig);

          // 3. 設定反映確認
          expect(game.config, equals(newConfig));
          debugPrint('  ✅ 設定変更反映確認');

          // 4. システムへの影響確認
          expect(game.timerManager, isNotNull);
          expect(game.managers.audioManager, isNotNull);
          debugPrint('  ✅ システム影響確認');
        }

        debugPrint('🎉 設定変更統合テスト成功！');
      });
    });

    group('エラーハンドリング統合', () {
      test('大きな時間ステップでの安定性', () async {
        debugPrint('⚠️ 統合テスト: エラーハンドリング...');

        await game.onLoad();

        // 極端に大きな時間ステップで更新
        expect(() => game.update(10.0), returnsNormally);
        expect(() => game.update(0.0), returnsNormally);
        expect(() => game.update(-1.0), returnsNormally);

        // システムが引き続き正常動作することを確認
        expect(game.isInitialized, isTrue);
        expect(game.managers.audioManager, isNotNull);

        debugPrint('  ✅ 極端値での安定性確認');
        debugPrint('🎉 エラーハンドリング統合テスト成功！');
      });

      test('連続イベント処理', () async {
        debugPrint('🔥 統合テスト: 連続イベント処理...');

        await game.onLoad();

        // 連続でタップイベントを発生
        for (int i = 0; i < 10; i++) {
          final position = Vector2(i * 10.0, i * 10.0);
          game.managers.inputManager.handleTapDown(position);
          game.managers.inputManager.handleTapUp(position);
        }

        // システムが正常動作することを確認
        expect(game.isInitialized, isTrue);
        expect(() => game.update(1 / 60), returnsNormally);

        debugPrint('  ✅ 連続イベント処理安定性確認');
        debugPrint('🎉 連続イベント処理テスト成功！');
      });
    });

    group('メモリ・リソース管理', () {
      test('リソース解放確認', () async {
        debugPrint('🧹 統合テスト: リソース解放...');

        await game.onLoad();

        // システム初期化確認
        expect(game.managers.audioManager, isNotNull);
        expect(game.managers.dataManager, isNotNull);
        expect(game.managers.monetizationManager, isNotNull);
        expect(game.managers.analyticsManager, isNotNull);

        // リソース解放実行
        game.onRemove();

        // 解放後も例外が発生しないことを確認
        expect(() => game.update(1 / 60), returnsNormally);

        debugPrint('  ✅ リソース解放実行成功');
        debugPrint('🎉 リソース管理テスト成功！');
      });
    });
  });

  group('🎮 SimpleGame統合テスト', () {
    late SimpleGame simpleGame;

    setUp(() {
      simpleGame = SimpleGame();
    });

    test('SimpleGame完全初期化', () async {
      debugPrint('🎯 SimpleGame統合テスト開始...');

      // SimpleGameの実際の初期化
      await simpleGame.onLoad();

      // 初期化確認
      expect(simpleGame.isInitialized, isTrue);
      expect(simpleGame.children.isNotEmpty, isTrue);

      // SimpleGame固有の要素確認（ParticleEffectManager、GameComponent）
      final particleManagers = simpleGame.children
          .query<ParticleEffectManager>();
      final gameComponents = simpleGame.children.whereType<GameComponent>();

      expect(particleManagers.length, equals(1));
      expect(gameComponents.length, greaterThanOrEqualTo(1)); // _testCircle

      debugPrint(
        '  ✅ SimpleGameコンポーネント: Particle=${particleManagers.length}, Game=${gameComponents.length}',
      );
      debugPrint('🎉 SimpleGame統合テスト成功！');
    });
  });
}
