/// ゲームサービス結果の種類
enum GameServiceResult {
  success,
  failure,
  cancelled,
  notSupported,
  notSignedIn,
  networkError,
  permissionDenied,
}

/// リーダーボード操作結果
class LeaderboardResult {
  final GameServiceResult result;
  final String? message;
  final String? leaderboardId;
  
  const LeaderboardResult({
    required this.result,
    this.message,
    this.leaderboardId,
  });
  
  bool get isSuccess => result == GameServiceResult.success;
  
  @override
  String toString() => 'LeaderboardResult(result: $result, message: $message)';
}

/// 実績操作結果  
class AchievementResult {
  final GameServiceResult result;
  final String? message;
  final String? achievementId;
  
  const AchievementResult({
    required this.result,
    this.message,
    this.achievementId,
  });
  
  bool get isSuccess => result == GameServiceResult.success;
  
  @override
  String toString() => 'AchievementResult(result: $result, message: $message)';
}

/// ゲームプレイヤー情報
class GamePlayer {
  final String? id;
  final String? playerId;
  final String? displayName;
  final String? avatar;
  final String? avatarUrl;
  final bool isAuthenticated;
  final bool isSignedIn;
  final Map<String, dynamic> additionalInfo;
  
  const GamePlayer({
    this.id,
    this.playerId,
    this.displayName,
    this.avatar,
    this.avatarUrl,
    this.isAuthenticated = false,
    this.isSignedIn = false,
    this.additionalInfo = const {},
  });
  
  @override
  String toString() => 'GamePlayer(id: ${id ?? playerId}, name: $displayName, authenticated: ${isAuthenticated || isSignedIn})';
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'displayName': displayName,
      'avatar': avatar,
      'avatarUrl': avatarUrl,
      'isAuthenticated': isAuthenticated,
      'isSignedIn': isSignedIn,
      'additionalInfo': additionalInfo,
    };
  }
}