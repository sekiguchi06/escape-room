import 'game_services_models.dart';
import 'game_services_configuration.dart';

/// Flutter公式準拠統計情報サービス
///
/// Game Center/Google Play Gamesの統計情報機能
class GameServicesStatisticsService {
  final GameServicesConfiguration _config;

  /// Flutter公式推奨: コンストラクタで設定指定
  GameServicesStatisticsService({GameServicesConfiguration? config})
      : _config = config ?? const GameServicesConfiguration();

  /// 統計情報取得
  Map<String, dynamic> getStatistics({
    required bool isInitialized,
    required bool isSignedIn,
    required String? playerId,
    required String? displayName,
    required Map<String, int> scoreCache,
  }) {
    return <String, dynamic>{
      'initialized': isInitialized,
      'signedIn': isSignedIn,
      'playerId': playerId,
      'displayName': displayName,
      'cachedScores': Map<String, int>.from(scoreCache),
      'leaderboardCount': _config.leaderboardIds.length,
      'achievementCount': _config.achievementIds.length,
    };
  }

  /// デバッグ情報取得
  ///
  /// Flutter公式準拠: 詳細なデバッグ情報提供
  Map<String, dynamic> getDebugInfo({
    required bool isInitialized,
    required bool isSignedIn,
    required GamePlayer? currentPlayer,
    required Map<String, int> scoreCache,
  }) {
    return <String, dynamic>{
      'flutter_official_compliant': true, // Flutter公式準拠であることを明示
      'package': 'games_services', // 使用パッケージ
      'initialized': isInitialized,
      'debug_mode': _config.debugMode,
      'auto_signin_enabled': _config.autoSignInEnabled,
      'signed_in': isSignedIn,
      'current_player': currentPlayer?.toJson(),
      'leaderboard_ids': _config.leaderboardIds,
      'achievement_ids': _config.achievementIds,
      'score_cache': scoreCache,
      'retry_count': _config.signInRetryCount,
      'timeout_seconds': _config.networkTimeoutSeconds,
    };
  }
}