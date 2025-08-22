import '../models/game_error_models.dart';

/// エラーリカバリー戦略
abstract class ErrorRecoveryStrategy {
  /// エラーから回復を試みる
  Future<bool> attemptRecovery(GameError error);

  /// この戦略が適用可能かチェック
  bool canHandle(GameError error);
}

/// ネットワークエラーリカバリー戦略
class NetworkErrorRecoveryStrategy implements ErrorRecoveryStrategy {
  final int maxRetries;
  final Duration retryDelay;
  int _retryCount = 0;

  NetworkErrorRecoveryStrategy({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  @override
  bool canHandle(GameError error) {
    return error.type == GameErrorType.network && _retryCount < maxRetries;
  }

  @override
  Future<bool> attemptRecovery(GameError error) async {
    if (!canHandle(error)) return false;

    _retryCount++;
    await Future.delayed(retryDelay);

    // ネットワーク再接続を試みる処理
    // 実際の実装では具体的な再接続ロジックを実装

    return true; // 簡易実装
  }

  void reset() {
    _retryCount = 0;
  }
}
