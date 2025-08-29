import 'game_state_base.dart';
import 'game_state_machine.dart';
import 'game_state_provider.dart';

/// 脱出ゲーム用の状態定義
enum EscapeRoomState implements GameState {
  initial('初期状態'),
  exploring('探索中'),
  inventory('インベントリ'),
  puzzle('パズル'),
  puzzleSolving('パズル解き'),
  itemUsing('アイテム使用'),
  escaped('脱出成功！'),
  timeUp('時間切れ'),
  ending('エンディング'),
  gameOver('ゲームオーバー');

  const EscapeRoomState(this.description);

  @override
  final String description;

  @override
  String get name => toString().split('.').last;

  @override
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// 脱出ゲーム専用プロバイダー
class EscapeRoomStateProvider extends GameStateProvider<EscapeRoomState> {
  String? _currentPuzzleId;

  static const List<StateTransition<EscapeRoomState>> _defaultTransitions = [
    StateTransition<EscapeRoomState>(
      fromState: EscapeRoomState,
      toState: EscapeRoomState,
    ),
    StateTransition<EscapeRoomState>(
      fromState: EscapeRoomState,
      toState: EscapeRoomState,
    ),
    StateTransition<EscapeRoomState>(
      fromState: EscapeRoomState,
      toState: EscapeRoomState,
    ),
    StateTransition<EscapeRoomState>(
      fromState: EscapeRoomState,
      toState: EscapeRoomState,
    ),
    StateTransition<EscapeRoomState>(
      fromState: EscapeRoomState,
      toState: EscapeRoomState,
    ),
    StateTransition<EscapeRoomState>(
      fromState: EscapeRoomState,
      toState: EscapeRoomState,
    ),
    StateTransition<EscapeRoomState>(
      fromState: EscapeRoomState,
      toState: EscapeRoomState,
    ),
  ];

  EscapeRoomStateProvider() : super(EscapeRoomState.initial) {
    defineTransitions(_defaultTransitions);
  }

  /// 現在のパズルIDを取得
  String? get currentPuzzleId => _currentPuzzleId;

  /// ゲーム開始
  void startGame() {
    transitionTo(EscapeRoomState.exploring);
  }

  /// インベントリを表示
  void showInventory() {
    transitionTo(EscapeRoomState.inventory);
  }

  /// インベントリを非表示
  void hideInventory() {
    if (currentState == EscapeRoomState.inventory) {
      transitionTo(EscapeRoomState.exploring);
    }
  }

  /// パズル開始
  void startPuzzle([String? puzzleId]) {
    _currentPuzzleId = puzzleId;
    transitionTo(EscapeRoomState.puzzle);
  }

  /// パズル完了
  void completePuzzle() {
    _currentPuzzleId = null;
    transitionTo(EscapeRoomState.exploring);
  }

  /// 脱出成功
  void escapeSuccess() {
    transitionTo(EscapeRoomState.escaped);
  }

  /// 時間切れ
  void timeUp() {
    transitionTo(EscapeRoomState.timeUp);
  }

  /// アイテム使用開始
  void useItem() {
    transitionTo(EscapeRoomState.itemUsing);
  }

  /// 探索に戻る
  void returnToExploring() {
    transitionTo(EscapeRoomState.exploring);
  }

  /// ゲームクリア
  void clearGame() {
    transitionTo(EscapeRoomState.ending);
  }

  /// ゲームオーバー
  void gameOver() {
    transitionTo(EscapeRoomState.gameOver);
  }

  /// ゲームリセット
  void resetGame() {
    forceSetState(EscapeRoomState.initial);
  }

  /// 現在のゲーム段階
  bool get isGameActive => [
    EscapeRoomState.exploring,
    EscapeRoomState.inventory,
    EscapeRoomState.puzzle,
    EscapeRoomState.puzzleSolving,
    EscapeRoomState.itemUsing,
  ].contains(currentState);

  bool get isGameEnded => [
    EscapeRoomState.escaped,
    EscapeRoomState.timeUp,
    EscapeRoomState.ending,
    EscapeRoomState.gameOver,
  ].contains(currentState);
}