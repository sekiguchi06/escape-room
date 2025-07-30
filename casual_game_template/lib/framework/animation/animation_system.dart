import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// アニメーション設定
class AnimationConfig {
  final Duration duration;
  final Curve curve;
  final bool autoReverse;
  final int repeatCount;
  final bool infinite;
  final Duration startDelay;
  final VoidCallback? onComplete;
  
  const AnimationConfig({
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.autoReverse = false,
    this.repeatCount = 1,
    this.infinite = false, 
    this.startDelay = Duration.zero,
    this.onComplete,
  });
  
  /// EffectController生成
  EffectController toEffectController() {
    return EffectController(
      duration: duration.inMilliseconds / 1000.0,
      curve: curve,
      alternate: autoReverse,
      repeatCount: infinite ? null : repeatCount,
      infinite: infinite,
      startDelay: startDelay.inMilliseconds / 1000.0,
      onMax: autoReverse ? null : onComplete,
      onMin: autoReverse ? onComplete : null,
    );
  }
}

/// PositionComponent用Extension（移動・スケール・回転）
extension PositionComponentAnimations on PositionComponent {
  /// 移動アニメーション
  void animateMoveTo(
    Vector2 destination, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    add(
      MoveEffect.to(
        destination,
        config.toEffectController(),
        onComplete: config.onComplete,
      ),
    );
  }
  
  /// 相対移動アニメーション
  void animateMoveBy(
    Vector2 offset, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    add(
      MoveEffect.by(
        offset,
        config.toEffectController(),
        onComplete: config.onComplete,
      ),
    );
  }
  
  /// スケールアニメーション
  void animateScaleTo(
    Vector2 scale, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    add(
      ScaleEffect.to(
        scale,
        config.toEffectController(),
        onComplete: config.onComplete,
      ),
    );
  }
  
  /// 相対スケールアニメーション
  void animateScaleBy(
    Vector2 scaleFactor, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    add(
      ScaleEffect.by(
        scaleFactor,
        config.toEffectController(),
        onComplete: config.onComplete,
      ),
    );
  }
  
  /// 回転アニメーション
  void animateRotateTo(
    double angle, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    add(
      RotateEffect.to(
        angle,
        config.toEffectController(),
        onComplete: config.onComplete,
      ),
    );
  }
  
  /// 相対回転アニメーション
  void animateRotateBy(
    double angle, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    add(
      RotateEffect.by(
        angle,
        config.toEffectController(),
        onComplete: config.onComplete,
      ),
    );
  }
  
  /// 振動アニメーション
  void animateShake({
    double intensity = 5.0,
    Duration duration = const Duration(milliseconds: 300),
    VoidCallback? onComplete,
  }) {
    add(
      SequenceEffect([
        MoveEffect.by(
          Vector2(intensity, 0),
          EffectController(duration: duration.inMilliseconds / 1000.0 / 8),
        ),
        MoveEffect.by(
          Vector2(-intensity * 2, 0),
          EffectController(duration: duration.inMilliseconds / 1000.0 / 4),
        ),
        MoveEffect.by(
          Vector2(intensity * 2, 0),
          EffectController(duration: duration.inMilliseconds / 1000.0 / 4),
        ),
        MoveEffect.by(
          Vector2(-intensity * 2, 0),
          EffectController(duration: duration.inMilliseconds / 1000.0 / 4),
        ),
        MoveEffect.by(
          Vector2(intensity, 0),
          EffectController(duration: duration.inMilliseconds / 1000.0 / 8),
          onComplete: onComplete,
        ),
      ]),
    );
  }
}

/// HasPaint実装Component用Extension（透明度）
extension HasPaintAnimations<T extends Component> on T {
  /// フェードイン
  void animateFadeIn({
    AnimationConfig config = const AnimationConfig(),
  }) {
    if (this is OpacityProvider) {
      add(
        OpacityEffect.fadeIn(
          config.toEffectController(),
          onComplete: config.onComplete,
        ),
      );
    }
  }
  
  /// フェードアウト
  void animateFadeOut({
    AnimationConfig config = const AnimationConfig(),
  }) {
    if (this is OpacityProvider) {
      add(
        OpacityEffect.fadeOut(
          config.toEffectController(),
          onComplete: config.onComplete,
        ),
      );
    }
  }
  
  /// 透明度アニメーション
  void animateOpacityTo(
    double opacity, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    if (this is OpacityProvider) {
      add(
        OpacityEffect.to(
          opacity,
          config.toEffectController(),
          onComplete: config.onComplete,
        ),
      );
    }
  }
  
  /// 相対透明度アニメーション
  void animateOpacityBy(
    double offset, {
    AnimationConfig config = const AnimationConfig(),
  }) {
    if (this is OpacityProvider) {
      add(
        OpacityEffect.by(
          offset,
          config.toEffectController(),
          onComplete: config.onComplete,
        ),
      );
    }
  }
}

/// SpriteComponent専用Extension
extension SpriteComponentAnimations on SpriteComponent {
  /// 点滅アニメーション
  void animateBlink({
    int blinkCount = 3,
    Duration blinkDuration = const Duration(milliseconds: 200),
    VoidCallback? onComplete,
  }) {
    final effects = <Effect>[];
    
    for (int i = 0; i < blinkCount; i++) {
      effects.add(
        OpacityEffect.to(
          0.3,
          EffectController(duration: blinkDuration.inMilliseconds / 2000.0),
        ),
      );
      effects.add(
        OpacityEffect.to(
          1.0,
          EffectController(duration: blinkDuration.inMilliseconds / 2000.0),
          onComplete: i == blinkCount - 1 ? onComplete : null,
        ),
      );
    }
    
    add(SequenceEffect(effects));
  }
}

/// TextComponent専用Extension（HasPaint対応版が必要）
extension TextComponentAnimations on TextComponent {
  /// テキスト表示アニメーション
  void animateTypewriter({
    Duration totalDuration = const Duration(seconds: 1),
    VoidCallback? onComplete,
  }) {
    // TextComponentはデフォルトでHasPaint未実装のため
    // カスタム実装が必要（公式Issue #1013参照）
    debugPrint('TextComponent opacity animations require custom implementation with HasPaint');
  }
}

/// アニメーション連鎖用Extension
extension ComponentEffectChain on Component {
  /// 連続アニメーション実行
  void animateSequence(List<Effect> effects) {
    add(SequenceEffect(effects));
  }
  
  /// 並列アニメーション実行
  void animateParallel(List<Effect> effects) {
    for (final effect in effects) {
      add(effect);
    }
  }
  
  /// 全Effect削除
  void clearAllEffects() {
    final effects = children.whereType<Effect>().toList();
    for (final effect in effects) {
      effect.removeFromParent();
    }
  }
}

/// プリセットアニメーション
class AnimationPresets {
  /// ボタンタップアニメーション
  static void buttonTap(PositionComponent button) {
    button.animateScaleBy(
      Vector2.all(0.9),
      config: AnimationConfig(
        duration: const Duration(milliseconds: 100),
        autoReverse: true,
        curve: Curves.easeOutBack,
      ),
    );
  }
  
  /// ポップアップ表示
  static void popIn(PositionComponent component) {
    component.scale = Vector2.zero();
    component.animateScaleTo(
      Vector2.all(1.0),
      config: const AnimationConfig(
        duration: Duration(milliseconds: 800), // 0.8秒に延長して視認しやすく
        curve: Curves.elasticOut,
      ),
    );
  }
  
  /// スライドイン（左から）
  static void slideInFromLeft(PositionComponent component, double screenWidth) {
    final originalX = component.position.x;
    final originalY = component.position.y;
    // 画面左端の完全に見えない位置に移動（サイズ分だけ左にオフセット）
    component.position.x = -component.size.x - 50; // 追加の50px左にオフセット
    component.animateMoveTo(
      Vector2(originalX, originalY),
      config: const AnimationConfig(
        duration: Duration(milliseconds: 1500), // 1.5秒に延長して視認しやすく
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

/// ゲーム用基底Component（すべてのEffect対応）
class GameComponent extends PositionComponent with HasPaint {
  GameComponent({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  });
  
  @override
  void render(Canvas canvas) {
    // 基本的な矩形描画（デバッグ用）
    if (size.x > 0 && size.y > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        paint,
      );
    }
    super.render(canvas);
  }
}