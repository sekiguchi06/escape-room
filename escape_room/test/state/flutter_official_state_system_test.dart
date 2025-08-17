import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/foundation.dart';
import 'package:escape_room/framework/state/flutter_official_state_system.dart';

/// Flutter公式準拠状態管理システムの単体テスト
/// 
/// テスト対象:
/// 1. ChangeNotifierパターンの正しい実装
/// 2. 状態遷移の基本動作
/// 3. 統計情報の正確性
/// 4. イミュータブルなデータ取得
/// 5. メモリリーク防止
/// 6. Flutter公式準拠性の確認

/// テスト用ゲーム状態クラス
class TestGameState extends GameState {
  final String _name;
  
  const TestGameState(this._name);
  
  @override
  String get name => _name;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🎮 Flutter公式準拠ゲーム状態管理システム テスト', () {
    
    // テスト用状態インスタンス
    late TestGameState startState;
    late TestGameState playingState;
    late TestGameState pausedState;
    late TestGameState gameOverState;
    
    setUp(() {
      startState = const TestGameState('start');
      playingState = const TestGameState('playing');
      pausedState = const TestGameState('paused');
      gameOverState = const TestGameState('gameOver');
    });
    
    group('FlutterGameStateProvider基本機能テスト', () {
      test('Flutter公式ChangeNotifier継承確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // ChangeNotifierを継承していることを確認
        expect(provider, isA<ChangeNotifier>());
        expect(provider, isA<FlutterGameStateProvider<TestGameState>>());
        
        // 初期状態が正しく設定されていることを確認
        expect(provider.currentState, equals(startState));
        expect(provider.currentState.name, equals('start'));
      });
      
      test('基本的な状態遷移確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // 初期状態確認
        expect(provider.currentState, equals(startState));
        
        // 状態遷移実行
        provider.transitionTo(playingState);
        expect(provider.currentState, equals(playingState));
        expect(provider.currentState.name, equals('playing'));
        
        // 再度遷移
        provider.transitionTo(pausedState);
        expect(provider.currentState, equals(pausedState));
        expect(provider.currentState.name, equals('paused'));
      });
      
      test('同じ状態への遷移スキップ確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        var notificationCount = 0;
        
        // リスナー追加
        provider.addListener(() {
          notificationCount++;
        });
        
        // 初回遷移
        provider.transitionTo(playingState);
        expect(notificationCount, equals(1));
        
        // 同じ状態への遷移（スキップされるべき）
        provider.transitionTo(playingState);
        expect(notificationCount, equals(1)); // 通知されないことを確認
      });
      
      test('強制状態設定確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        var notificationCount = 0;
        
        provider.addListener(() {
          notificationCount++;
        });
        
        // 強制状態変更
        provider.forceSetState(gameOverState);
        expect(provider.currentState, equals(gameOverState));
        expect(notificationCount, equals(1));
        
        // 同じ状態でも強制変更は通知される
        provider.forceSetState(gameOverState);
        expect(notificationCount, equals(2));
      });
    });
    
    group('ChangeNotifier動作確認', () {
      test('リスナー通知の正確性', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        var notificationCount = 0;
        TestGameState? lastNotifiedState;
        
        provider.addListener(() {
          notificationCount++;
          lastNotifiedState = provider.currentState;
        });
        
        // 状態遷移1
        provider.transitionTo(playingState);
        expect(notificationCount, equals(1));
        expect(lastNotifiedState, equals(playingState));
        
        // 状態遷移2
        provider.transitionTo(pausedState);
        expect(notificationCount, equals(2));
        expect(lastNotifiedState, equals(pausedState));
        
        // 状態遷移3
        provider.transitionTo(gameOverState);
        expect(notificationCount, equals(3));
        expect(lastNotifiedState, equals(gameOverState));
      });
      
      test('複数リスナー動作確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        var listener1Count = 0;
        var listener2Count = 0;
        
        provider.addListener(() => listener1Count++);
        provider.addListener(() => listener2Count++);
        
        provider.transitionTo(playingState);
        
        expect(listener1Count, equals(1));
        expect(listener2Count, equals(1));
      });
      
      test('リスナー削除動作確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        var notificationCount = 0;
        
        void listener() => notificationCount++;
        
        provider.addListener(listener);
        provider.transitionTo(playingState);
        expect(notificationCount, equals(1));
        
        provider.removeListener(listener);
        provider.transitionTo(gameOverState);
        expect(notificationCount, equals(1)); // 削除後は通知されない
      });
    });
    
    group('統計情報管理確認', () {
      test('セッション管理確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // 初期セッション状態
        expect(provider.sessionCount, equals(0));
        expect(provider.sessionStartTime, isA<DateTime>());
        
        // セッション開始
        provider.startNewSession();
        expect(provider.sessionCount, equals(1));
        
        // 複数セッション
        provider.startNewSession();
        provider.startNewSession();
        expect(provider.sessionCount, equals(3));
        
        // セッション継続時間は正の値
        expect(provider.sessionDuration.inMicroseconds, greaterThanOrEqualTo(0));
      });
      
      test('状態変更カウント確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        expect(provider.totalStateChanges, equals(0));
        
        provider.transitionTo(playingState);
        expect(provider.totalStateChanges, equals(1));
        
        provider.transitionTo(pausedState);
        expect(provider.totalStateChanges, equals(2));
        
        provider.transitionTo(gameOverState);
        expect(provider.totalStateChanges, equals(3));
        
        // 同じ状態への遷移はカウントされない
        provider.transitionTo(gameOverState);
        expect(provider.totalStateChanges, equals(3));
      });
      
      test('状態訪問回数確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // 初期状態の訪問回数
        expect(provider.stateVisitCounts['start'], equals(1));
        
        // 状態遷移による訪問回数増加
        provider.transitionTo(playingState);
        expect(provider.stateVisitCounts['playing'], equals(1));
        
        provider.transitionTo(pausedState);
        provider.transitionTo(playingState); // 再訪問
        expect(provider.stateVisitCounts['playing'], equals(2));
        expect(provider.stateVisitCounts['paused'], equals(1));
      });
      
      test('遷移履歴記録確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        expect(provider.transitionHistory, isEmpty);
        
        provider.transitionTo(playingState);
        expect(provider.transitionHistory.length, equals(1));
        
        final firstTransition = provider.transitionHistory.first;
        expect(firstTransition.from, equals(startState));
        expect(firstTransition.to, equals(playingState));
        expect(firstTransition.timestamp, isA<DateTime>());
        
        provider.transitionTo(gameOverState);
        expect(provider.transitionHistory.length, equals(2));
        
        final secondTransition = provider.transitionHistory[1];
        expect(secondTransition.from, equals(playingState));
        expect(secondTransition.to, equals(gameOverState));
      });
      
      test('遷移履歴サイズ制限確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // 1000回以上の遷移でサイズ制限をテスト
        for (int i = 0; i < 1002; i++) {
          provider.transitionTo(i % 2 == 0 ? playingState : pausedState);
        }
        
        // 最大1000件に制限されることを確認
        expect(provider.transitionHistory.length, equals(1000));
      });
    });
    
    group('統計情報取得確認', () {
      test('StateStatistics構造確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        provider.startNewSession();
        provider.transitionTo(playingState);
        provider.transitionTo(pausedState);
        provider.transitionTo(playingState); // 再訪問
        
        final stats = provider.getStatistics();
        
        expect(stats.currentState, equals('playing'));
        expect(stats.sessionCount, equals(1));
        expect(stats.totalStateChanges, equals(3));
        expect(stats.sessionDuration, isA<Duration>());
        expect(stats.stateVisitCounts, isA<Map<String, int>>());
        expect(stats.mostVisitedState, equals('playing')); // 2回訪問
        expect(stats.averageStateTransitionsPerSession, equals(3.0));
      });
      
      test('統計情報JSON変換確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        provider.startNewSession();
        provider.transitionTo(playingState);
        
        final stats = provider.getStatistics();
        final json = stats.toJson();
        
        expect(json, isA<Map<String, dynamic>>());
        expect(json['currentState'], equals('playing'));
        expect(json['sessionCount'], equals(1));
        expect(json['totalStateChanges'], equals(1));
        expect(json['sessionDurationSeconds'], isA<int>());
        expect(json['stateVisitCounts'], isA<Map<String, int>>());
        expect(json['averageStateTransitionsPerSession'], equals(1.0));
      });
    });
    
    group('イミュータビリティ確認', () {
      test('stateVisitCounts変更不可確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        final visitCounts = provider.stateVisitCounts;
        
        // 返されたMapは変更不可であることを確認
        expect(() => visitCounts['test'] = 999, throwsUnsupportedError);
      });
      
      test('transitionHistory変更不可確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        provider.transitionTo(playingState);
        
        final history = provider.transitionHistory;
        
        // 返されたListは変更不可であることを確認
        expect(() => history.add(StateTransitionRecord(
          from: startState,
          to: pausedState,
          timestamp: DateTime.now(),
        )), throwsUnsupportedError);
      });
    });
    
    group('デバッグ情報確認', () {
      test('デバッグ情報構造確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        provider.startNewSession();
        provider.transitionTo(playingState);
        
        final debugInfo = provider.getDebugInfo();
        
        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['provider_type'], equals('ChangeNotifier'));
        expect(debugInfo['currentState'], equals('playing'));
        expect(debugInfo['sessionCount'], equals(1));
        expect(debugInfo['totalStateChanges'], equals(1));
        expect(debugInfo['sessionDuration'], isA<int>());
        expect(debugInfo['stateVisitCounts'], isA<Map<String, int>>());
        expect(debugInfo['transitionHistorySize'], equals(1));
      });
    });
    
    group('メモリ管理確認', () {
      test('dispose処理確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // データを蓄積
        provider.transitionTo(playingState);
        provider.transitionTo(pausedState);
        
        // dispose前の状態確認
        expect(provider.transitionHistory.isNotEmpty, isTrue);
        expect(provider.stateVisitCounts.isNotEmpty, isTrue);
        
        // dispose実行
        provider.dispose();
        
        // dispose後の状態確認（メモリ解放）
        expect(provider.transitionHistory.isEmpty, isTrue);
        expect(provider.stateVisitCounts.isEmpty, isTrue);
      });
    });
    
    group('エラーハンドリング確認', () {
      test('統計情報の安全性確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // 基本的な統計情報が正常に取得できることを確認
        final stats = provider.getStatistics();
        expect(stats.mostVisitedState, equals('start')); // 初期状態が記録される
        expect(stats.currentState, equals('start'));
        expect(stats.sessionDuration, isA<Duration>());
      });
    });
    
    group('StateTransitionRecord確認', () {
      test('StateTransitionRecord基本機能', () {
        final now = DateTime.now();
        final record = StateTransitionRecord<TestGameState>(
          from: startState,
          to: playingState,
          timestamp: now,
        );
        
        expect(record.from, equals(startState));
        expect(record.to, equals(playingState));
        expect(record.timestamp, equals(now));
      });
      
      test('StateTransitionRecord継続時間計算', () {
        final time1 = DateTime.now();
        final time2 = time1.add(const Duration(seconds: 5));
        
        final record1 = StateTransitionRecord<TestGameState>(
          from: startState,
          to: playingState,
          timestamp: time1,
        );
        
        final record2 = StateTransitionRecord<TestGameState>(
          from: playingState,
          to: pausedState,
          timestamp: time2,
        );
        
        final duration = record1.durationTo(record2);
        expect(duration, equals(const Duration(seconds: 5)));
      });
      
      test('StateTransitionRecord JSON変換', () {
        final record = StateTransitionRecord<TestGameState>(
          from: startState,
          to: playingState,
          timestamp: DateTime.fromMillisecondsSinceEpoch(1000000),
        );
        
        final json = record.toJson();
        expect(json['from'], equals('start'));
        expect(json['to'], equals('playing'));
        expect(json['timestamp'], equals(1000000));
      });
      
      test('StateTransitionRecord等価性確認', () {
        final timestamp = DateTime.now();
        final record1 = StateTransitionRecord<TestGameState>(
          from: startState,
          to: playingState,
          timestamp: timestamp,
        );
        
        final record2 = StateTransitionRecord<TestGameState>(
          from: startState,
          to: playingState,
          timestamp: timestamp,
        );
        
        expect(record1, equals(record2));
        expect(record1.hashCode, equals(record2.hashCode));
      });
    });
    
    group('後方互換性確認', () {
      test('GameStateProviderエイリアス動作確認', () {
        // typedef GameStateProvider = FlutterGameStateProvider
        final provider = GameStateProvider<TestGameState>(startState);
        
        expect(provider, isA<FlutterGameStateProvider<TestGameState>>());
        expect(provider, isA<ChangeNotifier>());
        expect(provider.currentState, equals(startState));
        
        // 基本機能も正常動作
        provider.transitionTo(playingState);
        expect(provider.currentState, equals(playingState));
      });
    });
    
    group('Flutter公式準拠性確認', () {
      test('ChangeNotifier準拠パターン確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        
        // Flutter公式ChangeNotifierパターンの確認
        expect(provider, isA<ChangeNotifier>());
        
        // リスナー追加テスト（protectedメンバーは直接テストしない）
        bool listenerCalled = false;
        provider.addListener(() {
          listenerCalled = true;
        });
        
        // notifyListeners()による通知確認（状態変更で自動的に通知される）
        provider.transitionTo(playingState);
        expect(listenerCalled, isTrue);
      });
      
      test('公式推奨パターン確認', () {
        final provider = FlutterGameStateProvider<TestGameState>(startState);
        final debugInfo = provider.getDebugInfo();
        
        // Flutter公式準拠であることを明示
        expect(debugInfo['flutter_official_compliant'], isTrue);
        expect(debugInfo['provider_type'], equals('ChangeNotifier'));
      });
    });
  });
}