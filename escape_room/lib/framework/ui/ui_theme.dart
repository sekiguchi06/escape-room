import 'package:flutter/material.dart';

/// テーマの設定値を管理するクラス（既存互換）
abstract class UITheme {
  /// テキストスタイルを取得（既存互換）
  TextStyle getTextStyle(String styleId);

  /// 色を取得
  Color getColor(String key);

  /// サイズ・寸法を取得（既存互換）
  double getDimension(String dimensionId);

  /// フォントサイズを取得
  double getFontSize(String key);

  /// フォント重みを取得（既存互換）
  FontWeight getFontWeight(String weightId);

  /// マージン/パディングを取得
  double getSpacing(String key);

  /// アニメーション設定を取得（既存互換）
  Duration getAnimationDuration(String animationId);

  /// Flutter公式ThemeDataに変換
  ThemeData toThemeData();
}