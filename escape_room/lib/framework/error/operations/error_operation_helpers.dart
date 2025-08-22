import '../models/game_error_models.dart';
import '../core/flutter_game_error_handler.dart';

/// エラー操作ヘルパークラス
class ErrorOperationHelpers {
  final FlutterGameErrorHandler _errorHandler;

  ErrorOperationHelpers(this._errorHandler);

  /// ネットワークエラー処理
  Future<T?> handleNetworkOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await operation();
    } catch (e, stack) {
      final error = GameError(
        type: GameErrorType.network,
        message: operationName ?? 'Network operation failed',
        details: e.toString(),
        originalError: e,
        stackTrace: stack,
        timestamp: DateTime.now(),
      );
      await _errorHandler.handleError(error);
      return null;
    }
  }

  /// 広告エラー処理
  Future<bool> handleAdOperation(
    Future<void> Function() operation, {
    required String adType,
  }) async {
    try {
      await operation();
      return true;
    } catch (e, stack) {
      final error = GameError(
        type: GameErrorType.adLoad,
        message: 'Failed to load $adType ad',
        details: e.toString(),
        originalError: e,
        stackTrace: stack,
        timestamp: DateTime.now(),
      );
      await _errorHandler.handleError(error);
      return false;
    }
  }

  /// 音声エラー処理
  Future<bool> handleAudioOperation(
    Future<void> Function() operation, {
    required String audioType,
  }) async {
    try {
      await operation();
      return true;
    } catch (e, stack) {
      final error = GameError(
        type: GameErrorType.audioPlayback,
        message: 'Failed to play $audioType',
        details: e.toString(),
        originalError: e,
        stackTrace: stack,
        timestamp: DateTime.now(),
      );
      await _errorHandler.handleError(error);
      return false;
    }
  }
}
