import '../core/interaction_result.dart';

/// インタラクション戦略の基底インターフェース
/// 🎯 目的: 異なるインタラクション行動の抽象化
abstract interface class InteractionStrategy {
  /// インタラクション可能性判定
  bool canInteract();
  
  /// インタラクション実行
  InteractionResult execute();
  
  /// 戦略名取得
  String get strategyName;
}