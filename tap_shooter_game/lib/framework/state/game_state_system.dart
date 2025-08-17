// ゲーム状態システム統合ファイル
// 分割されたコンポーネントを再エクスポート

export 'game_state_base.dart';
export 'game_state_machine.dart';
export 'game_progress_system.dart';
export 'game_autosave_system.dart';
export 'game_event_triggers.dart';

// レガシーサポートのため、他の部分も必要に応じて別ファイルに分割可能
import 'package:flutter/widgets.dart';
import 'game_state_base.dart';
import 'game_state_machine.dart';

/// Provider統合用の状態管理クラス
class GameStateProvider<T extends GameState> extends ChangeNotifier {
  late GameStateMachine<T> _stateMachine;
  final List<StateTransitionRecord<T>> _transitionHistory = [];
  int _maxHistorySize = 100;
  
  GameStateProvider(T initialState) {
    _stateMachine = GameStateMachine<T>(initialState);
    _stateMachine.addTransitionListener(_onTransition);
    _stateMachine.addStateChangeListener(_onStateChange);
  }
  
  /// 現在の状態
  T get currentState => _stateMachine.currentState;
  
  /// 遷移履歴
  List<StateTransitionRecord<T>> get transitionHistory =>
      List.unmodifiable(_transitionHistory);
  
  /// 状態遷移
  bool transitionTo(T newState) {
    return _stateMachine.transitionTo(newState);
  }
  
  /// 遷移可能性チェック
  bool canTransitionTo(T newState) {
    return _stateMachine.canTransitionTo(newState);
  }
  
  /// 遷移定義を追加
  void defineTransition(StateTransition<T> transition) {
    _stateMachine.defineTransition(transition);
  }
  
  /// 複数遷移を一括定義
  void defineTransitions(List<StateTransition<T>> transitions) {
    _stateMachine.defineTransitions(transitions);
  }
  
  /// 強制状態変更
  void forceSetState(T newState) {
    _stateMachine.forceSetState(newState);
    notifyListeners();
  }
  
  /// 履歴サイズ設定
  void setMaxHistorySize(int size) {
    _maxHistorySize = size;
    while (_transitionHistory.length > _maxHistorySize) {
      _transitionHistory.removeAt(0);
    }
  }
  
  /// 履歴クリア
  void clearHistory() {
    _transitionHistory.clear();
  }
  
  /// 利用可能な遷移取得
  List<Type> getAvailableTransitions() {
    return _stateMachine.getAvailableTransitions();
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentState': currentState.name,
      'transitionHistorySize': _transitionHistory.length,
      'availableTransitions': getAvailableTransitions().map((t) => t.toString()).toList(),
      'maxHistorySize': _maxHistorySize,
    };
  }
  
  /// 状態マシンアクセス（下位互換のため）
  GameStateMachine<T> get stateMachine => _stateMachine;
  
  /// 状態変更（下位互換のため）
  bool changeState(T newState) {
    return transitionTo(newState);
  }
  
  /// 強制状態変更（下位互換のため）
  void forceStateChange(T newState) {
    forceSetState(newState);
  }
  
  /// 統計取得（下位互換のため）
  StateStatistics getStatistics() {
    final stats = StateStatistics();
    for (final record in _transitionHistory) {
      stats.recordStateEntry(record.toState);
      stats.recordStateExit(record.fromState);
    }
    return stats;
  }
  
  void _onTransition(T from, T to) {
    final record = StateTransitionRecord<T>(
      fromState: from,
      toState: to,
      timestamp: DateTime.now(),
    );
    
    _transitionHistory.add(record);
    
    if (_transitionHistory.length > _maxHistorySize) {
      _transitionHistory.removeAt(0);
    }
    
    notifyListeners();
  }
  
  void _onStateChange(T state) {
    notifyListeners();
  }
  
  @override
  void dispose() {
    _stateMachine.removeTransitionListener(_onTransition);
    _stateMachine.removeStateChangeListener(_onStateChange);
    super.dispose();
  }
}

/// 状態遷移記録
class StateTransitionRecord<T extends GameState> {
  final T fromState;
  final T toState;
  final DateTime timestamp;
  final String? metadata;
  
  const StateTransitionRecord({
    required this.fromState,
    required this.toState,
    required this.timestamp,
    this.metadata,
  });
  
  /// 遷移にかかった時間を計算する際の基準時刻
  Duration getDurationSince(DateTime baseTime) {
    return timestamp.difference(baseTime);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'from': fromState.name,
      'to': toState.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// 状態統計
class StateStatistics {
  final Map<String, int> _stateVisitCounts = {};
  final Map<String, Duration> _stateDurations = {};
  final Map<String, DateTime> _stateEntryTimes = {};
  int _totalStateChanges = 0;
  
  void recordStateEntry(GameState state) {
    final stateName = state.name;
    _stateVisitCounts[stateName] = (_stateVisitCounts[stateName] ?? 0) + 1;
    _stateEntryTimes[stateName] = DateTime.now();
    _totalStateChanges++;
  }
  
  void recordStateExit(GameState state) {
    final stateName = state.name;
    final entryTime = _stateEntryTimes[stateName];
    if (entryTime != null) {
      final duration = DateTime.now().difference(entryTime);
      _stateDurations[stateName] = (_stateDurations[stateName] ?? Duration.zero) + duration;
    }
  }
  
  int getVisitCount(String stateName) => _stateVisitCounts[stateName] ?? 0;
  Duration getTotalDuration(String stateName) => _stateDurations[stateName] ?? Duration.zero;
  
  /// 総状態変更回数（下位互換のため）
  int get totalStateChanges => _totalStateChanges;
  
  /// セッション数（下位互換のため）
  int get sessionCount => _stateVisitCounts.values.fold(0, (sum, count) => sum + count);
  
  /// セッション継続時間（下位互換のため）
  Duration get sessionDuration => _stateDurations.values.fold(Duration.zero, (sum, duration) => sum + duration);
  
  /// 最も訪問された状態（下位互換のため）
  String get mostVisitedState {
    if (_stateVisitCounts.isEmpty) return '';
    return _stateVisitCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// セッション平均遷移数（下位互換のため）
  double get averageStateTransitionsPerSession {
    if (sessionCount == 0) return 0.0;
    return totalStateChanges / sessionCount;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'visitCounts': _stateVisitCounts,
      'totalDurations': _stateDurations.map((k, v) => MapEntry(k, v.inMilliseconds)),
      'totalStateChanges': _totalStateChanges,
      'sessionCount': sessionCount,
      'sessionDuration': sessionDuration.inMilliseconds,
      'mostVisitedState': mostVisitedState,
    };
  }
}

/// 状態ベースのWidget構築
class StateBuilder<T extends GameState> extends StatelessWidget {
  final GameStateProvider<T> provider;
  final Widget Function(BuildContext context, T state) builder;
  
  const StateBuilder({
    super.key,
    required this.provider,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, child) {
        return builder(context, provider.currentState);
      },
    );
  }
}

/// 状態遷移アニメーション
class StateTransitionAnimator<T extends GameState> {
  final Duration animationDuration;
  final Map<Type, Widget Function()> stateWidgets;
  
  StateTransitionAnimator({
    this.animationDuration = const Duration(milliseconds: 300),
    required this.stateWidgets,
  });
  
  Widget buildTransition(T fromState, T toState, Animation<double> animation) {
    final fromWidget = stateWidgets[fromState.runtimeType]?.call();
    final toWidget = stateWidgets[toState.runtimeType]?.call();
    
    if (fromWidget == null || toWidget == null) {
      return toWidget ?? const SizedBox.shrink();
    }
    
    return Stack(
      children: [
        FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(animation),
          child: fromWidget,
        ),
        FadeTransition(
          opacity: animation,
          child: toWidget,
        ),
      ],
    );
  }
}

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