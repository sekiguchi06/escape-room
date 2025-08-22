import 'interaction_result.dart';

/// インタラクション可能オブジェクトのインターフェース
/// 🎯 目的: インタラクション機能の定義
abstract interface class InteractableInterface {
  /// インタラクション可能性判定
  bool canInteract();

  /// インタラクション実行
  InteractionResult performInteraction();
}
