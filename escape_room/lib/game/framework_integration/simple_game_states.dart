import '../../framework/state/game_state_base.dart';

/// シンプルなゲーム状態の基底クラス
abstract class SimpleGameState extends GameState {
  const SimpleGameState();

  /// セッション番号（追加プロパティ）
  int get sessionNumber => 1;
}

/// ゲーム開始状態
class SimpleGameStartState extends SimpleGameState {
  const SimpleGameStartState();

  @override
  int get sessionNumber => 0;

  @override
  String get name => 'Start';

  @override
  String toString() => 'SimpleGameStartState';
}

/// ゲームプレイ状態
class SimpleGamePlayingState extends SimpleGameState {
  @override
  final int sessionNumber;
  final int score;
  final double timeRemaining;
  final int level;

  const SimpleGamePlayingState({
    this.sessionNumber = 1,
    this.score = 0,
    this.timeRemaining = 60.0,
    this.level = 1,
  });

  @override
  String get name => 'Playing';

  @override
  String toString() =>
      'SimpleGamePlayingState(sessionNumber: $sessionNumber, score: $score, timeRemaining: $timeRemaining, level: $level)';
}

/// ゲーム終了状態
class SimpleGameOverState extends SimpleGameState {
  final bool isVictory;
  final String? message;
  final int finalScore;
  final double finalTime;
  @override
  final int sessionNumber;

  const SimpleGameOverState({
    this.isVictory = false,
    this.message,
    this.finalScore = 0,
    this.finalTime = 0.0,
    this.sessionNumber = 1,
  });

  @override
  String get name => 'Game Over';

  @override
  String toString() =>
      'SimpleGameOverState(victory: $isVictory, score: $finalScore, finalTime: $finalTime, sessionNumber: $sessionNumber, message: $message)';
}
