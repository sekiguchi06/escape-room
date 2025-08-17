import 'package:flutter/foundation.dart';
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

/// SimpleGame用の状態遷移定義
class SimpleGameTransitions {
  static List<StateTransition<GameState>> getTransitions() {
    return [
      // Start -> Playing
      StateTransition<GameState>(
        fromState: SimpleGameStartState,
        toState: SimpleGamePlayingState,
        condition: (current, target) => current is SimpleGameStartState && target is SimpleGamePlayingState,
        onTransition: (from, to) {
          debugPrint('ゲーム開始: セッション${(to as SimpleGamePlayingState).sessionNumber}');
        },
      ),
      
      // Playing -> GameOver
      StateTransition<GameState>(
        fromState: SimpleGamePlayingState,
        toState: SimpleGameOverState,
        condition: (current, target) {
          if (current is! SimpleGamePlayingState || target is! SimpleGameOverState) {
            return false;
          }
          return current.timeRemaining <= 0 || target.finalTime <= 0;
        },
        onTransition: (from, to) {
          final playingState = from as SimpleGamePlayingState;
          final gameOverState = to as SimpleGameOverState;
          debugPrint('ゲームオーバー: セッション${playingState.sessionNumber} -> 最終時刻${gameOverState.finalTime}');
        },
      ),
      
      // GameOver -> Start
      StateTransition<GameState>(
        fromState: SimpleGameOverState,
        toState: SimpleGameStartState,
        onTransition: (from, to) {
          debugPrint('リスタート準備完了');
        },
      ),
      
      // Playing -> Playing (タイマー更新)
      StateTransition<GameState>(
        fromState: SimpleGamePlayingState,
        toState: SimpleGamePlayingState,
        condition: (current, target) => current is SimpleGamePlayingState && target is SimpleGamePlayingState,
        onTransition: (from, to) {
          // タイマー更新時の遷移は通常ログ出力しない（頻繁すぎる）
        },
      ),
      
      // GameOver -> Playing (直接リスタート)
      StateTransition<GameState>(
        fromState: SimpleGameOverState,
        toState: SimpleGamePlayingState,
        condition: (current, target) => current is SimpleGameOverState && target is SimpleGamePlayingState,
        onTransition: (from, to) {
          final gameOverState = from as SimpleGameOverState;
          final playingState = to as SimpleGamePlayingState;
          debugPrint('直接リスタート: セッション${gameOverState.sessionNumber} -> セッション${playingState.sessionNumber}');
        },
      ),
    ];
  }
}

/// SimpleGame用のステートファクトリ
class SimpleGameStateFactory {
  static SimpleGameStartState createStartState() {
    return SimpleGameStartState();
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
  }) {
    return SimpleGameOverState(
      finalTime: finalTime,
      sessionNumber: sessionNumber,
    );
  }
}

/// SimpleGame用の状態プロバイダー（フレームワーク統合）
class SimpleGameStateProvider extends GameStateProvider<GameState> {
  int _sessionCount = 0;
  
  SimpleGameStateProvider() : super(SimpleGameStateFactory.createStartState()) {
    // 状態遷移を定義
    stateMachine.defineTransitions(SimpleGameTransitions.getTransitions());
  }
  
  /// 現在のセッション数
  int get sessionCount => _sessionCount;
  
  /// 新しいセッションを開始
  void startNewSession() {
    _sessionCount++;
  }
  
  /// 現在の状態が特定の型かチェック
  bool isInState<T extends GameState>() {
    return currentState is T;
  }
  
  /// 安全な状態キャスト
  T? getStateAs<T extends GameState>() {
    return currentState is T ? currentState as T : null;
  }
  
  /// ゲーム開始
  bool startGame(double initialTime) {
    final newState = SimpleGameStateFactory.createPlayingState(
      timeRemaining: initialTime,
      sessionNumber: sessionCount + 1,
    );
    
    final success = transitionTo(newState);
    if (success) {
      startNewSession();
    }
    return success;
  }
  
  /// タイマー更新
  bool updateTimer(double timeRemaining) {
    if (currentState is! SimpleGamePlayingState) return false;
    
    final currentPlayingState = currentState as SimpleGamePlayingState;
    
    if (timeRemaining <= 0) {
      // ゲームオーバーに遷移
      final gameOverState = SimpleGameStateFactory.createGameOverState(
        finalTime: 0.0,
        sessionNumber: currentPlayingState.sessionNumber,
      );
      return transitionTo(gameOverState);
    } else {
      // プレイ中状態の更新
      final updatedState = SimpleGameStateFactory.createPlayingState(
        timeRemaining: timeRemaining,
        sessionNumber: currentPlayingState.sessionNumber,
      );
      stateMachine.forceSetState(updatedState);
      notifyListeners();
      return true;
    }
  }
  
  /// リスタート
  bool restart(double initialTime) {
    if (currentState is! SimpleGameOverState) return false;
    
    final gameOverState = currentState as SimpleGameOverState;
    final newState = SimpleGameStateFactory.createPlayingState(
      timeRemaining: initialTime,
      sessionNumber: gameOverState.sessionNumber + 1,
    );
    
    final success = transitionTo(newState);
    if (success) {
      startNewSession();
    }
    return success;
  }
  
  /// 状態を強制リセット（テスト用）
  void resetToState(GameState newState) {
    stateMachine.forceSetState(newState);
  }
  
  /// 現在のゲーム情報を取得
  Map<String, dynamic> getCurrentGameInfo() {
    final state = currentState;
    
    return {
      'stateName': state.name,
      'stateDescription': state.description,
      'timeRemaining': state is SimpleGamePlayingState ? state.timeRemaining : null,
      'sessionNumber': state is SimpleGamePlayingState 
          ? state.sessionNumber 
          : (state is SimpleGameOverState ? state.sessionNumber : null),
      'finalTime': state is SimpleGameOverState ? state.finalTime : null,
      'canStart': canTransitionTo(SimpleGameStateFactory.createPlayingState(timeRemaining: 5.0, sessionNumber: 1)),
      'canRestart': state is SimpleGameOverState,
    };
  }
}