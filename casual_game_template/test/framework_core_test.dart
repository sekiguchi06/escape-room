import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:casual_game_template/framework/state/game_state_system.dart';
import 'package:casual_game_template/framework/config/game_configuration.dart';
import 'package:casual_game_template/framework/timer/flame_timer_system.dart';
import 'package:casual_game_template/framework/ui/flutter_theme_system.dart';

/// テスト用の汎用ゲーム状態定義
class TestGameIdleState extends GameState {
  const TestGameIdleState() : super();
  
  @override
  String get name => 'idle';
  
  @override
  String get description => 'アイドル状態';
}

class TestGameActiveState extends GameState {
  final int level;
  final double progress;
  
  const TestGameActiveState({
    required this.level,
    required this.progress,
  }) : super();
  
  @override
  String get name => 'active';
  
  @override
  String get description => 'アクティブ状態 (レベル$level, 進捗${(progress * 100).toStringAsFixed(1)}%)';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'level': level,
      'progress': progress,
    };
  }
  
  @override
  bool operator ==(Object other) {
    return other is TestGameActiveState && 
           other.level == level &&
           other.progress == progress;
  }
  
  @override
  int get hashCode => Object.hash(name, level, progress);
}

class TestGameCompletedState extends GameState {
  final int finalLevel;
  final Duration completionTime;
  
  const TestGameCompletedState({
    required this.finalLevel,
    required this.completionTime,
  }) : super();
  
  @override
  String get name => 'completed';
  
  @override
  String get description => '完了状態 (最終レベル$finalLevel, 時間${completionTime.inSeconds}秒)';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'finalLevel': finalLevel,
      'completionTime': completionTime.inMilliseconds,
    };
  }
}

/// テスト用の汎用ゲーム設定
class TestGameConfig {
  final Duration maxTime;
  final int maxLevel;
  final Map<String, String> messages;
  final Map<String, Color> colors;
  final bool enablePowerUps;
  final double difficultyMultiplier;
  
  const TestGameConfig({
    required this.maxTime,
    required this.maxLevel,
    required this.messages,
    required this.colors,
    this.enablePowerUps = false,
    this.difficultyMultiplier = 1.0,
  });
  
  TestGameConfig copyWith({
    Duration? maxTime,
    int? maxLevel,
    Map<String, String>? messages,
    Map<String, Color>? colors,
    bool? enablePowerUps,
    double? difficultyMultiplier,
  }) {
    return TestGameConfig(
      maxTime: maxTime ?? this.maxTime,
      maxLevel: maxLevel ?? this.maxLevel,
      messages: messages ?? this.messages,
      colors: colors ?? this.colors,
      enablePowerUps: enablePowerUps ?? this.enablePowerUps,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'maxTimeMs': maxTime.inMilliseconds,
      'maxLevel': maxLevel,
      'messages': messages,
      'colors': colors.map((k, v) => MapEntry(k, v.toARGB32())),
      'enablePowerUps': enablePowerUps,
      'difficultyMultiplier': difficultyMultiplier,
    };
  }
  
  factory TestGameConfig.fromJson(Map<String, dynamic> json) {
    return TestGameConfig(
      maxTime: Duration(milliseconds: json['maxTimeMs'] ?? 60000),
      maxLevel: json['maxLevel'] ?? 5,
      messages: Map<String, String>.from(json['messages'] ?? {}),
      colors: (json['colors'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, Color(v as int))),
      enablePowerUps: json['enablePowerUps'] ?? false,
      difficultyMultiplier: (json['difficultyMultiplier'] ?? 1.0).toDouble(),
    );
  }
}

/// テスト用の汎用ゲーム設定クラス
class TestGameConfiguration extends GameConfiguration<GameState, TestGameConfig> 
    with ChangeNotifier, ConfigurationNotifier<GameState, TestGameConfig> {
  
  TestGameConfiguration({required super.config});
  
  @override
  bool isValid() {
    return config.maxTime.inMilliseconds > 0 &&
           config.maxLevel > 0 &&
           config.messages.isNotEmpty;
  }
  
  @override
  bool isValidConfig(TestGameConfig config) {
    return config.maxTime.inMilliseconds > 0 &&
           config.maxLevel > 0 &&
           config.messages.isNotEmpty;
  }
  
  @override
  TestGameConfig copyWith(Map<String, dynamic> overrides) {
    return config.copyWith(
      maxTime: overrides['maxTime'] as Duration?,
      maxLevel: overrides['maxLevel'] as int?,
      messages: overrides['messages'] as Map<String, String>?,
      colors: overrides['colors'] as Map<String, Color>?,
      enablePowerUps: overrides['enablePowerUps'] as bool?,
      difficultyMultiplier: overrides['difficultyMultiplier'] as double?,
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return config.toJson();
  }
  
  static TestGameConfiguration fromJson(Map<String, dynamic> json) {
    return TestGameConfiguration(
      config: TestGameConfig.fromJson(json),
    );
  }
  
  @override
  TestGameConfig getConfigForVariant(String variantId) {
    switch (variantId) {
      case 'easy':
        return config.copyWith(
          maxTime: Duration(seconds: 120),
          maxLevel: 3,
          difficultyMultiplier: 0.5,
        );
      case 'hard':
        return config.copyWith(
          maxTime: Duration(seconds: 30),
          maxLevel: 10,
          difficultyMultiplier: 2.0,
        );
      default:
        return config;
    }
  }
}

/// テスト用の状態プロバイダー
class TestGameStateProvider extends GameStateProvider<GameState> {
  TestGameStateProvider() : super(const TestGameIdleState()) {
    _setupTransitions();
  }
  
  void _setupTransitions() {
    stateMachine.defineTransitions([
      // Idle -> Active
      StateTransition<GameState>(
        fromState: TestGameIdleState,
        toState: TestGameActiveState,
        onTransition: (from, to) {
          final activeState = to as TestGameActiveState;
          debugPrint('ゲーム開始: レベル${activeState.level}');
        },
      ),
      
      // Active -> Active (進捗更新)
      StateTransition<GameState>(
        fromState: TestGameActiveState,
        toState: TestGameActiveState,
        onTransition: (from, to) {
          final fromActive = from as TestGameActiveState;
          final toActive = to as TestGameActiveState;
          if (toActive.level > fromActive.level) {
            debugPrint('レベルアップ: ${fromActive.level} -> ${toActive.level}');
          }
        },
      ),
      
      // Active -> Completed
      StateTransition<GameState>(
        fromState: TestGameActiveState,
        toState: TestGameCompletedState,
        onTransition: (from, to) {
          final activeState = from as TestGameActiveState;
          final completedState = to as TestGameCompletedState;
          debugPrint('ゲーム完了: レベル${activeState.level} -> 最終レベル${completedState.finalLevel}');
        },
      ),
      
      // Completed -> Idle (リセット)
      StateTransition<GameState>(
        fromState: TestGameCompletedState,
        toState: TestGameIdleState,
        onTransition: (from, to) {
          debugPrint('ゲームリセット');
        },
      ),
    ]);
  }
  
  /// ゲーム開始
  bool startGame(int initialLevel) {
    final newState = TestGameActiveState(level: initialLevel, progress: 0.0);
    final success = transitionTo(newState);
    if (success) {
      startNewSession();
    }
    return success;
  }
  
  /// 進捗更新
  bool updateProgress(int level, double progress) {
    if (currentState is! TestGameActiveState) return false;
    
    final newState = TestGameActiveState(level: level, progress: progress);
    return transitionTo(newState);
  }
  
  /// ゲーム完了
  bool completeGame(int finalLevel, Duration completionTime) {
    if (currentState is! TestGameActiveState) return false;
    
    final completedState = TestGameCompletedState(
      finalLevel: finalLevel,
      completionTime: completionTime,
    );
    return transitionTo(completedState);
  }
  
  /// リセット
  bool resetGame() {
    if (currentState is! TestGameCompletedState) return false;
    
    return transitionTo(const TestGameIdleState());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('フレームワークコア基盤テスト', () {
    test('汎用状態管理システム - 基本動作', () {
      debugPrint('🔧 汎用状態管理システムテスト開始...');
      
      // カスタム状態での状態マシン作成
      final stateMachine = GameStateMachine<GameState>(const TestGameIdleState());
      
      // 状態遷移定義
      stateMachine.defineTransition(StateTransition<GameState>(
        fromState: TestGameIdleState,
        toState: TestGameActiveState,
        condition: (current, target) => 
            current is TestGameIdleState && target is TestGameActiveState,
      ));
      
      // 初期状態確認
      expect(stateMachine.currentState, isA<TestGameIdleState>());
      debugPrint('  ✅ 初期状態: ${stateMachine.currentState.name}');
      
      // 状態遷移実行
      final activeState = TestGameActiveState(level: 1, progress: 0.0);
      final success = stateMachine.transitionTo(activeState);
      
      expect(success, isTrue);
      expect(stateMachine.currentState, isA<TestGameActiveState>());
      debugPrint('  ✅ 状態遷移成功: ${stateMachine.currentState.description}');
      
      // 遷移可能性チェック
      final canTransitionToCompleted = stateMachine.canTransitionTo(
        TestGameCompletedState(finalLevel: 5, completionTime: Duration(seconds: 30))
      );
      expect(canTransitionToCompleted, isFalse); // 遷移定義されていないので失敗
      debugPrint('  ✅ 無効遷移の適切な拒否');
      
      debugPrint('🎉 汎用状態管理システムテスト完了！');
    });
    
    test('汎用設定管理システム - 設定駆動', () {
      debugPrint('⚙️ 汎用設定管理システムテスト開始...');
      
      // テスト用設定作成
      final config = TestGameConfig(
        maxTime: Duration(seconds: 60),
        maxLevel: 5,
        messages: {
          'start': 'ゲーム開始',
          'progress': '進行中',
          'complete': '完了',
        },
        colors: {
          'primary': Colors.blue,
          'secondary': Colors.green,
          'danger': Colors.red,
        },
        enablePowerUps: true,
        difficultyMultiplier: 1.5,
      );
      
      debugPrint('  📝 設定作成完了:');
      debugPrint('    - 最大時間: ${config.maxTime.inSeconds}秒');
      debugPrint('    - 最大レベル: ${config.maxLevel}');
      debugPrint('    - パワーアップ: ${config.enablePowerUps}');
      debugPrint('    - 難易度倍率: ${config.difficultyMultiplier}');
      
      // 設定オブジェクト作成
      final configuration = TestGameConfiguration(config: config);
      expect(configuration.isValid(), isTrue);
      debugPrint('  ✅ 設定バリデーション成功');
      
      // JSON変換テスト
      final json = configuration.toJson();
      final restoredConfiguration = TestGameConfiguration.fromJson(json);
      
      expect(restoredConfiguration.config.maxTime, equals(config.maxTime));
      expect(restoredConfiguration.config.maxLevel, equals(config.maxLevel));
      expect(restoredConfiguration.config.enablePowerUps, equals(config.enablePowerUps));
      debugPrint('  ✅ JSON変換・復元成功');
      
      // A/Bテスト設定テスト
      final easyVariant = configuration.getConfigForVariant('easy');
      expect(easyVariant.maxTime.inSeconds, equals(120));
      expect(easyVariant.maxLevel, equals(3));
      expect(easyVariant.difficultyMultiplier, equals(0.5));
      debugPrint('  ✅ A/Bテストバリアント (easy): ${easyVariant.maxTime.inSeconds}秒, レベル${easyVariant.maxLevel}');
      
      final hardVariant = configuration.getConfigForVariant('hard');
      expect(hardVariant.maxTime.inSeconds, equals(30));
      expect(hardVariant.maxLevel, equals(10));
      expect(hardVariant.difficultyMultiplier, equals(2.0));
      debugPrint('  ✅ A/Bテストバリアント (hard): ${hardVariant.maxTime.inSeconds}秒, レベル${hardVariant.maxLevel}');
      
      debugPrint('🎉 汎用設定管理システムテスト完了！');
    });
    
    test('汎用タイマーシステム - 各種タイマータイプ', () {
      debugPrint('⏱️ 汎用タイマーシステムテスト開始...');
      
      // カウントダウンタイマー
      debugPrint('  🔻 カウントダウンタイマーテスト...');
      bool countdownCompleted = false; // タイマー完了フラグ
      final countdownTimer = FlameGameTimer('countdown_test', TimerConfiguration(
        duration: Duration(seconds: 3),
        type: TimerType.countdown,
        onComplete: () => countdownCompleted = true,
      ));
      
      expect(countdownTimer.remaining, equals(Duration(seconds: 3)));
      expect(countdownTimer.type, equals(TimerType.countdown));
      debugPrint('    ✅ 初期値: ${countdownTimer.remaining.inSeconds}秒');
      
      // タイマー開始・更新シミュレーション
      countdownTimer.start();
      expect(countdownTimer.isRunning, isTrue);
      
      // 1秒進行をシミュレート
      countdownTimer.update(1.0);
      expect(countdownTimer.remaining.inSeconds, equals(2));
      debugPrint('    ✅ 1秒後: ${countdownTimer.remaining.inSeconds}秒');
      
      // 完了まで進行してフラグをテスト
      expect(countdownCompleted, isFalse);
      countdownTimer.update(2.1); // 残り時間を0にする
      expect(countdownCompleted, isTrue);
      debugPrint('    ✅ タイマー完了フラグ: $countdownCompleted');
      
      // カウントアップタイマー
      debugPrint('  🔺 カウントアップタイマーテスト...');
      bool countupCompleted = false; // タイマー完了フラグ
      final countupTimer = FlameGameTimer('countup_test', TimerConfiguration(
        duration: Duration(seconds: 5),
        type: TimerType.countup,
        onComplete: () => countupCompleted = true,
      ));
      
      expect(countupTimer.remaining, equals(Duration(seconds: 5)));
      expect(countupTimer.type, equals(TimerType.countup));
      
      countupTimer.start();
      countupTimer.update(2.0);
      expect(countupTimer.remaining.inSeconds, equals(3));
      debugPrint('    ✅ 2秒後: ${countupTimer.remaining.inSeconds}秒残り');
      
      // 完了フラグのテスト
      expect(countupCompleted, isFalse);
      countupTimer.update(3.1); // 残り時間を0にする
      expect(countupCompleted, isTrue);
      debugPrint('    ✅ カウントアップタイマー完了フラグ: $countupCompleted');
      
      // インターバルタイマー
      debugPrint('  🔄 インターバルタイマーテスト...');
      int intervalCount = 0;
      final intervalTimer = FlameGameTimer('interval_test', TimerConfiguration(
        duration: Duration(seconds: 2),
        type: TimerType.interval,
        onComplete: () => intervalCount++,
      ));
      
      intervalTimer.start();
      intervalTimer.update(2.5); // 2秒を超えると1回完了
      expect(intervalCount, equals(1));
      debugPrint('    ✅ インターバル完了回数: $intervalCount');
      
      // タイマー制御操作
      debugPrint('  🎛️ タイマー制御テスト...');
      final controlTimer = FlameGameTimer('control_test', const TimerConfiguration(
        duration: Duration(seconds: 10),
        type: TimerType.countdown,
      ));
      
      controlTimer.start();
      expect(controlTimer.isRunning, isTrue);
      
      controlTimer.pause();
      expect(controlTimer.isPaused, isTrue);
      expect(controlTimer.isRunning, isFalse);
      
      controlTimer.resume();
      expect(controlTimer.isPaused, isFalse);
      expect(controlTimer.isRunning, isTrue);
      
      controlTimer.reset();
      expect(controlTimer.isRunning, isFalse);
      expect(controlTimer.remaining, equals(Duration(seconds: 10)));
      debugPrint('    ✅ 制御操作 (開始/一時停止/再開/リセット) 成功');
      
      debugPrint('🎉 汎用タイマーシステムテスト完了！');
    });
    
    test('汎用UIテーマシステム - テーマ管理', () {
      debugPrint('🎨 汎用UIテーマシステムテスト開始...');
      
      final themeManager = FlutterThemeManager();
      themeManager.initializeDefaultThemes();
      
      // 利用可能なテーマ確認
      final availableThemes = themeManager.getAvailableThemes();
      expect(availableThemes.length, greaterThan(0));
      debugPrint('  📋 利用可能テーマ: ${availableThemes.join(', ')}');
      
      // デフォルトテーマ確認
      final defaultTheme = themeManager.currentTheme;
      final primaryColor = defaultTheme.getColor('primary');
      final textSize = defaultTheme.getFontSize('medium');
      
      expect(primaryColor, isNotNull);
      expect(textSize, greaterThan(0));
      debugPrint('  🎯 デフォルトテーマ - プライマリ色: $primaryColor, テキストサイズ: $textSize');
      
      // テーマ変更
      if (availableThemes.contains('dark')) {
        themeManager.setTheme('dark');
        expect(themeManager.currentThemeId, equals('dark'));
        debugPrint('  🌙 ダークテーマに変更成功');
        
        final darkPrimaryColor = themeManager.currentTheme.getColor('primary');
        debugPrint('  🎨 ダークテーマプライマリ色: $darkPrimaryColor');
      }
      
      // カスタムテーマ登録
      final customTheme = FlutterUITheme(
        themeData: ThemeData(
          primarySwatch: Colors.purple,
          fontFamily: 'Arial',
        ),
        colors: const {
          'primary': Colors.purple,
          'secondary': Colors.orange,
          'accent': Colors.cyan,
        },
        fontSizes: const {
          'small': 10.0,
          'medium': 14.0,
          'large': 18.0,
        },
      );
      
      themeManager.registerTheme('custom', customTheme);
      themeManager.setTheme('custom');
      
      expect(themeManager.currentThemeId, equals('custom'));
      expect(themeManager.currentTheme.getColor('primary'), equals(Colors.purple));
      debugPrint('  🎭 カスタムテーマ登録・適用成功');
      
      debugPrint('🎉 汎用UIテーマシステムテスト完了！');
    });
    
    test('統合シナリオ - 複合ゲームシミュレーション', () {
      debugPrint('🎮 統合シナリオテスト開始...');
      
      // 設定作成
      final config = TestGameConfig(
        maxTime: Duration(seconds: 30),
        maxLevel: 3,
        messages: {
          'start': 'Ready to play?',
          'level_up': 'Level Up!',
          'complete': 'Congratulations!',
        },
        colors: {
          'normal': Colors.blue,
          'warning': Colors.orange,
          'critical': Colors.red,
        },
        enablePowerUps: true,
        difficultyMultiplier: 1.2,
      );
      
      final configuration = TestGameConfiguration(config: config);
      final stateProvider = TestGameStateProvider();
      
      debugPrint('  🎯 ゲームシナリオ実行...');
      
      // Phase 1: ゲーム開始
      expect(stateProvider.currentState, isA<TestGameIdleState>());
      debugPrint('    📍 初期状態: ${stateProvider.currentState.name}');
      
      final startSuccess = stateProvider.startGame(1);
      expect(startSuccess, isTrue);
      expect(stateProvider.currentState, isA<TestGameActiveState>());
      
      final initialState = stateProvider.currentState as TestGameActiveState;
      expect(initialState.level, equals(1));
      expect(initialState.progress, equals(0.0));
      debugPrint('    🚀 ゲーム開始: レベル${initialState.level}');
      
      // Phase 2: 進捗更新・レベルアップ
      stateProvider.updateProgress(1, 0.5);
      stateProvider.updateProgress(2, 0.0); // レベルアップ
      stateProvider.updateProgress(2, 0.8);
      stateProvider.updateProgress(3, 0.0); // レベルアップ
      
      final currentState = stateProvider.currentState as TestGameActiveState;
      expect(currentState.level, equals(3));
      debugPrint('    📈 最終レベル到達: レベル${currentState.level}');
      
      // Phase 3: ゲーム完了
      final completionTime = Duration(seconds: 25);
      final completeSuccess = stateProvider.completeGame(3, completionTime);
      expect(completeSuccess, isTrue);
      expect(stateProvider.currentState, isA<TestGameCompletedState>());
      
      final completedState = stateProvider.currentState as TestGameCompletedState;
      expect(completedState.finalLevel, equals(3));
      expect(completedState.completionTime, equals(completionTime));
      debugPrint('    🏆 ゲーム完了: 最終レベル${completedState.finalLevel}, 時間${completedState.completionTime.inSeconds}秒');
      
      // Phase 4: 統計確認
      final statistics = stateProvider.getStatistics();
      expect(statistics.sessionCount, greaterThan(0));
      expect(statistics.totalStateChanges, greaterThan(0));
      debugPrint('    📊 統計情報:');
      debugPrint('      - セッション数: ${statistics.sessionCount}');
      debugPrint('      - 状態変更数: ${statistics.totalStateChanges}');
      debugPrint('      - 最多訪問状態: ${statistics.mostVisitedState}');
      
      // Phase 5: リセット
      final resetSuccess = stateProvider.resetGame();
      expect(resetSuccess, isTrue);
      expect(stateProvider.currentState, isA<TestGameIdleState>());
      debugPrint('    🔄 ゲームリセット完了');
      
      // Phase 6: A/Bテスト設定変更
      final hardConfig = configuration.getConfigForVariant('hard');
      expect(hardConfig.maxTime.inSeconds, equals(30));
      expect(hardConfig.maxLevel, equals(10));
      expect(hardConfig.difficultyMultiplier, equals(2.0));
      debugPrint('    🧪 A/Bテスト (hard): 時間${hardConfig.maxTime.inSeconds}秒, レベル${hardConfig.maxLevel}, 難易度x${hardConfig.difficultyMultiplier}');
      
      debugPrint('🎉 統合シナリオテスト完了！');
    });
  });
}