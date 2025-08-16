import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../framework/state/game_state_system.dart';

/// SimpleGame用の状態列挙（game_config.dart用）
enum SimpleGameState {
  start,
  playing,
  gameOver,
}

/// SimpleGame用の状態定義（フレームワーク対応）
class SimpleGameStartState extends GameState {
  const SimpleGameStartState() : super();
  
  @override
  String get name => 'start';
  
  @override
  String get description => 'ゲーム開始待ち状態';
}

class SimpleGamePlayingState extends GameState {
  final double timeRemaining;
  final int sessionNumber;
  
  const SimpleGamePlayingState({
    this.timeRemaining = 30.0,
    this.sessionNumber = 1,
  }) : super();
  
  @override
  String get name => 'playing';
  
  @override
  String get description => 'ゲームプレイ中 (残り${timeRemaining.toStringAsFixed(1)}秒)';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'timeRemaining': timeRemaining,
      'sessionNumber': sessionNumber,
    };
  }
  
  @override
  bool operator ==(Object other) {
    return other is SimpleGamePlayingState && 
           other.timeRemaining == timeRemaining &&
           other.sessionNumber == sessionNumber;
  }
  
  @override
  int get hashCode => Object.hash(name, timeRemaining, sessionNumber);
}

class SimpleGameOverState extends GameState {
  final double finalTime;
  final int sessionNumber;
  final int finalScore;
  
  const SimpleGameOverState({
    this.finalTime = 0.0,
    this.sessionNumber = 1,
    this.finalScore = 0,
  }) : super();
  
  @override
  String get name => 'gameOver';
  
  @override
  String get description => 'ゲームオーバー (セッション$sessionNumber完了)';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'finalTime': finalTime,
      'sessionNumber': sessionNumber,
      'finalScore': finalScore,
    };
  }
  
  @override
  bool operator ==(Object other) {
    return other is SimpleGameOverState && 
           other.finalTime == finalTime &&
           other.sessionNumber == sessionNumber &&
           other.finalScore == finalScore;
  }
  
  @override
  int get hashCode => Object.hash(name, finalTime, sessionNumber, finalScore);
}

/// SimpleGame用のステートファクトリ
class SimpleGameStateFactory {
  static SimpleGameStartState createStartState() {
    return const SimpleGameStartState();
  }
  
  static SimpleGamePlayingState createPlayingState({
    required double timeRemaining,
    required int sessionNumber,
  }) {
    return SimpleGamePlayingState(
      timeRemaining: timeRemaining,
      sessionNumber: sessionNumber,
    );
  }
  
  static SimpleGameOverState createGameOverState({
    required double finalTime,
    required int sessionNumber,
    required int finalScore,
  }) {
    return SimpleGameOverState(
      finalTime: finalTime,
      sessionNumber: sessionNumber,
      finalScore: finalScore,
    );
  }
}

/// ゲーム状態クラス（Riverpod用）
class GameStateData {
  final GameState currentState;
  final int sessionCount;
  final int totalStateChanges;
  final DateTime sessionStartTime;
  final Map<String, int> stateVisitCounts;
  
  const GameStateData({
    required this.currentState,
    this.sessionCount = 0,
    this.totalStateChanges = 0,
    required this.sessionStartTime,
    this.stateVisitCounts = const {},
  });
  
  GameStateData copyWith({
    GameState? currentState,
    int? sessionCount,
    int? totalStateChanges,
    DateTime? sessionStartTime,
    Map<String, int>? stateVisitCounts,
  }) {
    return GameStateData(
      currentState: currentState ?? this.currentState,
      sessionCount: sessionCount ?? this.sessionCount,
      totalStateChanges: totalStateChanges ?? this.totalStateChanges,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      stateVisitCounts: stateVisitCounts ?? this.stateVisitCounts,
    );
  }
}

/// SimpleGame用のRiverpod状態プロバイダー
class SimpleGameStateNotifier extends StateNotifier<GameStateData> {
  SimpleGameStateNotifier() : super(GameStateData(
    currentState: SimpleGameStateFactory.createStartState(),
    sessionStartTime: DateTime.now(),
  ));
  
  /// 現在の状態が特定の型かチェック
  bool isInState<T extends GameState>() {
    return state.currentState is T;
  }
  
  /// 安全な状態キャスト
  T? getStateAs<T extends GameState>() {
    return state.currentState is T ? state.currentState as T : null;
  }
  
  /// ゲーム開始
  bool startGame(double initialTime) {
    final newState = SimpleGameStateFactory.createPlayingState(
      timeRemaining: initialTime,
      sessionNumber: state.sessionCount + 1,
    );
    
    if (_canTransitionTo(newState)) {
      _transitionTo(newState);
      _startNewSession();
      return true;
    }
    return false;
  }
  
  /// タイマー更新
  bool updateTimer(double timeRemaining) {
    if (state.currentState is! SimpleGamePlayingState) return false;
    
    final currentPlayingState = state.currentState as SimpleGamePlayingState;
    
    if (timeRemaining <= 0) {
      // ゲームオーバーに遷移
      final gameOverState = SimpleGameStateFactory.createGameOverState(
        finalTime: 0.0,
        sessionNumber: currentPlayingState.sessionNumber,
        finalScore: 0, // スコアは外部から設定
      );
      return _transitionTo(gameOverState);
    } else {
      // プレイ中状態の更新
      final updatedState = SimpleGameStateFactory.createPlayingState(
        timeRemaining: timeRemaining,
        sessionNumber: currentPlayingState.sessionNumber,
      );
      _forceSetState(updatedState);
      return true;
    }
  }
  
  /// リスタート
  bool restart(double initialTime) {
    if (state.currentState is! SimpleGameOverState) return false;
    
    final gameOverState = state.currentState as SimpleGameOverState;
    final newState = SimpleGameStateFactory.createPlayingState(
      timeRemaining: initialTime,
      sessionNumber: gameOverState.sessionNumber + 1,
    );
    
    if (_canTransitionTo(newState)) {
      _transitionTo(newState);
      _startNewSession();
      return true;
    }
    return false;
  }
  
  /// 状態を強制リセット（テスト用）
  void resetToState(GameState newState) {
    _forceSetState(newState);
  }
  
  /// 現在のゲーム情報を取得
  Map<String, dynamic> getCurrentGameInfo() {
    final currentState = state.currentState;
    
    return {
      'stateName': currentState.name,
      'stateDescription': currentState.description,
      'timeRemaining': currentState is SimpleGamePlayingState ? currentState.timeRemaining : null,
      'sessionNumber': currentState is SimpleGamePlayingState 
          ? currentState.sessionNumber 
          : (currentState is SimpleGameOverState ? currentState.sessionNumber : null),
      'finalTime': currentState is SimpleGameOverState ? currentState.finalTime : null,
      'canStart': _canTransitionTo(SimpleGameStateFactory.createPlayingState(timeRemaining: 5.0, sessionNumber: 1)),
      'canRestart': currentState is SimpleGameOverState,
    };
  }
  
  /// 状態遷移可能性チェック（簡易版）
  bool _canTransitionTo(GameState newState) {
    final current = state.currentState;
    
    // Start -> Playing
    if (current is SimpleGameStartState && newState is SimpleGamePlayingState) {
      return true;
    }
    
    // Playing -> GameOver
    if (current is SimpleGamePlayingState && newState is SimpleGameOverState) {
      return true;
    }
    
    // GameOver -> Start
    if (current is SimpleGameOverState && newState is SimpleGameStartState) {
      return true;
    }
    
    // Playing -> Playing (タイマー更新)
    if (current is SimpleGamePlayingState && newState is SimpleGamePlayingState) {
      return true;
    }
    
    // GameOver -> Playing (直接リスタート)
    if (current is SimpleGameOverState && newState is SimpleGamePlayingState) {
      return true;
    }
    
    return false;
  }
  
  /// 状態遷移を実行
  bool _transitionTo(GameState newState) {
    if (!_canTransitionTo(newState)) {
      debugPrint('Invalid transition: ${state.currentState.name} -> ${newState.name}');
      return false;
    }
    
    final oldState = state.currentState;
    
    // 状態変更
    state = state.copyWith(
      currentState: newState,
      totalStateChanges: state.totalStateChanges + 1,
      stateVisitCounts: _updateStateVisitCounts(newState),
    );
    
    // 遷移ログ
    _logTransition(oldState, newState);
    
    return true;
  }
  
  /// 強制的に状態を設定（遷移チェックなし）
  void _forceSetState(GameState newState) {
    state = state.copyWith(
      currentState: newState,
      totalStateChanges: state.totalStateChanges + 1,
      stateVisitCounts: _updateStateVisitCounts(newState),
    );
  }
  
  /// 新しいセッション開始
  void _startNewSession() {
    state = state.copyWith(
      sessionCount: state.sessionCount + 1,
      sessionStartTime: DateTime.now(),
    );
    debugPrint('New session started: ${state.sessionCount}');
  }
  
  /// 状態訪問回数を更新
  Map<String, int> _updateStateVisitCounts(GameState newState) {
    final counts = Map<String, int>.from(state.stateVisitCounts);
    final stateName = newState.name;
    counts[stateName] = (counts[stateName] ?? 0) + 1;
    return counts;
  }
  
  /// 遷移ログ
  void _logTransition(GameState from, GameState to) {
    if (from is SimpleGameStartState && to is SimpleGamePlayingState) {
      debugPrint('ゲーム開始: セッション${to.sessionNumber}');
    } else if (from is SimpleGamePlayingState && to is SimpleGameOverState) {
      debugPrint('ゲームオーバー: セッション${from.sessionNumber} -> 最終時刻${to.finalTime}');
    } else if (from is SimpleGameOverState && to is SimpleGameStartState) {
      debugPrint('リスタート準備完了');
    } else if (from is SimpleGameOverState && to is SimpleGamePlayingState) {
      debugPrint('直接リスタート: セッション${from.sessionNumber} -> セッション${to.sessionNumber}');
    }
    
    debugPrint('State transition: ${from.name} -> ${to.name}');
  }
}

/// 状態プロバイダーへのアクセス用
final simpleGameStateProvider = StateNotifierProvider<SimpleGameStateNotifier, GameStateData>(
  (ref) => SimpleGameStateNotifier(),
);