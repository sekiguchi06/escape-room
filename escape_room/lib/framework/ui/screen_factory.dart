import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'flame_ui_builder.dart';
import 'ui_system.dart';

/// Flame公式Component準拠の画面ファクトリー
///
/// カジュアルゲーム量産時の標準画面レイアウトを自動生成。
/// Template Methodパターンでゲーム固有部分を抽象化。
///
/// 使用例:
/// ```dart
/// final startScreen = ScreenFactory.createScreen(
///   type: GameScreenType.start,
///   screenSize: game.size,
///   config: ScreenConfig(
///     title: 'My Game',
///     backgroundColor: Colors.blue.withValues(alpha: 0.3),
///     customActions: {'start': () => game.navigateTo('playing')},
///   ),
/// );
/// ```
class ScreenFactory {
  /// 画面作成メイン関数
  ///
  /// GameScreenType に基づいて標準レイアウトの画面を生成。
  /// Flame公式のPositionComponent構造に準拠。
  static PositionComponent createScreen({
    required String type,
    required Vector2 screenSize,
    required ScreenConfig config,
  }) {
    switch (type) {
      case 'start':
        return _createStartScreen(screenSize, config);
      case 'menu':
        return _createMenuScreen(screenSize, config);
      case 'playing':
        return _createPlayingScreen(screenSize, config);
      case 'pause':
        return _createPauseScreen(screenSize, config);
      case 'gameOver':
        return _createGameOverScreen(screenSize, config);
      case 'settings':
        return _createSettingsScreen(screenSize, config);
      case 'shop':
        return _createShopScreen(screenSize, config);
      case 'leaderboard':
        return _createLeaderboardScreen(screenSize, config);
      default:
        return _createMenuScreen(screenSize, config);
    }
  }

  /// スタート画面の生成
  static PositionComponent _createStartScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: config.title ?? 'Game Title',
        screenSize: screenSize,
        yOffset: -100,
      ),
    );

    // サブタイトル（オプション）
    if (config.subtitle != null) {
      screen.add(
        FlameUIBuilder.subtitleText(
          text: config.subtitle!,
          screenSize: screenSize,
          yOffset: -60,
        ),
      );
    }

    // START GAME ボタン
    screen.add(
      FlameUIBuilder.primaryButton(
        text: 'START GAME',
        onPressed: config.customActions?['start'] ?? () {},
        screenSize: screenSize,
      ),
    );

    // Settings ボタン
    if (config.showSettings) {
      screen.add(
        FlameUIBuilder.settingsButton(
          screenSize,
          customOnPressed: config.customActions?['settings'],
        ),
      );
    }

    return screen;
  }

  /// メニュー画面の生成
  static PositionComponent _createMenuScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: config.title ?? 'Menu',
        screenSize: screenSize,
        yOffset: -120,
      ),
    );

    // メニューボタン群（縦配置）
    final menuItems = config.menuItems ?? ['Start', 'Settings', 'Exit'];
    for (int i = 0; i < menuItems.length; i++) {
      final yPos = -20.0 + (i * 60.0);
      screen.add(
        FlameUIBuilder.primaryButton(
          text: menuItems[i],
          onPressed: config.customActions?[menuItems[i].toLowerCase()] ?? () {},
          screenSize: screenSize,
          customPosition: Vector2(
            screenSize.x / 2 - 100,
            screenSize.y / 2 + yPos,
          ),
        ),
      );
    }

    return screen;
  }

  /// プレイ画面の生成
  static PositionComponent _createPlayingScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 背景（ゲームプレイ用・透明度低め）
    screen.add(
      _createBackground(
        screenSize,
        config.copyWith(
          backgroundColor: config.backgroundColor?.withValues(alpha: 0.1),
        ),
      ),
    );

    // 注意: Score/Time表示はGameTemplate.createGameUI()で管理するためここでは作成しない
    // 二重表示防止のFlame公式パターン

    // 一時停止ボタン（右上、スコア下）
    if (config.showPauseButton) {
      screen.add(
        FlameUIBuilder.iconButton(
          text: '⏸',
          onPressed: config.customActions?['pause'] ?? () {},
          position: Vector2(screenSize.x - 30, 80),
        ),
      );
    }

    // プログレスバー（下部）
    if (config.showProgressBar) {
      screen.add(
        FlameUIBuilder.progressBar(
          screenSize: screenSize,
          progress: config.progressValue ?? 0.0,
        ),
      );
    }

    return screen;
  }

  /// 一時停止画面の生成
  static PositionComponent _createPauseScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 半透明背景（オーバーレイ）
    screen.add(
      FlameUIBuilder.background(screenSize: screenSize, color: Colors.black54),
    );

    // パネル
    final pausePanel = FlameUIBuilder.panel(
      screenSize: screenSize,
      children: [
        FlameUIBuilder.titleText(
          text: 'PAUSED',
          screenSize: Vector2(screenSize.x * 0.8, screenSize.y * 0.6),
          yOffset: -80,
        ),
        FlameUIBuilder.primaryButton(
          text: 'Resume',
          onPressed: config.customActions?['resume'] ?? () {},
          screenSize: Vector2(screenSize.x * 0.8, screenSize.y * 0.6),
          customPosition: Vector2(
            screenSize.x * 0.4 - 100,
            screenSize.y * 0.3 - 10,
          ),
        ),
        FlameUIBuilder.secondaryButton(
          text: 'Menu',
          onPressed: config.customActions?['menu'] ?? () {},
          screenSize: Vector2(screenSize.x * 0.8, screenSize.y * 0.6),
          customPosition: Vector2(
            screenSize.x * 0.4 - 75,
            screenSize.y * 0.3 + 50,
          ),
        ),
      ],
    );

    screen.add(pausePanel);

    return screen;
  }

  /// ゲームオーバー画面の生成
  static PositionComponent _createGameOverScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // GAME OVER タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: config.title ?? 'GAME OVER',
        screenSize: screenSize,
        yOffset: -120,
        styleId: 'xlarge',
      ),
    );

    // 最終スコア表示
    if (config.finalScore != null) {
      screen.add(
        FlameUIBuilder.subtitleText(
          text: 'Final Score: ${config.finalScore}',
          screenSize: screenSize,
          yOffset: -70,
        ),
      );
    }

    // ハイスコア表示
    if (config.highScore != null) {
      screen.add(
        FlameUIBuilder.subtitleText(
          text: 'High Score: ${config.highScore}',
          screenSize: screenSize,
          yOffset: -40,
          styleId: 'medium',
        ),
      );
    }

    // PLAY AGAIN ボタン
    screen.add(
      FlameUIBuilder.primaryButton(
        text: 'PLAY AGAIN',
        onPressed: config.customActions?['restart'] ?? () {},
        screenSize: screenSize,
      ),
    );

    // MENU ボタン
    screen.add(
      FlameUIBuilder.secondaryButton(
        text: 'MENU',
        onPressed: config.customActions?['menu'] ?? () {},
        screenSize: screenSize,
      ),
    );

    // Settings ボタン
    if (config.showSettings) {
      screen.add(
        FlameUIBuilder.settingsButton(
          screenSize,
          customOnPressed: config.customActions?['settings'],
        ),
      );
    }

    return screen;
  }

  /// 設定画面の生成
  static PositionComponent _createSettingsScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: 'SETTINGS',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // 設定項目リスト（簡易実装）
    final settingsItems =
        config.settingsItems ?? ['Sound', 'Music', 'Difficulty'];
    for (int i = 0; i < settingsItems.length; i++) {
      final yPos = -50.0 + (i * 50.0);
      screen.add(
        FlameUIBuilder.secondaryButton(
          text: settingsItems[i],
          onPressed:
              config.customActions?[settingsItems[i].toLowerCase()] ?? () {},
          screenSize: screenSize,
          customPosition: Vector2(
            screenSize.x / 2 - 75,
            screenSize.y / 2 + yPos,
          ),
        ),
      );
    }

    // 戻るボタン
    screen.add(
      FlameUIBuilder.backButton(
        screenSize,
        customOnPressed: config.customActions?['back'],
      ),
    );

    return screen;
  }

  /// ショップ画面の生成
  static PositionComponent _createShopScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: 'SHOP',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // コイン表示（右上）
    screen.add(
      FlameUIBuilder.scoreText(
        text: config.coinText ?? 'Coins: 100',
        screenSize: screenSize,
      ),
    );

    // 商品リスト（グリッド配置・簡易実装）
    final shopItems =
        config.shopItems ?? ['Power Up', 'Extra Life', 'Coin Pack'];
    for (int i = 0; i < shopItems.length; i++) {
      final xPos = (i % 2) * 200.0 - 100.0;
      final yPos = (i ~/ 2) * 80.0 - 50.0;
      screen.add(
        FlameUIBuilder.secondaryButton(
          text: shopItems[i],
          onPressed:
              config
                  .customActions?['buy_${shopItems[i].toLowerCase().replaceAll(' ', '_')}'] ??
              () {},
          screenSize: screenSize,
          customSize: Vector2(180, 60),
          customPosition: Vector2(
            screenSize.x / 2 + xPos,
            screenSize.y / 2 + yPos,
          ),
        ),
      );
    }

    // 戻るボタン
    screen.add(
      FlameUIBuilder.backButton(
        screenSize,
        customOnPressed: config.customActions?['back'],
      ),
    );

    return screen;
  }

  /// リーダーボード画面の生成
  static PositionComponent _createLeaderboardScreen(
    Vector2 screenSize,
    ScreenConfig config,
  ) {
    final screen = PositionComponent();

    // 背景
    screen.add(_createBackground(screenSize, config));

    // タイトル
    screen.add(
      FlameUIBuilder.titleText(
        text: 'LEADERBOARD',
        screenSize: screenSize,
        yOffset: -150,
      ),
    );

    // スコアリスト（簡易実装）
    final scores =
        config.leaderboardData ??
        [
          {'name': 'Player 1', 'score': 1000},
          {'name': 'Player 2', 'score': 800},
          {'name': 'Player 3', 'score': 600},
        ];

    for (int i = 0; i < scores.length && i < 5; i++) {
      final data = scores[i];
      final yPos = -80.0 + (i * 40.0);
      screen.add(
        TextUIComponent(
          text: '${i + 1}. ${data['name']} - ${data['score']}',
          styleId: 'medium',
          position: Vector2(screenSize.x / 2, screenSize.y / 2 + yPos),
        )..anchor = Anchor.center,
      );
    }

    // 戻るボタン
    screen.add(
      FlameUIBuilder.backButton(
        screenSize,
        customOnPressed: config.customActions?['back'],
      ),
    );

    return screen;
  }

  /// 背景生成（共通処理）
  static Component _createBackground(Vector2 screenSize, ScreenConfig config) {
    if (config.gradientColors != null && config.gradientColors!.length > 1) {
      return FlameUIBuilder.gradientBackground(
        screenSize: screenSize,
        colors: config.gradientColors!,
      );
    } else {
      return FlameUIBuilder.background(
        screenSize: screenSize,
        color: config.backgroundColor ?? Colors.indigo.withValues(alpha: 0.3),
      );
    }
  }
}

/// 画面設定クラス
///
/// 各画面の表示内容とアクションをカスタマイズ。
/// 不要な項目は null で無効化可能。
class ScreenConfig {
  /// 画面タイトル
  final String? title;

  /// サブタイトル
  final String? subtitle;

  /// 背景色
  final Color? backgroundColor;

  /// グラデーション背景色
  final List<Color>? gradientColors;

  /// カスタムアクション（ボタンのコールバック）
  final Map<String, VoidCallback>? customActions;

  /// 設定ボタンを表示するか
  final bool showSettings;

  /// 一時停止ボタンを表示するか
  final bool showPauseButton;

  /// プログレスバーを表示するか
  final bool showProgressBar;

  /// プログレスバーの値（0.0-1.0）
  final double? progressValue;

  /// スコアテキスト
  final String? scoreText;

  /// タイマーテキスト
  final String? timerText;

  /// 最終スコア（ゲームオーバー画面用）
  final int? finalScore;

  /// ハイスコア（ゲームオーバー画面用）
  final int? highScore;

  /// コインテキスト（ショップ画面用）
  final String? coinText;

  /// メニュー項目リスト
  final List<String>? menuItems;

  /// 設定項目リスト
  final List<String>? settingsItems;

  /// ショップ商品リスト
  final List<String>? shopItems;

  /// リーダーボードデータ
  final List<Map<String, dynamic>>? leaderboardData;

  const ScreenConfig({
    this.title,
    this.subtitle,
    this.backgroundColor,
    this.gradientColors,
    this.customActions,
    this.showSettings = true,
    this.showPauseButton = true,
    this.showProgressBar = false,
    this.progressValue,
    this.scoreText,
    this.timerText,
    this.finalScore,
    this.highScore,
    this.coinText,
    this.menuItems,
    this.settingsItems,
    this.shopItems,
    this.leaderboardData,
  });

  /// コピーコンストラクタ
  ScreenConfig copyWith({
    String? title,
    String? subtitle,
    Color? backgroundColor,
    List<Color>? gradientColors,
    Map<String, VoidCallback>? customActions,
    bool? showSettings,
    bool? showPauseButton,
    bool? showProgressBar,
    double? progressValue,
    String? scoreText,
    String? timerText,
    int? finalScore,
    int? highScore,
    String? coinText,
    List<String>? menuItems,
    List<String>? settingsItems,
    List<String>? shopItems,
    List<Map<String, dynamic>>? leaderboardData,
  }) {
    return ScreenConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientColors: gradientColors ?? this.gradientColors,
      customActions: customActions ?? this.customActions,
      showSettings: showSettings ?? this.showSettings,
      showPauseButton: showPauseButton ?? this.showPauseButton,
      showProgressBar: showProgressBar ?? this.showProgressBar,
      progressValue: progressValue ?? this.progressValue,
      scoreText: scoreText ?? this.scoreText,
      timerText: timerText ?? this.timerText,
      finalScore: finalScore ?? this.finalScore,
      highScore: highScore ?? this.highScore,
      coinText: coinText ?? this.coinText,
      menuItems: menuItems ?? this.menuItems,
      settingsItems: settingsItems ?? this.settingsItems,
      shopItems: shopItems ?? this.shopItems,
      leaderboardData: leaderboardData ?? this.leaderboardData,
    );
  }
}
