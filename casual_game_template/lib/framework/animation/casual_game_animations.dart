import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// Flame公式Effects活用のカジュアルゲーム用アニメーションプリセット
/// 
/// Flame公式のEffectsシステム（MoveEffect、ScaleEffect、ColorEffect等）を使用し、
/// カジュアルゲーム量産時の標準アニメーションを提供します。
/// 
/// 使用例:
/// ```dart
/// // ボタンタップエフェクト
/// CasualGameAnimations.buttonTap(myButton);
/// 
/// // コイン収集エフェクト  
/// CasualGameAnimations.coinCollect(coinComponent);
/// 
/// // カスタムエフェクト適用
/// final effect = CasualGameAnimations.presets['screen_transition']!(component);
/// component.addAll(effect);
/// ```
class CasualGameAnimations {
  
  /// ボタンタップアニメーション
  /// 
  /// Flame公式のScaleEffect + ColorEffectを組み合わせた
  /// 標準的なボタンフィードバック。
  static void buttonTap(PositionComponent button) {
    button.add(
      SequenceEffect([
        // 押し込みエフェクト（0.05秒）
        ScaleEffect.by(
          Vector2.all(0.9), 
          EffectController(duration: 0.05),
        ),
        // 戻りエフェクト（0.05秒）
        ScaleEffect.by(
          Vector2.all(1.11), // 0.9 * 1.11 = 0.999 ≈ 1.0
          EffectController(duration: 0.05),
        ),
        // 色変化エフェクト（同時実行）
      ]),
    );
    
    // 色変化は削除（ColorEffectのAPIが不安定なため）
    // 代わりにスケールエフェクトのみで視覚フィードバックを提供
  }
  
  /// コイン収集アニメーション
  /// 
  /// 上昇→拡大→フェードアウトの3段階エフェクト。
  /// EffectControllerの同時実行機能を活用。
  static void coinCollect(PositionComponent coin) {
    coin.add(
      SequenceEffect([
        // 上昇 + 拡大（同時実行）
        MoveEffect.by(
          Vector2(0, -50), 
          EffectController(duration: 0.8),
        ),
        ScaleEffect.by(
          Vector2.all(1.5), 
          EffectController(duration: 0.4),
        ),
        // フェードアウト（0.4秒遅延後実行）
        OpacityEffect.fadeOut(
          EffectController(duration: 0.4, startDelay: 0.4),
        ),
        // 自動削除
        RemoveEffect(),
      ]),
    );
  }
  
  /// 敵ヒットアニメーション
  /// 
  /// 横振動のみ（ColorEffectは不安定なため削除）
  static void enemyHit(PositionComponent enemy) {
    
    // 横振動（4回）
    enemy.add(
      MoveEffect.by(
        Vector2(10, 0),
        EffectController(
          duration: 0.05,
          alternate: true,
          repeatCount: 4,
        ),
      ),
    );
  }
  
  /// 画面遷移アニメーション（スライドイン）
  /// 
  /// 画面外から中央へのスライド移動。
  /// 開始位置を画面外に設定して自然な遷移を実現。
  static void screenSlideIn(PositionComponent screen, Vector2 screenSize, {
    SlideDirection direction = SlideDirection.fromBottom,
    double duration = 0.5,
  }) {
    Vector2 startOffset;
    switch (direction) {
      case SlideDirection.fromBottom:
        startOffset = Vector2(0, screenSize.y);
        break;
      case SlideDirection.fromTop:
        startOffset = Vector2(0, -screenSize.y);
        break;
      case SlideDirection.fromLeft:
        startOffset = Vector2(-screenSize.x, 0);
        break;
      case SlideDirection.fromRight:
        startOffset = Vector2(screenSize.x, 0);
        break;
    }
    
    // 開始位置に移動（瞬時）
    screen.position.add(startOffset);
    
    // 元の位置に戻る（アニメーション）
    screen.add(
      MoveEffect.by(
        -startOffset, // 元の位置へ
        EffectController(duration: duration, curve: Curves.easeOut),
      ),
    );
  }
  
  /// 画面遷移アニメーション（フェードイン）
  static void screenFadeIn(PositionComponent screen, {double duration = 0.3}) {
    screen.add(
      OpacityEffect.fadeIn(
        EffectController(duration: duration),
      ),
    );
  }
  
  /// ポップアップ表示アニメーション
  /// 
  /// 小→大のスケールエフェクト + バウンス。
  /// Curves.elasticOutでバウンシーな動きを実現。
  static void popupShow(PositionComponent popup) {
    // 初期スケールを0に
    popup.scale = Vector2.zero();
    
    popup.add(
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(
          duration: 0.5,
          curve: Curves.elasticOut,
        ),
      ),
    );
  }
  
  /// ポップアップ非表示アニメーション
  static void popupHide(PositionComponent popup) {
    popup.add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.3, curve: Curves.easeIn),
        ),
        RemoveEffect(),
      ]),
    );
  }
  
  /// フローティングテキストアニメーション
  /// 
  /// ダメージ表示やスコア表示に使用。
  /// 上昇 + フェード + 自動削除。
  static void floatingText(TextComponent text, {
    Vector2? moveOffset,
    double duration = 1.0,
  }) {
    final offset = moveOffset ?? Vector2(0, -30);
    text.add(
      SequenceEffect([
        MoveEffect.by(
          offset,
          EffectController(duration: duration),
        ),
        OpacityEffect.fadeOut(
          EffectController(duration: duration),
        ),
        RemoveEffect(),
      ]),
    );
  }
  
  /// パルスアニメーション（呼吸のような繰り返し）
  /// 
  /// 重要な要素の注意喚起に使用。
  /// 無限ループのスケールエフェクト。
  static void pulse(PositionComponent component, {
    double scale = 1.2,
    double duration = 1.0,
  }) {
    component.add(
      ScaleEffect.by(
        Vector2.all(scale),
        EffectController(
          duration: duration,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }
  
  /// 回転アニメーション
  static void rotate(PositionComponent component, {
    double angle = 6.28318, // 2π (360度)
    double duration = 2.0,
    bool infinite = false,
  }) {
    component.add(
      RotateEffect.by(
        angle,
        EffectController(
          duration: duration,
          infinite: infinite,
        ),
      ),
    );
  }
  
  /// シェイクアニメーション（画面振動）
  static void shake(PositionComponent component, {
    double intensity = 5.0,
    double duration = 0.5,
    int frequency = 10,
  }) {
    final random = <Vector2>[];
    for (int i = 0; i < frequency; i++) {
      random.add(Vector2(
        (i.isEven ? intensity : -intensity) * (1.0 - i / frequency),
        (i.isOdd ? intensity : -intensity) * (1.0 - i / frequency),
      ));
    }
    
    final effects = <Effect>[];
    for (int i = 0; i < random.length; i++) {
      effects.add(
        MoveEffect.by(
          random[i],
          EffectController(duration: duration / frequency),
        ),
      );
      if (i < random.length - 1) {
        effects.add(
          MoveEffect.by(
            -random[i],
            EffectController(duration: duration / frequency),
          ),
        );
      }
    }
    
    component.add(SequenceEffect(effects));
  }
  
  /// プリセットアニメーション定義
  /// 
  /// Map形式でアニメーションを管理。
  /// 量産ゲーム開発時の標準エフェクト集。
  static final Map<String, List<Effect> Function(PositionComponent)> presets = {
    
    'coin_collect': (component) => [
      MoveEffect.by(Vector2(0, -50), EffectController(duration: 0.8)),
      ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.4)),
      OpacityEffect.fadeOut(EffectController(duration: 0.4, startDelay: 0.4)),
      RemoveEffect(),
    ],
    
    'enemy_hit': (component) => [
      MoveEffect.by(
        Vector2(10, 0),
        EffectController(duration: 0.05, alternate: true, repeatCount: 4),
      ),
    ],
    
    'button_feedback': (component) => [
      SequenceEffect([
        ScaleEffect.by(Vector2.all(0.9), EffectController(duration: 0.05)),
        ScaleEffect.by(Vector2.all(1.11), EffectController(duration: 0.05)),
      ]),
    ],
    
    'popup_appear': (component) => [
      ScaleEffect.to(
        Vector2.all(1.0),
        EffectController(duration: 0.5, curve: Curves.elasticOut),
      ),
    ],
    
    'popup_disappear': (component) => [
      SequenceEffect([
        ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.3)),
        RemoveEffect(),
      ]),
    ],
    
    'screen_fade_in': (component) => [
      OpacityEffect.fadeIn(EffectController(duration: 0.3)),
    ],
    
    'screen_slide_up': (component) => [
      MoveEffect.by(Vector2(0, -600), EffectController(duration: 0.5)),
    ],
    
    'floating_damage': (component) => [
      MoveEffect.by(Vector2(0, -30), EffectController(duration: 1.0)),
      OpacityEffect.fadeOut(EffectController(duration: 1.0)),
      RemoveEffect(),
    ],
    
    'power_up_collect': (component) => [
      SequenceEffect([
        ScaleEffect.by(Vector2.all(1.3), EffectController(duration: 0.2)),
        RotateEffect.by(6.28318, EffectController(duration: 0.5)),
        OpacityEffect.fadeOut(EffectController(duration: 0.5)),
        RemoveEffect(),
      ]),
    ],
    
    'warning_pulse': (component) => [
      ScaleEffect.by(
        Vector2.all(1.1),
        EffectController(duration: 0.5, alternate: true, infinite: true),
      ),
    ],
  };
  
  /// プリセットアニメーション適用
  static void applyPreset(String presetName, PositionComponent component) {
    final preset = presets[presetName];
    if (preset != null) {
      final effects = preset(component);
      component.addAll(effects);
    }
  }
  
  /// 複数プリセットの組み合わせ適用
  static void applyPresets(List<String> presetNames, PositionComponent component) {
    for (final presetName in presetNames) {
      applyPreset(presetName, component);
    }
  }
}

/// スライド方向の定義
enum SlideDirection {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
}

/// アニメーション拡張メソッド
extension CasualGameAnimationExtensions on PositionComponent {
  
  /// 便利メソッド：プリセットアニメーション適用
  void animateWith(String presetName) {
    CasualGameAnimations.applyPreset(presetName, this);
  }
  
  /// 便利メソッド：ボタンタップエフェクト
  void animateButtonTap() {
    CasualGameAnimations.buttonTap(this);
  }
  
  /// 便利メソッド：フェードイン
  void animateFadeIn({double duration = 0.3}) {
    add(OpacityEffect.fadeIn(EffectController(duration: duration)));
  }
  
  /// 便利メソッド：フェードアウト
  void animateFadeOut({double duration = 0.3, bool removeAfter = false}) {
    final effects = <Effect>[
      OpacityEffect.fadeOut(EffectController(duration: duration)),
    ];
    if (removeAfter) {
      effects.add(RemoveEffect());
    }
    add(SequenceEffect(effects));
  }
  
  /// 便利メソッド：スケール変更
  void animateScaleTo(Vector2 targetScale, {double duration = 0.3}) {
    add(ScaleEffect.to(targetScale, EffectController(duration: duration)));
  }
  
  /// 便利メソッド：位置移動
  void animateMoveTo(Vector2 targetPosition, {double duration = 0.5}) {
    add(MoveEffect.to(targetPosition, EffectController(duration: duration)));
  }
  
  /// 便利メソッド：パルスアニメーション開始
  void startPulse({double scale = 1.2, double duration = 1.0}) {
    CasualGameAnimations.pulse(this, scale: scale, duration: duration);
  }
  
  /// 便利メソッド：シェイクアニメーション
  void shake({double intensity = 5.0, double duration = 0.5}) {
    CasualGameAnimations.shake(this, intensity: intensity, duration: duration);
  }
}