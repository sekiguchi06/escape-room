import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/game_state_system.dart';

/// 脱出ゲーム専用状態 (Riverpod版)
enum EscapeRoomState implements GameState {
  exploring, // 部屋探索中
  inventory, // インベントリ確認中
  puzzle, // パズル解答中
  escaped, // 脱出成功
  timeUp; // 時間切れ

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

/// 脱出ゲーム状態データクラス
class EscapeRoomStateData {
  final EscapeRoomState currentState;
  final String? currentPuzzleId;
  final String? selectedItemId;
  final Map<String, dynamic> gameData;
  final int sessionCount;
  final int totalStateChanges;
  final DateTime sessionStartTime;

  const EscapeRoomStateData({
    required this.currentState,
    this.currentPuzzleId,
    this.selectedItemId,
    this.gameData = const {},
    this.sessionCount = 0,
    this.totalStateChanges = 0,
    required this.sessionStartTime,
  });

  EscapeRoomStateData copyWith({
    EscapeRoomState? currentState,
    String? currentPuzzleId,
    String? selectedItemId,
    Map<String, dynamic>? gameData,
    int? sessionCount,
    int? totalStateChanges,
    DateTime? sessionStartTime,
  }) {
    return EscapeRoomStateData(
      currentState: currentState ?? this.currentState,
      currentPuzzleId: currentPuzzleId ?? this.currentPuzzleId,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      gameData: gameData ?? this.gameData,
      sessionCount: sessionCount ?? this.sessionCount,
      totalStateChanges: totalStateChanges ?? this.totalStateChanges,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
    );
  }

  // clearSelectedItem用のヘルパー
  EscapeRoomStateData clearSelectedItem() {
    return copyWith(selectedItemId: null);
  }

  // clearCurrentPuzzle用のヘルパー
  EscapeRoomStateData clearCurrentPuzzle() {
    return copyWith(currentPuzzleId: null);
  }
}

/// 脱出ゲーム用Riverpod状態管理
class EscapeRoomStateNotifier extends StateNotifier<EscapeRoomStateData> {
  // UI統合用コールバック
  void Function()? _onInventoryToggle;
  void Function(String puzzleId)? _onPuzzleStart;
  void Function()? _onPuzzleComplete;
  void Function()? _onEscapeSuccess;

  EscapeRoomStateNotifier()
    : super(
        EscapeRoomStateData(
          currentState: EscapeRoomState.exploring,
          sessionStartTime: DateTime.now(),
        ),
      );

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

  /// インベントリ表示（UI統合対応）
  void showInventory() {
    if (_canTransitionTo(EscapeRoomState.inventory)) {
      _transitionTo(EscapeRoomState.inventory);
      _onInventoryToggle?.call();
    } else {
      debugPrint(
        '❌ Cannot show inventory from current state: ${state.currentState.name}',
      );
    }
  }

  /// インベントリ非表示（UI統合対応）
  void hideInventory() {
    if (state.currentState == EscapeRoomState.inventory &&
        _canTransitionTo(EscapeRoomState.exploring)) {
      _transitionTo(EscapeRoomState.exploring);
      _onInventoryToggle?.call();
    } else {
      debugPrint(
        '❌ Cannot hide inventory from current state: ${state.currentState.name}',
      );
    }
  }

  /// インベントリ切り替え（UI統合対応）
  void toggleInventory() {
    switch (state.currentState) {
      case EscapeRoomState.exploring:
        showInventory();
        break;
      case EscapeRoomState.inventory:
        hideInventory();
        break;
      default:
        debugPrint(
          '❌ Cannot toggle inventory from state: ${state.currentState.name}',
        );
    }
  }

  /// パズル開始（UI統合対応）
  void startPuzzle(String puzzleId) {
    if (state.currentState == EscapeRoomState.exploring &&
        _canTransitionTo(EscapeRoomState.puzzle)) {
      state = state.copyWith(currentPuzzleId: puzzleId);
      _transitionTo(EscapeRoomState.puzzle);
      _onPuzzleStart?.call(puzzleId);
    } else {
      debugPrint(
        '❌ Cannot start puzzle from current state: ${state.currentState.name}',
      );
    }
  }

  /// パズル完了（UI統合対応）
  void completePuzzle() {
    if (state.currentState == EscapeRoomState.puzzle &&
        _canTransitionTo(EscapeRoomState.exploring)) {
      _transitionTo(EscapeRoomState.exploring);
      state = state.clearCurrentPuzzle();
      _onPuzzleComplete?.call();
    } else {
      debugPrint(
        '❌ Cannot complete puzzle from current state: ${state.currentState.name}',
      );
    }
  }

  /// パズルキャンセル（UI統合対応）
  void cancelPuzzle() {
    if (state.currentState == EscapeRoomState.puzzle) {
      debugPrint('🧩 Puzzle cancelled: ${state.currentPuzzleId}');
      state = state.clearCurrentPuzzle();
      _transitionTo(EscapeRoomState.exploring);
    }
  }

  /// アイテム選択（状態管理）
  void selectItem(String itemId) {
    state = state.copyWith(selectedItemId: itemId);
    debugPrint('🎁 Item selected: $itemId');
  }

  /// アイテム選択解除
  void deselectItem() {
    state = state.clearSelectedItem();
    debugPrint('🎁 Item deselected');
  }

  /// ゲームデータ更新（パズル進行等）
  void updateGameData(String key, dynamic value) {
    final newGameData = Map<String, dynamic>.from(state.gameData);
    newGameData[key] = value;
    state = state.copyWith(gameData: newGameData);
    debugPrint('💾 Game data updated: $key = $value');
  }

  /// 脱出成功
  void escapeSuccess() {
    if (_canTransitionTo(EscapeRoomState.escaped)) {
      _transitionTo(EscapeRoomState.escaped);
      _onEscapeSuccess?.call();
    } else {
      debugPrint(
        '❌ Cannot escape from current state: ${state.currentState.name}',
      );
    }
  }

  /// 時間切れ
  void timeUp() {
    if (_canTransitionTo(EscapeRoomState.timeUp)) {
      _transitionTo(EscapeRoomState.timeUp);
    }
  }

  /// ゲームをリセットして探索状態に戻す
  void resetToExploring() {
    state = EscapeRoomStateData(
      currentState: EscapeRoomState.exploring,
      sessionStartTime: DateTime.now(),
      sessionCount: state.sessionCount + 1,
    );
    debugPrint(
      '🔄 Game reset to exploring state (session ${state.sessionCount})',
    );
  }

  /// 状態遷移可能性チェック
  bool _canTransitionTo(EscapeRoomState newState) {
    final current = state.currentState;

    // exploring → inventory
    if (current == EscapeRoomState.exploring &&
        newState == EscapeRoomState.inventory) {
      return true;
    }

    // inventory → exploring
    if (current == EscapeRoomState.inventory &&
        newState == EscapeRoomState.exploring) {
      return true;
    }

    // exploring → puzzle
    if (current == EscapeRoomState.exploring &&
        newState == EscapeRoomState.puzzle) {
      return true;
    }

    // puzzle → exploring
    if (current == EscapeRoomState.puzzle &&
        newState == EscapeRoomState.exploring) {
      return true;
    }

    // exploring → escaped
    if (current == EscapeRoomState.exploring &&
        newState == EscapeRoomState.escaped) {
      return true;
    }

    // any → timeUp
    if (newState == EscapeRoomState.timeUp) {
      return true;
    }

    return false;
  }

  /// 状態遷移を実行
  void _transitionTo(EscapeRoomState newState) {
    if (!_canTransitionTo(newState)) {
      debugPrint(
        'Invalid transition: ${state.currentState.name} -> ${newState.name}',
      );
      return;
    }

    final oldState = state.currentState;

    // 状態変更
    state = state.copyWith(
      currentState: newState,
      totalStateChanges: state.totalStateChanges + 1,
    );

    // 遷移ログ
    _logTransition(oldState, newState);
  }

  /// 遷移ログ
  void _logTransition(EscapeRoomState from, EscapeRoomState to) {
    switch ((from, to)) {
      case (EscapeRoomState.exploring, EscapeRoomState.inventory):
        debugPrint('🎒 Inventory opened');
      case (EscapeRoomState.inventory, EscapeRoomState.exploring):
        debugPrint('🎒 Inventory closed');
      case (EscapeRoomState.exploring, EscapeRoomState.puzzle):
        debugPrint('🧩 Puzzle started: ${state.currentPuzzleId}');
      case (EscapeRoomState.puzzle, EscapeRoomState.exploring):
        debugPrint('🧩 Puzzle completed: ${state.currentPuzzleId}');
      case (EscapeRoomState.exploring, EscapeRoomState.escaped):
        debugPrint('🎉 Escape success!');
      case (_, EscapeRoomState.timeUp):
        debugPrint('⏰ Time up!');
      default:
        debugPrint('State transition: ${from.name} -> ${to.name}');
    }

    debugPrint('State transition: ${from.name} -> ${to.name}');
  }

  /// 現在の状態が操作可能かチェック
  bool get canInteract => state.currentState == EscapeRoomState.exploring;

  /// インベントリが表示中かチェック
  bool get isInventoryVisible =>
      state.currentState == EscapeRoomState.inventory;

  /// パズル中かチェック
  bool get isPuzzleActive => state.currentState == EscapeRoomState.puzzle;

  /// ゲーム終了状態かチェック
  bool get isGameEnded =>
      state.currentState == EscapeRoomState.escaped ||
      state.currentState == EscapeRoomState.timeUp;

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentState': state.currentState.name,
      'currentPuzzleId': state.currentPuzzleId,
      'selectedItemId': state.selectedItemId,
      'gameDataSize': state.gameData.length,
      'sessionCount': state.sessionCount,
      'totalStateChanges': state.totalStateChanges,
      'canInteract': canInteract,
      'isInventoryVisible': isInventoryVisible,
      'isPuzzleActive': isPuzzleActive,
      'isGameEnded': isGameEnded,
    };
  }
}

/// 脱出ゲーム状態プロバイダー
final escapeRoomStateProvider =
    StateNotifierProvider<EscapeRoomStateNotifier, EscapeRoomStateData>(
      (ref) => EscapeRoomStateNotifier(),
    );
