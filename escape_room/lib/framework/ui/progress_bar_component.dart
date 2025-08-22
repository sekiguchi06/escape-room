import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'ui_component_base.dart';

/// プログレスバーUIコンポーネント
class ProgressBarUIComponent extends UIComponent<double> {
  late RectangleComponent _background;
  late RectangleComponent _foreground;

  double _progress = 0.0; // 0.0 - 1.0
  final String _backgroundColorId;
  final String _foregroundColorId;

  ProgressBarUIComponent({
    double progress = 0.0,
    String backgroundColorId = 'background',
    String foregroundColorId = 'primary',
    super.position,
    Vector2? size,
    super.themeId,
  }) : _progress = progress,
       _backgroundColorId = backgroundColorId,
       _foregroundColorId = foregroundColorId,
       super(size: size ?? Vector2(200, 20));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 背景
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = getThemeColor(_backgroundColorId),
    );
    add(_background);

    // プログレス
    _foreground = RectangleComponent(
      size: Vector2(size.x * _progress, size.y),
      paint: Paint()..color = getThemeColor(_foregroundColorId),
    );
    add(_foreground);
  }

  /// プログレスを設定（0.0 - 1.0）
  void setProgress(double progress) {
    _progress = progress.clamp(0.0, 1.0);
    if (isMounted) {
      _foreground.size = Vector2(size.x * _progress, size.y);
    }
  }

  /// 現在のプログレスを取得
  double get progress => _progress;

  @override
  void updateContent(double content) {
    setProgress(content);
  }

  @override
  void onThemeChanged() {
    super.onThemeChanged();
    if (isMounted) {
      _background.paint.color = getThemeColor(_backgroundColorId);
      _foreground.paint.color = getThemeColor(_foregroundColorId);
    }
  }

  /// アニメーション付きでプログレスを設定
  void animateToProgress(double targetProgress, {double duration = 0.5}) {
    final target = targetProgress.clamp(0.0, 1.0);
    if (isMounted) {
      _foreground.add(
        SizeEffect.to(
          Vector2(size.x * target, size.y),
          EffectController(duration: duration),
        ),
      );
    }
    _progress = target;
  }

  /// プログレスバーの色を動的に変更
  void setColors({String? backgroundColorId, String? foregroundColorId}) {
    if (isMounted) {
      if (backgroundColorId != null) {
        _background.paint.color = getThemeColor(backgroundColorId);
      }
      if (foregroundColorId != null) {
        _foreground.paint.color = getThemeColor(foregroundColorId);
      }
    }
  }

  /// パルス効果を追加
  void addPulseEffect({double duration = 1.0}) {
    if (isMounted) {
      _foreground.add(
        OpacityEffect.fadeIn(
          EffectController(
            duration: duration / 2,
            reverseDuration: duration / 2,
            infinite: true,
          ),
        ),
      );
    }
  }
}
