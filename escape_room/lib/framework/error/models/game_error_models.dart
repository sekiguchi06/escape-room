/// ゲームエラーの種類
enum GameErrorType {
  /// ネットワーク関連エラー
  network,

  /// 広告読み込みエラー
  adLoad,

  /// 音声再生エラー
  audioPlayback,

  /// ゲームロジックエラー
  gameLogic,

  /// リソース読み込みエラー
  resourceLoad,

  /// 設定エラー
  configuration,

  /// 権限エラー
  permission,

  /// 不明なエラー
  unknown,
}

/// ゲームエラー情報
class GameError implements Exception {
  final GameErrorType type;
  final String message;
  final String? details;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  const GameError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
    required this.timestamp,
  });

  /// ユーザー向けメッセージ取得
  String get userMessage {
    switch (type) {
      case GameErrorType.network:
        return 'ネットワーク接続を確認してください';
      case GameErrorType.adLoad:
        return '広告の読み込みに失敗しました';
      case GameErrorType.audioPlayback:
        return '音声の再生に問題が発生しました';
      case GameErrorType.gameLogic:
        return 'ゲームでエラーが発生しました';
      case GameErrorType.resourceLoad:
        return 'データの読み込みに失敗しました';
      case GameErrorType.configuration:
        return '設定に問題があります';
      case GameErrorType.permission:
        return '必要な権限が不足しています';
      case GameErrorType.unknown:
        return '予期しないエラーが発生しました';
    }
  }

  /// 開発者向け詳細情報
  Map<String, dynamic> toDetailedMap() {
    return {
      'type': type.name,
      'message': message,
      'details': details,
      'userMessage': userMessage,
      'timestamp': timestamp.toIso8601String(),
      'originalError': originalError?.toString(),
      'stackTrace': stackTrace?.toString(),
    };
  }

  @override
  String toString() => 'GameError($type): $message';
}
