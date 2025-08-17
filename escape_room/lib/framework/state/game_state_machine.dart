import 'package:flutter/foundation.dart';
import 'game_state_base.dart';

/// 汎用状態マシン
class GameStateMachine<T extends GameState> {
  T _currentState;
  final List<StateTransition<T>> _transitions = [];
  final List<void Function(T from, T to)> _transitionListeners = [];
  final List<void Function(T state)> _stateChangeListeners = [];
  
  GameStateMachine(this._currentState);
  
  /// 現在の状態を取得
  T get currentState => _currentState;
  
  /// 状態遷移を定義
  void defineTransition(StateTransition<T> transition) {
    _transitions.add(transition);
  }
  
  /// 複数の状態遷移を一括定義
  void defineTransitions(List<StateTransition<T>> transitions) {
    _transitions.addAll(transitions);
  }
  
  /// 状態遷移が可能かチェック
  bool canTransitionTo(T newState) {
    return _transitions.any((transition) => 
      transition.canTransition(_currentState, newState)
    );
  }
  
  /// 状態遷移を実行
  bool transitionTo(T newState) {
    if (!canTransitionTo(newState)) {
      debugPrint('Invalid transition: ${_currentState.name} -> ${newState.name}');
      return false;
    }
    
    final oldState = _currentState;
    
    // 遷移前の処理
    final transition = _transitions.firstWhere(
      (t) => t.canTransition(_currentState, newState),
    );
    
    // 状態変更
    _currentState = newState;
    
    // 遷移後の処理
    transition.onTransition?.call(oldState, newState);
    
    // リスナー通知
    for (final listener in _transitionListeners) {
      listener(oldState, newState);
    }
    for (final listener in _stateChangeListeners) {
      listener(newState);
    }
    
    debugPrint('State transition: ${oldState.name} -> ${newState.name}');
    return true;
  }
  
  /// 強制的に状態を設定（遷移チェックなし）
  void forceSetState(T newState) {
    // final oldState = _currentState;
    _currentState = newState;
    
    for (final listener in _stateChangeListeners) {
      listener(newState);
    }
    
    // debugPrint('Force state change: ${oldState.name} -> ${newState.name}');
  }
  
  /// 遷移リスナーを追加
  void addTransitionListener(void Function(T from, T to) listener) {
    _transitionListeners.add(listener);
  }
  
  /// 状態変更リスナーを追加
  void addStateChangeListener(void Function(T state) listener) {
    _stateChangeListeners.add(listener);
  }
  
  /// リスナーを削除
  void removeTransitionListener(void Function(T from, T to) listener) {
    _transitionListeners.remove(listener);
  }
  
  void removeStateChangeListener(void Function(T state) listener) {
    _stateChangeListeners.remove(listener);
  }
  
  /// 定義された遷移一覧を取得
  List<StateTransition<T>> getTransitions() {
    return List.unmodifiable(_transitions);
  }
  
  /// 現在の状態から遷移可能な状態一覧を取得
  List<Type> getAvailableTransitions() {
    return _transitions
        .where((t) => t.fromState == _currentState.runtimeType)
        .map((t) => t.toState)
        .toList();
  }
}