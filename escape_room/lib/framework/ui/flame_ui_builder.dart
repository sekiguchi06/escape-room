import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'ui_system.dart';

/// Flame公式Component準拠のUI部品ファクトリー
///
/// カジュアルゲーム量産時の標準UI部品を提供します。
/// Flutter ThemeData準拠で一貫性のあるUI設計を実現。
///
/// 使用例:
/// ```dart
/// // 主要アクションボタン
/// final startButton = FlameUIBuilder.primaryButton(
///   text: 'START GAME',
///   onPressed: () => game.navigateTo('playing'),
///   screenSize: screenSize,
/// );
///
/// // 設定ボタン（右上配置）
/// final settingsButton = FlameUIBuilder.settingsButton(screenSize);
/// ```
class FlameUIBuilder {
  /// 主要アクションボタン（画面中央下）
  ///
  /// カジュアルゲームの標準レイアウトに従った配置とサイズ。
  /// Flame公式のButtonUIComponentを使用。
  static ButtonUIComponent primaryButton({
    required String text,
    required VoidCallback onPressed,
    required Vector2 screenSize,
    Vector2? customSize,
    Vector2? customPosition,
  }) {
    final size = customSize ?? Vector2(200, 50);
    final position =
        customPosition ??
        Vector2(
          screenSize.x / 2 - size.x / 2, // 中央配置
          screenSize.y / 2 + 20, // 中央より少し下
        );

    return ButtonUIComponent(
      text: text,
      colorId: 'primary',
      position: position,
      size: size,
      onPressed: onPressed,
    )..anchor = Anchor.topLeft;
  }

  /// セカンダリーボタン（サブアクション用）
  static ButtonUIComponent secondaryButton({
    required String text,
    required VoidCallback onPressed,
    required Vector2 screenSize,
    Vector2? customSize,
    Vector2? customPosition,
  }) {
    final size = customSize ?? Vector2(150, 40);
    final position =
        customPosition ??
        Vector2(screenSize.x / 2 - size.x / 2, screenSize.y / 2 + 80);

    return ButtonUIComponent(
      text: text,
      colorId: 'secondary',
      position: position,
      size: size,
      onPressed: onPressed,
    )..anchor = Anchor.topLeft;
  }

  /// 設定ボタン（右上配置）
  ///
  /// 標準的な設定ボタンレイアウト。
  /// router.pushNamed('settings')の呼び出しを自動化。
  static ButtonUIComponent settingsButton(
    Vector2 screenSize, {
    VoidCallback? customOnPressed,
  }) {
    return ButtonUIComponent(
      text: 'Settings',
      colorId: 'secondary',
      position: UILayoutManager.topRight(screenSize, Vector2(120, 40), 20),
      size: Vector2(120, 40),
      onPressed:
          customOnPressed ??
          () {
            // デフォルト動作：設定画面への遷移
            // ゲームインスタンスの取得は呼び出し元で処理
          },
    )..anchor = Anchor.topLeft;
  }

  /// メニューボタン（左上配置）
  static ButtonUIComponent menuButton(
    Vector2 screenSize, {
    String text = 'Menu',
    VoidCallback? customOnPressed,
  }) {
    return ButtonUIComponent(
      text: text,
      colorId: 'secondary',
      position: UILayoutManager.topLeft(screenSize, Vector2(100, 40), 20),
      size: Vector2(100, 40),
      onPressed:
          customOnPressed ??
          () {
            // デフォルト動作：メニュー画面への遷移
          },
    )..anchor = Anchor.topLeft;
  }

  /// 戻るボタン（左下配置）
  static ButtonUIComponent backButton(
    Vector2 screenSize, {
    String text = 'Back',
    VoidCallback? customOnPressed,
  }) {
    return ButtonUIComponent(
      text: text,
      colorId: 'secondary',
      position: Vector2(20, screenSize.y - 60),
      size: Vector2(100, 40),
      onPressed:
          customOnPressed ??
          () {
            // デフォルト動作：前画面への戻り
          },
    )..anchor = Anchor.topLeft;
  }

  /// タイトルテキスト（画面上部中央）
  ///
  /// ゲームタイトルや画面名表示用の大型テキスト。
  /// Flutter ThemeData準拠のスタイル適用。
  static TextUIComponent titleText({
    required String text,
    required Vector2 screenSize,
    double yOffset = -80,
    String styleId = 'xlarge',
  }) {
    return TextUIComponent(
      text: text,
      styleId: styleId,
      position: Vector2(screenSize.x / 2, screenSize.y / 2 + yOffset),
    )..anchor = Anchor.center;
  }

  /// サブタイトルテキスト（タイトル下）
  static TextUIComponent subtitleText({
    required String text,
    required Vector2 screenSize,
    double yOffset = -40,
    String styleId = 'large',
  }) {
    return TextUIComponent(
      text: text,
      styleId: styleId,
      position: Vector2(screenSize.x / 2, screenSize.y / 2 + yOffset),
    )..anchor = Anchor.center;
  }

  /// スコアテキスト（右上配置）
  static TextUIComponent scoreText({
    required String text,
    required Vector2 screenSize,
    String styleId = 'medium',
  }) {
    // Flame公式: 十分な余白で安全な配置
    return TextUIComponent(
      text: text,
      styleId: styleId,
      position: Vector2(screenSize.x - 60, 60),
    )..anchor = Anchor.topRight;
  }

  /// タイマーテキスト（左上配置）
  static TextUIComponent timerText({
    required String text,
    required Vector2 screenSize,
    String styleId = 'medium',
  }) {
    // Flame公式: 十分な余白で安全な配置
    return TextUIComponent(
      text: text,
      styleId: styleId,
      position: Vector2(60, 60),
    )..anchor = Anchor.topLeft;
  }

  /// 背景コンポーネント（視覚確認用）
  ///
  /// PositionComponent準拠の背景実装。
  /// タップイベントは通過させる設計。
  static RectangleComponent background({
    required Vector2 screenSize,
    required Color color,
    int priority = -100,
  }) {
    return RectangleComponent(
      position: Vector2.zero(),
      size: screenSize,
      paint: Paint()..color = color,
    )..priority = priority;
  }

  /// グラデーション背景
  static RectangleComponent gradientBackground({
    required Vector2 screenSize,
    required List<Color> colors,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    int priority = -100,
  }) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: begin,
        end: end,
      ).createShader(Rect.fromLTWH(0, 0, screenSize.x, screenSize.y));

    return RectangleComponent(
      position: Vector2.zero(),
      size: screenSize,
      paint: paint,
    )..priority = priority;
  }

  /// プログレスバー（水平）
  static Component progressBar({
    required Vector2 screenSize,
    required double progress, // 0.0-1.0
    Vector2? customSize,
    Vector2? customPosition,
    Color backgroundColor = Colors.grey,
    Color foregroundColor = Colors.blue,
  }) {
    final size = customSize ?? Vector2(screenSize.x * 0.8, 20);
    final position =
        customPosition ??
        Vector2(screenSize.x / 2 - size.x / 2, screenSize.y - 80);

    final container = PositionComponent(position: position, size: size);

    // 背景
    container.add(
      RectangleComponent(size: size, paint: Paint()..color = backgroundColor),
    );

    // プログレス
    container.add(
      RectangleComponent(
        size: Vector2(size.x * progress.clamp(0.0, 1.0), size.y),
        paint: Paint()..color = foregroundColor,
      ),
    );

    return container;
  }

  /// 円形プログレス（中央配置）
  static CircleComponent circularProgress({
    required Vector2 screenSize,
    required double progress, // 0.0-1.0
    double radius = 50,
    Vector2? customPosition,
    Color backgroundColor = Colors.grey,
    Color foregroundColor = Colors.blue,
  }) {
    final position =
        customPosition ?? Vector2(screenSize.x / 2, screenSize.y / 2);

    // TODO: 円形プログレスの実装
    // FlameのCircleComponentを使用した実装
    return CircleComponent(
      radius: radius,
      position: position,
      paint: Paint()..color = foregroundColor,
    )..anchor = Anchor.center;
  }

  /// アイコンボタン（小型）
  static ButtonUIComponent iconButton({
    required String text,
    required VoidCallback onPressed,
    required Vector2 position,
    double size = 40,
    String colorId = 'secondary',
  }) {
    return ButtonUIComponent(
      text: text,
      colorId: colorId,
      position: position,
      size: Vector2.all(size),
      onPressed: onPressed,
    )..anchor = Anchor.center;
  }

  /// パネル（情報表示用）
  static PositionComponent panel({
    required Vector2 screenSize,
    required List<Component> children,
    Vector2? customSize,
    Vector2? customPosition,
    Color backgroundColor = Colors.black54,
    double cornerRadius = 10,
  }) {
    final size = customSize ?? Vector2(screenSize.x * 0.8, screenSize.y * 0.6);
    final position =
        customPosition ??
        Vector2(screenSize.x / 2 - size.x / 2, screenSize.y / 2 - size.y / 2);

    final panel = PositionComponent(position: position, size: size);

    // 背景（角丸は簡易実装）
    panel.add(
      RectangleComponent(size: size, paint: Paint()..color = backgroundColor),
    );

    // 子要素追加
    for (final child in children) {
      panel.add(child);
    }

    return panel;
  }

  /// 単色背景コンポーネント
  static PositionComponent solidColorBackground({
    required Vector2 screenSize,
    required Color color,
    int priority = -100,
  }) {
    return RectangleComponent(
      position: Vector2.zero(),
      size: screenSize,
      paint: Paint()..color = color,
    )..priority = priority;
  }

  /// デフォルトゲーム背景
  static PositionComponent defaultGameBackground({
    required Vector2 screenSize,
    int priority = -100,
  }) {
    return solidColorBackground(
      screenSize: screenSize,
      color: const Color(0xFF1E1E1E),
      priority: priority,
    );
  }

  /// 一時停止ボタン（ゲーム画面用）
  static ButtonUIComponent pauseButton(
    Vector2 screenSize, {
    VoidCallback? customOnPressed,
  }) {
    return ButtonUIComponent(
      text: 'Pause',
      colorId: 'secondary',
      position: UILayoutManager.topRight(screenSize, Vector2(80, 40), 20),
      size: Vector2(80, 40),
      onPressed:
          customOnPressed ??
          () {
            // デフォルト動作：ゲーム一時停止
          },
    )..anchor = Anchor.topLeft;
  }

  /// 設定項目（設定画面用）
  static ButtonUIComponent settingsItem({
    required String text,
    required VoidCallback onPressed,
    required Vector2 position,
    Vector2? customSize,
  }) {
    final size = customSize ?? Vector2(200, 50);

    return ButtonUIComponent(
      text: text,
      colorId: 'secondary',
      position: position,
      size: size,
      onPressed: onPressed,
    )..anchor = Anchor.topLeft;
  }
}
