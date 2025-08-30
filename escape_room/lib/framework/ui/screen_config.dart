import 'package:flutter/material.dart';

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
