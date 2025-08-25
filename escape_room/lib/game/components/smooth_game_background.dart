import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../framework/ui/image_preloader.dart';
import 'game_background.dart';

/// スムーズなトランジション効果付きゲーム背景
/// フラッシュバック現象を防ぐため、画像切り替え時にクロスフェード効果を適用
class SmoothGameBackground extends StatefulWidget {
  final GameBackgroundConfig config;
  final double bottomReservedHeight;
  final Duration transitionDuration;

  const SmoothGameBackground({
    super.key,
    required this.config,
    this.bottomReservedHeight = 0.0,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SmoothGameBackground> createState() => _SmoothGameBackgroundState();
}

class _SmoothGameBackgroundState extends State<SmoothGameBackground>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  GameBackgroundConfig? _previousConfig;
  GameBackgroundConfig? _currentConfig;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _currentConfig = widget.config;
    _fadeController.value = 1.0; // 初期状態は完全表示
  }

  @override
  void didUpdateWidget(SmoothGameBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 設定が変更された場合、スムーズなトランジションを開始
    if (oldWidget.config.asset.path != widget.config.asset.path) {
      _startTransition(oldWidget.config, widget.config);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// スムーズなトランジションを開始
  void _startTransition(GameBackgroundConfig from, GameBackgroundConfig to) {
    setState(() {
      _previousConfig = from;
      _currentConfig = to;
    });

    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // プリロード完了を待機
    return ValueListenableBuilder<bool>(
      valueListenable: ImagePreloader().preloadComplete,
      builder: (context, isPreloaded, child) {
        if (!isPreloaded) {
          // プリロード中は黒画面
          return Container(color: Colors.black);
        }

        return _buildTransitionBackground();
      },
    );
  }

  /// トランジション効果付き背景を構築（黒ベース）
  Widget _buildTransitionBackground() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // 常に黒背景を維持
            Container(color: Colors.black),

            // 前の背景（黒へフェードアウト）
            if (_previousConfig != null)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - _fadeAnimation.value,
                    child: _buildBackgroundLayer(_previousConfig!, constraints),
                  );
                },
              ),

            // 現在の背景（黒からフェードイン）
            if (_currentConfig != null)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: _buildBackgroundLayer(_currentConfig!, constraints),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  /// 背景レイヤーを構築
  Widget _buildBackgroundLayer(
    GameBackgroundConfig config,
    BoxConstraints constraints,
  ) {
    return Stack(
      children: [
        // VTR風ぼかし背景レイヤー
        _buildBlurredBackground(config),

        // メイン画像レイヤー
        _buildMainImageLayer(config, constraints),
      ],
    );
  }

  /// VTR風ぼかし背景を構築
  Widget _buildBlurredBackground(GameBackgroundConfig config) {
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

  /// メイン画像レイヤーを構築
  Widget _buildMainImageLayer(
    GameBackgroundConfig config,
    BoxConstraints constraints,
  ) {
    final screenWidth = constraints.maxWidth;
    final availableHeight =
        constraints.maxHeight -
        config.topReservedHeight -
        widget.bottomReservedHeight;

    // メイン画像の最適サイズ計算
    final imageLayout = _calculateImageLayout(
      config,
      screenWidth,
      availableHeight,
    );

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
          borderRadius: BorderRadius.circular(8),
          child: Image(
            image: config.asset.provider(),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            // 重要: gaplessPlayback でフラッシュバックを防ぐ
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }

  /// 画像レイアウト計算
  ImageLayout _calculateImageLayout(
    GameBackgroundConfig config,
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
      // 高さに合わせて横幅を調整
      return ImageLayout(
        width: screenWidth,
        height: availableHeight,
        offsetX: 0,
        offsetY: 0,
      );
    }
  }
}

/// 高性能スムーズ背景（最適化版）
class OptimizedSmoothGameBackground extends StatefulWidget {
  final GameBackgroundConfig config;
  final double bottomReservedHeight;

  const OptimizedSmoothGameBackground({
    super.key,
    required this.config,
    this.bottomReservedHeight = 0.0,
  });

  @override
  State<OptimizedSmoothGameBackground> createState() =>
      _OptimizedSmoothGameBackgroundState();
}

class _OptimizedSmoothGameBackgroundState
    extends State<OptimizedSmoothGameBackground> {
  GameBackgroundConfig? _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.config;
  }

  @override
  void didUpdateWidget(OptimizedSmoothGameBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.asset.path != widget.config.asset.path) {
      setState(() {
        _currentConfig = widget.config;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ImagePreloader().preloadComplete,
      builder: (context, isPreloaded, child) {
        // プリロード未完了またはエラー時は安全な黒背景を表示
        if (!isPreloaded || _currentConfig == null) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
                ),
              ),
            ),
          );
        }

        // 黒ベースのトランジション（明るい点滅を防ぐ）
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return _buildBlackFadeTransition(child, animation);
          },
          child: _buildSafeBackground(),
        );
      },
    );
  }

  /// 黒ベースのフェードトランジション
  Widget _buildBlackFadeTransition(Widget child, Animation<double> animation) {
    return Stack(
      children: [
        // 常に黒背景を維持
        Container(color: Colors.black),
        // 画像をフェードイン（黒から画像へ）
        FadeTransition(opacity: animation, child: child),
      ],
    );
  }

  /// 安全な背景構築（エラー耐性）
  Widget _buildSafeBackground() {
    try {
      return ResponsiveGameBackground(
        key: ValueKey(_currentConfig!.asset.path),
        config: _currentConfig!,
        bottomReservedHeight: widget.bottomReservedHeight,
      );
    } catch (e) {
      // エラー時はフォールバック背景
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.white30,
            size: 48,
          ),
        ),
      );
    }
  }
}
