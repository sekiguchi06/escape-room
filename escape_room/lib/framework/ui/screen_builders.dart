import 'package:flame/components.dart';
import 'screen_config.dart';
import 'screen_builders/start_screen_builder.dart';
import 'screen_builders/menu_screen_builder.dart';
import 'screen_builders/playing_screen_builder.dart';
import 'screen_builders/pause_screen_builder.dart';
import 'screen_builders/game_over_screen_builder.dart';
import 'screen_builders/settings_screen_builder.dart';
import 'screen_builders/shop_screen_builder.dart';
import 'screen_builders/leaderboard_screen_builder.dart';

/// 個別ビルダーの再エクスポート
export 'screen_builders/start_screen_builder.dart';
export 'screen_builders/menu_screen_builder.dart';
export 'screen_builders/playing_screen_builder.dart';
export 'screen_builders/pause_screen_builder.dart';
export 'screen_builders/game_over_screen_builder.dart';
export 'screen_builders/settings_screen_builder.dart';
export 'screen_builders/shop_screen_builder.dart';
export 'screen_builders/leaderboard_screen_builder.dart';
export 'screen_builders/screen_builder_utils.dart';

/// 個別画面ビルダーファクトリー
///
/// 各画面タイプの生成ロジックを分離した個別ファイルからの統一アクセスポイント
class ScreenBuilders {
  /// スタート画面の生成
  static PositionComponent createStartScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return StartScreenBuilder.create(screenSize, config);
  }

  /// メニュー画面の生成
  static PositionComponent createMenuScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return MenuScreenBuilder.create(screenSize, config);
  }

  /// プレイ画面の生成
  static PositionComponent createPlayingScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return PlayingScreenBuilder.create(screenSize, config);
  }

  /// 一時停止画面の生成
  static PositionComponent createPauseScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return PauseScreenBuilder.create(screenSize, config);
  }

  /// ゲームオーバー画面の生成
  static PositionComponent createGameOverScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return GameOverScreenBuilder.create(screenSize, config);
  }

  /// 設定画面の生成
  static PositionComponent createSettingsScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return SettingsScreenBuilder.create(screenSize, config);
  }

  /// ショップ画面の生成
  static PositionComponent createShopScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return ShopScreenBuilder.create(screenSize, config);
  }

  /// リーダーボード画面の生成
  static PositionComponent createLeaderboardScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    return LeaderboardScreenBuilder.create(screenSize, config);
  }
}