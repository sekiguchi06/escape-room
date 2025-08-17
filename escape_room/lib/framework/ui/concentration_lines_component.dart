import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// 集中線エフェクト用CustomPainterComponent
/// マンガ風の集中線演出を提供
class ConcentrationLinesComponent extends Component {
  final Vector2 center;
  final double maxRadius;
  final int lineCount;
  final Color lineColor;
  final double maxLineWidth;
  final double minLineWidth;
  final double animationDuration;
  
  late List<ConcentrationLine> _lines;
  late double _animationProgress;
  late EffectController _animationController;
  bool _isAnimating = false;
  
  ConcentrationLinesComponent({
    required this.center,
    this.maxRadius = 300.0,
    this.lineCount = 24,
    this.lineColor = Colors.black,
    this.maxLineWidth = 4.0,
    this.minLineWidth = 1.0,
    this.animationDuration = 2.0,
  });
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    _initializeLines();
    _animationProgress = 0.0;
    _animationController = LinearEffectController(animationDuration);
  }
  
  /// 集中線の初期化
  void _initializeLines() {
    _lines = [];
    final random = Random();
    
    for (int i = 0; i < lineCount; i++) {
      final angle = (i / lineCount) * 2 * pi;
      final startRadius = 50.0 + random.nextDouble() * 50.0;
      final endRadius = maxRadius * (0.8 + random.nextDouble() * 0.2);
      final width = minLineWidth + random.nextDouble() * (maxLineWidth - minLineWidth);
      
      _lines.add(ConcentrationLine(
        angle: angle,
        startRadius: startRadius,
        endRadius: endRadius,
        width: width,
        opacity: 0.7 + random.nextDouble() * 0.3,
      ));
    }
  }
  
  /// アニメーション開始
  void startAnimation() {
    if (_isAnimating) return;
    
    _isAnimating = true;
    _animationProgress = 0.0;
    
    // 回転とフェードインのアニメーション
    add(
      RotateEffect.by(
        pi / 4, // 45度回転
        _animationController,
        onComplete: () {
          // フェードアウト開始
          add(
            OpacityEffect.fadeOut(
              LinearEffectController(0.5),
              onComplete: () {
                _isAnimating = false;
                removeFromParent();
              },
            ),
          );
        },
      ),
    );
    
    // スケールアニメーション
    add(
      ScaleEffect.by(
        Vector2.all(1.5),
        _animationController,
      ),
    );
  }
  
  @override
  void render(Canvas canvas) {
    if (_lines.isEmpty) return;
    
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // 各集中線を描画
    for (final line in _lines) {
      paint.strokeWidth = line.width;
      paint.color = lineColor.withValues(alpha: line.opacity);
      
      final startX = center.x + cos(line.angle) * line.startRadius;
      final startY = center.y + sin(line.angle) * line.startRadius;
      final endX = center.x + cos(line.angle) * line.endRadius;
      final endY = center.y + sin(line.angle) * line.endRadius;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_isAnimating) {
      // アニメーションプログレスの更新
      _animationProgress += dt / animationDuration;
      _animationProgress = _animationProgress.clamp(0.0, 1.0);
      
      // 集中線の動的変更（脈動効果）
      final pulseEffect = sin(_animationProgress * pi * 4) * 0.1 + 1.0;
      for (final line in _lines) {
        line.currentOpacity = line.opacity * pulseEffect;
      }
    }
  }
}

/// 個別の集中線データクラス
class ConcentrationLine {
  final double angle;
  final double startRadius;
  final double endRadius;
  final double width;
  final double opacity;
  double currentOpacity;
  
  ConcentrationLine({
    required this.angle,
    required this.startRadius,
    required this.endRadius,
    required this.width,
    required this.opacity,
  }) : currentOpacity = opacity;
}

/// 集中線エフェクトマネージャー
/// 複数の集中線エフェクトを管理
class ConcentrationLinesManager extends Component {
  final Map<String, ConcentrationLinesComponent> _activeEffects = {};
  
  /// 集中線エフェクトを再生
  void playConcentrationLines({
    required String effectId,
    required Vector2 center,
    double maxRadius = 300.0,
    int lineCount = 24,
    Color lineColor = Colors.black,
    double animationDuration = 2.0,
  }) {
    // 既存のエフェクトがあれば停止
    stopEffect(effectId);
    
    debugPrint('🌟 Playing concentration lines effect: $effectId at $center');
    
    final effect = ConcentrationLinesComponent(
      center: center,
      maxRadius: maxRadius,
      lineCount: lineCount,
      lineColor: lineColor,
      animationDuration: animationDuration,
    );
    
    _activeEffects[effectId] = effect;
    add(effect);
    
    // アニメーション開始
    effect.startAnimation();
    
    // 自動クリーンアップ
    Future.delayed(Duration(milliseconds: ((animationDuration + 0.5) * 1000).round()), () {
      _activeEffects.remove(effectId);
      debugPrint('🧹 Concentration lines effect cleaned up: $effectId');
    });
  }
  
  /// 特定のエフェクトを停止
  void stopEffect(String effectId) {
    final effect = _activeEffects[effectId];
    if (effect != null && effect.isMounted) {
      effect.removeFromParent();
      _activeEffects.remove(effectId);
    }
  }
  
  /// 全エフェクトを停止
  void stopAllEffects() {
    for (final effect in _activeEffects.values) {
      if (effect.isMounted) {
        effect.removeFromParent();
      }
    }
    _activeEffects.clear();
  }
  
  /// アクティブエフェクト数
  int get activeEffectCount => _activeEffects.length;
}