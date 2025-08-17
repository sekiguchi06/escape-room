import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// ゲーム状態の基底クラス
/// すべてのゲーム状態はこのクラスを継承する
abstract class GameState {
  const GameState();
  /// 状態の名前（デバッグ・ログ用）
  String get name;
  
  /// 状態の説明（オプション）
  String get description => name;
  
  /// 状態データ（JSON形式）
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
  
  @override
  String toString() => name;
  
  @override
  bool operator ==(Object other) => other is GameState && other.name == name;
  
  @override
  int get hashCode => name.hashCode;
}

/// 状態遷移の定義
class StateTransition<T extends GameState> {
  final Type fromState;
  final Type toState;
  final bool Function(T current, T target)? condition;
  final void Function(T from, T to)? onTransition;
  
  const StateTransition({
    required this.fromState,
    required this.toState,
    this.condition,
    this.onTransition,
  });
  
  /// 遷移可能かチェック
  bool canTransition(T current, T target) {
    if (current.runtimeType != fromState || target.runtimeType != toState) {
      return false;
    }
    return condition?.call(current, target) ?? true;
  }
}

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

/// Provider統合用の状態管理クラス
class GameStateProvider<T extends GameState> extends ChangeNotifier {
  late GameStateMachine<T> _stateMachine;
  
  // メトリクス
  int _sessionCount = 0;
  int _totalStateChanges = 0;
  DateTime _sessionStartTime = DateTime.now();
  final Map<String, int> _stateVisitCounts = {};
  final List<StateTransitionRecord<T>> _transitionHistory = [];
  
  GameStateProvider(T initialState) {
    _stateMachine = GameStateMachine<T>(initialState);
    _setupListeners();
    _recordStateVisit(initialState);
  }
  
  /// 現在の状態
  T get currentState => _stateMachine.currentState;
  
  /// 状態マシン
  GameStateMachine<T> get stateMachine => _stateMachine;
  
  /// セッション数
  int get sessionCount => _sessionCount;
  
  /// 総状態変更数
  int get totalStateChanges => _totalStateChanges;
  
  /// セッション開始時刻
  DateTime get sessionStartTime => _sessionStartTime;
  
  /// 状態訪問回数
  Map<String, int> get stateVisitCounts => Map.unmodifiable(_stateVisitCounts);
  
  /// 遷移履歴
  List<StateTransitionRecord<T>> get transitionHistory => List.unmodifiable(_transitionHistory);
  
  void _setupListeners() {
    _stateMachine.addTransitionListener((from, to) {
      _totalStateChanges++;
      _recordStateVisit(to);
      _recordTransition(from, to);
      notifyListeners();
    });
  }
  
  /// 状態遷移を実行
  bool transitionTo(T newState) {
    final success = _stateMachine.transitionTo(newState);
    if (success) {
      _totalStateChanges++;
      _recordStateVisit(newState);
      _recordTransition(currentState, newState);
    }
    return success;
  }
  
  /// 状態遷移可能性チェック
  bool canTransitionTo(T newState) {
    return _stateMachine.canTransitionTo(newState);
  }
  
  /// 状態を変更（遷移ルールに従う）
  bool changeState(T newState) {
    final success = transitionTo(newState);
    if (success) {
      notifyListeners(); // Flutter公式Provider準拠
    }
    return success;
  }
  
  /// 強制的に状態を変更（遷移ルールを無視）
  /// テスト用途など、遷移ルールを無視して直接状態を設定したい場合に使用
  void forceStateChange(T newState) {
    _stateMachine.forceSetState(newState);
    _totalStateChanges++;
    _recordStateVisit(newState);
    notifyListeners(); // Flutter公式Provider準拠
  }

  /// 新しいセッション開始
  void startNewSession() {
    _sessionCount++;
    _sessionStartTime = DateTime.now();
    debugPrint('New session started: $_sessionCount');
  }
  
  /// セッション継続時間
  Duration get sessionDuration => DateTime.now().difference(_sessionStartTime);
  
  /// 状態訪問を記録
  void _recordStateVisit(T state) {
    final stateName = state.name;
    _stateVisitCounts[stateName] = (_stateVisitCounts[stateName] ?? 0) + 1;
  }
  
  /// 遷移を記録
  void _recordTransition(T from, T to) {
    final record = StateTransitionRecord<T>(
      from: from,
      to: to,
      timestamp: DateTime.now(),
    );
    _transitionHistory.add(record);
    
    // 履歴サイズ制限
    if (_transitionHistory.length > 1000) {
      _transitionHistory.removeAt(0);
    }
  }
  
  /// 状態統計を取得
  StateStatistics getStatistics() {
    return StateStatistics(
      currentState: currentState.name,
      sessionCount: _sessionCount,
      totalStateChanges: _totalStateChanges,
      sessionDuration: sessionDuration,
      stateVisitCounts: _stateVisitCounts,
      mostVisitedState: _getMostVisitedState(),
      averageStateTransitionsPerSession: _sessionCount > 0 ? _totalStateChanges / _sessionCount : 0.0,
    );
  }
  
  String? _getMostVisitedState() {
    if (_stateVisitCounts.isEmpty) return null;
    
    return _stateVisitCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentState': currentState.name,
      'sessionCount': _sessionCount,
      'totalStateChanges': _totalStateChanges,
      'sessionDuration': sessionDuration.inSeconds,
      'stateVisitCounts': _stateVisitCounts,
      'transitionHistorySize': _transitionHistory.length,
    };
  }
}

/// 状態遷移記録
class StateTransitionRecord<T extends GameState> {
  final T from;
  final T to;
  final DateTime timestamp;
  
  const StateTransitionRecord({
    required this.from,
    required this.to,
    required this.timestamp,
  });
  
  /// 遷移にかかった時間（次の遷移との間隔）
  Duration? durationTo(StateTransitionRecord<T> next) {
    return next.timestamp.difference(timestamp);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'from': from.name,
      'to': to.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}

/// 状態統計情報
class StateStatistics {
  final String currentState;
  final int sessionCount;
  final int totalStateChanges;
  final Duration sessionDuration;
  final Map<String, int> stateVisitCounts;
  final String? mostVisitedState;
  final double averageStateTransitionsPerSession;
  
  const StateStatistics({
    required this.currentState,
    required this.sessionCount,
    required this.totalStateChanges,
    required this.sessionDuration,
    required this.stateVisitCounts,
    required this.mostVisitedState,
    required this.averageStateTransitionsPerSession,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'currentState': currentState,
      'sessionCount': sessionCount,
      'totalStateChanges': totalStateChanges,
      'sessionDurationSeconds': sessionDuration.inSeconds,
      'stateVisitCounts': stateVisitCounts,
      'mostVisitedState': mostVisitedState,
      'averageStateTransitionsPerSession': averageStateTransitionsPerSession,
    };
  }
}

/// 状態ビルダー（UI構築用）
/// 注意: Flutter環境でのみ使用可能
/*
class StateBuilder<T extends GameState> extends StatelessWidget {
  final GameStateProvider<T> provider;
  final Widget Function(BuildContext context, T state) builder;
  final Widget Function(BuildContext context)? loading;
  
  const StateBuilder({
    super.key,
    required this.provider,
    required this.builder,
    this.loading,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return builder(context, provider.currentState);
      },
    );
  }
}
*/

/// 状態遷移アニメーション
/// 注意: Flutter環境でのみ使用可能
/*
class StateTransitionAnimator<T extends GameState> {
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation<double>> _animations = {};
  
  /// アニメーションを登録
  void registerAnimation(
    String transitionKey,
    AnimationController controller,
    Animation<double> animation,
  ) {
    _controllers[transitionKey] = controller;
    _animations[transitionKey] = animation;
  }
  
  /// 状態遷移時のアニメーション実行
  Future<void> animateTransition(T from, T to) async {
    final key = '${from.name}_to_${to.name}';
    final controller = _controllers[key];
    
    if (controller != null) {
      await controller.forward();
    }
  }
  
  /// リソース解放
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _animations.clear();
  }
}
*/

/// 脱出ゲーム専用状態
/// 移植ガイド準拠実装
enum EscapeRoomState implements GameState {
  exploring,    // 部屋探索中
  inventory,    // インベントリ確認中
  puzzle,       // パズル解答中
  escaped,      // 脱出成功
  timeUp;       // 時間切れ
  
  @override
  String get name => switch (this) {
    EscapeRoomState.exploring => 'exploring',
    EscapeRoomState.inventory => 'inventory', 
    EscapeRoomState.puzzle => 'puzzle',
    EscapeRoomState.escaped => 'escaped',
    EscapeRoomState.timeUp => 'timeUp',
  };
  
  @override
  String get description => switch (this) {
    EscapeRoomState.exploring => '部屋を探索中',
    EscapeRoomState.inventory => 'インベントリ確認中',
    EscapeRoomState.puzzle => 'パズル解答中', 
    EscapeRoomState.escaped => '脱出成功！',
    EscapeRoomState.timeUp => '時間切れ',
  };
  
  @override
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
}

/// 状態遷移ロジック拡張
/// 移植ガイド準拠実装・UI統合対応
class EscapeRoomStateProvider extends GameStateProvider<EscapeRoomState> {
  String? _currentPuzzleId;
  String? _selectedItemId;
  Map<String, dynamic> _gameData = {};
  
  // UI統合用コールバック
  void Function()? _onInventoryToggle;
  void Function(String puzzleId)? _onPuzzleStart;
  void Function()? _onPuzzleComplete;
  void Function()? _onEscapeSuccess;
  
  EscapeRoomStateProvider() : super(EscapeRoomState.exploring) {
    _setupEscapeRoomTransitions();
  }
  
  /// 現在のパズルID
  String? get currentPuzzleId => _currentPuzzleId;
  
  /// 選択中のアイテムID
  String? get selectedItemId => _selectedItemId;
  
  /// ゲームデータ
  Map<String, dynamic> get gameData => Map.unmodifiable(_gameData);
  
  /// UI統合コールバック設定
  void setUICallbacks({
    void Function()? onInventoryToggle,
    void Function(String puzzleId)? onPuzzleStart,
    void Function()? onPuzzleComplete,
    void Function()? onEscapeSuccess,
  }) {
    _onInventoryToggle = onInventoryToggle;
    _onPuzzleStart = onPuzzleStart;
    _onPuzzleComplete = onPuzzleComplete;
    _onEscapeSuccess = onEscapeSuccess;
  }
  
  /// 脱出ゲーム専用状態遷移を設定
  void _setupEscapeRoomTransitions() {
    stateMachine.defineTransitions([
      // exploring → inventory
      StateTransition<EscapeRoomState>(
        fromState: EscapeRoomState,
        toState: EscapeRoomState,
        condition: (from, to) => from == EscapeRoomState.exploring && to == EscapeRoomState.inventory,
        onTransition: (from, to) {
          debugPrint('🎒 Inventory opened');
          _onInventoryToggle?.call();
        },
      ),
      
      // inventory → exploring
      StateTransition<EscapeRoomState>(
        fromState: EscapeRoomState,
        toState: EscapeRoomState,
        condition: (from, to) => from == EscapeRoomState.inventory && to == EscapeRoomState.exploring,
        onTransition: (from, to) {
          debugPrint('🎒 Inventory closed');
          _onInventoryToggle?.call();
        },
      ),
      
      // exploring → puzzle
      StateTransition<EscapeRoomState>(
        fromState: EscapeRoomState,
        toState: EscapeRoomState,
        condition: (from, to) => from == EscapeRoomState.exploring && to == EscapeRoomState.puzzle,
        onTransition: (from, to) {
          debugPrint('🧩 Puzzle started: $_currentPuzzleId');
          if (_currentPuzzleId != null) {
            _onPuzzleStart?.call(_currentPuzzleId!);
          }
        },
      ),
      
      // puzzle → exploring
      StateTransition<EscapeRoomState>(
        fromState: EscapeRoomState,
        toState: EscapeRoomState,
        condition: (from, to) => from == EscapeRoomState.puzzle && to == EscapeRoomState.exploring,
        onTransition: (from, to) {
          debugPrint('🧩 Puzzle completed: $_currentPuzzleId');
          _onPuzzleComplete?.call();
          _currentPuzzleId = null;
        },
      ),
      
      // exploring → escaped
      StateTransition<EscapeRoomState>(
        fromState: EscapeRoomState,
        toState: EscapeRoomState,
        condition: (from, to) => from == EscapeRoomState.exploring && to == EscapeRoomState.escaped,
        onTransition: (from, to) {
          debugPrint('🎉 Escape success!');
          _onEscapeSuccess?.call();
        },
      ),
      
      // any → timeUp
      StateTransition<EscapeRoomState>(
        fromState: EscapeRoomState,
        toState: EscapeRoomState,
        condition: (from, to) => to == EscapeRoomState.timeUp,
        onTransition: (from, to) {
          debugPrint('⏰ Time up!');
        },
      ),
    ]);
  }
  
  /// インベントリ表示（UI統合対応）
  void showInventory() {
    if (canTransitionTo(EscapeRoomState.inventory)) {
      transitionTo(EscapeRoomState.inventory);
    } else {
      debugPrint('❌ Cannot show inventory from current state: ${currentState.name}');
    }
  }
  
  /// インベントリ非表示（UI統合対応）
  void hideInventory() {
    if (currentState == EscapeRoomState.inventory && 
        canTransitionTo(EscapeRoomState.exploring)) {
      transitionTo(EscapeRoomState.exploring);
    } else {
      debugPrint('❌ Cannot hide inventory from current state: ${currentState.name}');
    }
  }
  
  /// インベントリ切り替え（UI統合対応）
  void toggleInventory() {
    switch (currentState) {
      case EscapeRoomState.exploring:
        showInventory();
        break;
      case EscapeRoomState.inventory:
        hideInventory();
        break;
      default:
        debugPrint('❌ Cannot toggle inventory from state: ${currentState.name}');
    }
  }
  
  /// パズル開始（UI統合対応）
  void startPuzzle(String puzzleId) {
    if (currentState == EscapeRoomState.exploring && 
        canTransitionTo(EscapeRoomState.puzzle)) {
      _currentPuzzleId = puzzleId;
      transitionTo(EscapeRoomState.puzzle);
    } else {
      debugPrint('❌ Cannot start puzzle from current state: ${currentState.name}');
    }
  }
  
  /// パズル完了（UI統合対応）
  void completePuzzle() {
    if (currentState == EscapeRoomState.puzzle && 
        canTransitionTo(EscapeRoomState.exploring)) {
      transitionTo(EscapeRoomState.exploring);
    } else {
      debugPrint('❌ Cannot complete puzzle from current state: ${currentState.name}');
    }
  }
  
  /// パズルキャンセル（UI統合対応）
  void cancelPuzzle() {
    if (currentState == EscapeRoomState.puzzle) {
      debugPrint('🧩 Puzzle cancelled: $_currentPuzzleId');
      _currentPuzzleId = null;
      transitionTo(EscapeRoomState.exploring);
    }
  }
  
  /// アイテム選択（状態管理）
  void selectItem(String itemId) {
    _selectedItemId = itemId;
    debugPrint('🎁 Item selected: $itemId');
    notifyListeners(); // Observer Pattern通知
  }
  
  /// アイテム選択解除
  void deselectItem() {
    _selectedItemId = null;
    debugPrint('🎁 Item deselected');
    notifyListeners(); // Observer Pattern通知
  }
  
  /// ゲームデータ更新（パズル進行等）
  void updateGameData(String key, dynamic value) {
    _gameData[key] = value;
    debugPrint('💾 Game data updated: $key = $value');
    notifyListeners(); // Observer Pattern通知
  }
  
  /// 脱出成功
  void escapeSuccess() {
    if (canTransitionTo(EscapeRoomState.escaped)) {
      transitionTo(EscapeRoomState.escaped);
    } else {
      debugPrint('❌ Cannot escape from current state: ${currentState.name}');
    }
  }
  
  /// 時間切れ
  void timeUp() {
    if (canTransitionTo(EscapeRoomState.timeUp)) {
      transitionTo(EscapeRoomState.timeUp);
    }
  }
  
  /// 現在の状態が操作可能かチェック
  bool get canInteract => currentState == EscapeRoomState.exploring;
  
  /// インベントリが表示中かチェック
  bool get isInventoryVisible => currentState == EscapeRoomState.inventory;
  
  /// パズル中かチェック
  bool get isPuzzleActive => currentState == EscapeRoomState.puzzle;
  
  /// ゲーム終了状態かチェック
  bool get isGameEnded => currentState == EscapeRoomState.escaped || 
                         currentState == EscapeRoomState.timeUp;
  
  /// デバッグ情報取得（Observer Pattern状態確認）
  @override
  Map<String, dynamic> getDebugInfo() {
    final baseInfo = super.getDebugInfo();
    return {
      ...baseInfo,
      'currentPuzzleId': _currentPuzzleId,
      'selectedItemId': _selectedItemId,
      'gameDataSize': _gameData.length,
      'canInteract': canInteract,
      'isInventoryVisible': isInventoryVisible,
      'isPuzzleActive': isPuzzleActive,
      'isGameEnded': isGameEnded,
    };
  }
}