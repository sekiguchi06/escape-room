/// インタラクション結果データクラス
/// 🎯 目的: インタラクションの実行結果を格納
class InteractionResult {
  final bool success;
  final String message;
  final List<String> itemsToAdd;
  final bool shouldActivate;
  
  const InteractionResult({
    required this.success,
    this.message = '',
    this.itemsToAdd = const [],
    this.shouldActivate = false,
  });
  
  /// 成功結果
  factory InteractionResult.success({
    String message = '',
    List<String> itemsToAdd = const [],
    bool shouldActivate = false,
  }) {
    return InteractionResult(
      success: true,
      message: message,
      itemsToAdd: itemsToAdd,
      shouldActivate: shouldActivate,
    );
  }
  
  /// 失敗結果
  factory InteractionResult.failure(String message) {
    return InteractionResult(
      success: false,
      message: message,
    );
  }
}