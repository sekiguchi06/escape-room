/// ゲームサービス設定クラス
class GameServicesConfiguration {
  /// デバッグモード
  final bool debugMode;
  
  /// 自動サインイン有効
  final bool autoSignInEnabled;
  
  /// リーダーボードID一覧
  final Map<String, String> leaderboardIds;
  
  /// 実績ID一覧
  final Map<String, String> achievementIds;
  
  /// サインイン失敗時のリトライ回数
  final int signInRetryCount;
  
  /// ネットワークタイムアウト(秒)
  final int networkTimeoutSeconds;
  
  const GameServicesConfiguration({
    this.debugMode = false,
    this.autoSignInEnabled = true,
    this.leaderboardIds = const {},
    this.achievementIds = const {},
    this.signInRetryCount = 3,
    this.networkTimeoutSeconds = 30,
  });
  
  GameServicesConfiguration copyWith({
    bool? debugMode,
    bool? autoSignInEnabled,
    Map<String, String>? leaderboardIds,
    Map<String, String>? achievementIds,
    int? signInRetryCount,
    int? networkTimeoutSeconds,
  }) {
    return GameServicesConfiguration(
      debugMode: debugMode ?? this.debugMode,
      autoSignInEnabled: autoSignInEnabled ?? this.autoSignInEnabled,
      leaderboardIds: leaderboardIds ?? this.leaderboardIds,
      achievementIds: achievementIds ?? this.achievementIds,
      signInRetryCount: signInRetryCount ?? this.signInRetryCount,
      networkTimeoutSeconds: networkTimeoutSeconds ?? this.networkTimeoutSeconds,
    );
  }
}