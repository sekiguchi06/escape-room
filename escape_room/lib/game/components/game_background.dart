import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../gen/assets.gen.dart';

/// ゲーム背景コンポーネント
/// VTR風の拡大ぼかし背景 + メイン画像の複合表示
class GameBackground extends StatelessWidget {
  final AssetGenImage asset;
  final double topReservedHeight;
  final double aspectRatio;

  const GameBackground({
    super.key,
    required this.asset,
    this.topReservedHeight = 84.0, // メニューバー領域
    this.aspectRatio = 5 / 8, // デフォルト5:8比率
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight - topReservedHeight;

        // 理想的なメイン画像サイズを計算
        final idealImageWidth = screenWidth;
        final idealImageHeight = idealImageWidth / aspectRatio;

        // メイン画像が利用可能高さに収まるかチェック
        final fitsInHeight = idealImageHeight <= availableHeight;

        // 実際のメイン画像サイズを決定（横幅は常に100%）
        final double mainImageWidth = screenWidth; // 常に100%
        final double mainImageHeight;

        if (fitsInHeight) {
          // 横幅基準でサイズ決定
          mainImageHeight = idealImageHeight;
        } else {
          // 高さ基準でサイズ決定
          mainImageHeight = availableHeight;
        }

        // 余白の計算（横幅は常に100%なので横余白なし）
        final verticalMargin = (availableHeight - mainImageHeight) / 2;

        // 余白があるかどうか判定（縦方向のみ）
        final hasMargins = verticalMargin > 0;

        return Stack(
          children: [
            // VTR風拡大ぼかし背景（余白がある場合のみ）
            if (hasMargins) _buildBlurredBackground(),

            // メイン画像（横幅100%）
            Positioned(
              top: topReservedHeight + verticalMargin,
              left: 0,
              child: SizedBox(
                width: mainImageWidth,
                height: mainImageHeight,
                child: asset.image(fit: BoxFit.cover),
              ),
            ),
          ],
        );
      },
    );
  }

  /// VTR風拡大ぼかし背景を構築
  Widget _buildBlurredBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          // 拡大された背景画像
          Transform.scale(
            scale: 1.2, // 20%拡大
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: asset.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // ぼかしエフェクト
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3), // 軽い暗化
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ゲーム背景設定
class GameBackgroundConfig {
  final AssetGenImage asset;
  final double aspectRatio;
  final double topReservedHeight;
  final double blurSigma;
  final double blurOpacity;
  final double scaleRatio;

  const GameBackgroundConfig({
    required this.asset,
    this.aspectRatio = 5 / 8,
    this.topReservedHeight = 84.0,
    this.blurSigma = 15.0,
    this.blurOpacity = 0.3,
    this.scaleRatio = 1.2,
  });

  /// 設定のコピー作成
  GameBackgroundConfig copyWith({
    AssetGenImage? asset,
    double? aspectRatio,
    double? topReservedHeight,
    double? blurSigma,
    double? blurOpacity,
    double? scaleRatio,
  }) {
    return GameBackgroundConfig(
      asset: asset ?? this.asset,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      topReservedHeight: topReservedHeight ?? this.topReservedHeight,
      blurSigma: blurSigma ?? this.blurSigma,
      blurOpacity: blurOpacity ?? this.blurOpacity,
      scaleRatio: scaleRatio ?? this.scaleRatio,
    );
  }

  /// 脱出ゲーム用デフォルト設定
  static final escapeRoom = GameBackgroundConfig(
    asset: Assets.images.escapeRoomBg,
    aspectRatio: 5 / 8,
    topReservedHeight: 84.0,
  );

  /// 脱出ゲーム用夜モード設定（照明オフ）
  static final escapeRoomNight = GameBackgroundConfig(
    asset: Assets.images.escapeRoomBgNight,
    aspectRatio: 5 / 8,
    topReservedHeight: 84.0,
  );
}

/// レスポンシブ背景コンポーネント（高度版）
class ResponsiveGameBackground extends StatelessWidget {
  final GameBackgroundConfig config;
  final double bottomReservedHeight; // 下部余白（インベントリ領域）

  const ResponsiveGameBackground({
    super.key,
    required this.config,
    this.bottomReservedHeight = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // VTR風ぼかし背景レイヤー
            _buildBackgroundLayer(constraints),

            // メイン画像レイヤー
            _buildMainImageLayer(constraints),
          ],
        );
      },
    );
  }

  /// 背景レイヤーの構築
  Widget _buildBackgroundLayer(BoxConstraints constraints) {
    return Positioned.fill(
      child: Stack(
        children: [
          // 拡大画像
          Transform.scale(
            scale: config.scaleRatio,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: config.asset.provider(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // ぼかしとオーバーレイ
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: config.blurSigma,
                sigmaY: config.blurSigma,
              ),
              child: Container(
                color: Colors.black.withValues(alpha: config.blurOpacity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// メイン画像レイヤーの構築
  Widget _buildMainImageLayer(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final availableHeight =
        constraints.maxHeight - config.topReservedHeight - bottomReservedHeight;

    // メイン画像の最適サイズ計算
    final imageLayout = _calculateImageLayout(screenWidth, availableHeight);

    return Positioned(
      top: config.topReservedHeight + imageLayout.offsetY,
      left: imageLayout.offsetX,
      child: Container(
        width: imageLayout.width,
        height: imageLayout.height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8), // 軽い角丸
          child: config.asset.image(
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }

  /// 画像レイアウト計算
  ImageLayout _calculateImageLayout(
    double screenWidth,
    double availableHeight,
  ) {
    // 常に横幅100%を使用
    final widthBasedHeight = screenWidth / config.aspectRatio;

    if (widthBasedHeight <= availableHeight) {
      // 横幅100%でフィット
      return ImageLayout(
        width: screenWidth,
        height: widthBasedHeight,
        offsetX: 0,
        offsetY: (availableHeight - widthBasedHeight) / 2,
      );
    } else {
      // 高さに合わせて横幅を調整（ぼかし領域は縦方向のみ）
      return ImageLayout(
        width: screenWidth, // 横幅は常に100%
        height: availableHeight,
        offsetX: 0,
        offsetY: 0,
      );
    }
  }
}

/// 画像レイアウト情報
class ImageLayout {
  final double width;
  final double height;
  final double offsetX;
  final double offsetY;

  const ImageLayout({
    required this.width,
    required this.height,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  String toString() {
    return 'ImageLayout(${width.toInt()}x${height.toInt()} at (${offsetX.toInt()}, ${offsetY.toInt()}))';
  }
}
