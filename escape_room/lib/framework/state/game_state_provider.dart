import 'package:flutter/widgets.dart';
import 'game_state_base.dart';
import 'game_state_machine.dart';
import 'state_models.dart';

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
      'availableTransitions': getAvailableTransitions()
          .map((t) => t.toString())
          .toList(),
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