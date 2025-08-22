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
