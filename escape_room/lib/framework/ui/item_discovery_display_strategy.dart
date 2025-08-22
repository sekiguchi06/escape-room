import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'modal_config.dart';
import 'modal_strategy_interface.dart';
import 'japanese_message_system.dart';
import 'concentration_lines_component.dart';
import '../effects/particle_system.dart';

/// アイテム発見演出戦略
/// 下からスライド + 集中線 + パーティクルエフェクト
class ItemDiscoveryDisplayStrategy implements ModalDisplayStrategy {
  ConcentrationLinesManager? _concentrationLinesManager;
  ParticleEffectManager? _particleEffectManager;

  @override
  String get strategyName => 'item_discovery_display';

  @override
  bool canHandle(ModalType type) => type == ModalType.itemDiscovery;

  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🎊 Creating item discovery modal UI: ${config.title}');

    final elements = ModalUIElements();

    // アイテム画像サイズ（画面幅の60%）
    final imageSize = modalSize.x * 0.6;
    final imageDisplaySize = Vector2(imageSize, imageSize);

    // 最終位置（画面下80%の位置）
    final finalPosition = Vector2(
      (modalSize.x - imageSize) / 2,
      modalSize.y * 0.8 - imageSize,
    );

    // 開始位置（画面下120%の位置、見えない場所）
    final startPosition = Vector2(finalPosition.x, modalSize.y * 1.2);

    // 背景オーバーレイ（少し暗め）
    elements.background = RectangleComponent(
      size: modalSize,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.7),
    );

    // アイテム背景パネル（円形に近い角丸）
    elements.modalPanel = RectangleComponent(
      position: finalPosition,
      size: imageDisplaySize,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // アイテム画像（設定済みパスを使用）

    // 安全な実装: RectangleComponentを使用
    elements.imageComponent =
        RectangleComponent(
            paint: Paint()..color = Colors.brown.withValues(alpha: 0.5),
          )
          ..position = Vector2(
            finalPosition.x + imageDisplaySize.x * 0.1,
            finalPosition.y + imageDisplaySize.y * 0.1,
          )
          ..size = Vector2(imageDisplaySize.x * 0.8, imageDisplaySize.y * 0.8);

    // タイトル（画像の下）
    elements.titleText = TextComponent(
      text: config.title,
      textRenderer: JapaneseFontSystem.getTextPaint(
        24,
        Colors.yellow,
        FontWeight.bold,
      ),
      position: Vector2(
        finalPosition.x + imageDisplaySize.x / 2,
        finalPosition.y + imageDisplaySize.y + 20,
      ),
      anchor: Anchor.center,
    );

    // 説明文（タイトルの下）
    elements.contentText = TextComponent(
      text: config.content,
      textRenderer: JapaneseFontSystem.getTextPaint(16, Colors.white),
      position: Vector2(
        finalPosition.x + imageDisplaySize.x / 2,
        finalPosition.y + imageDisplaySize.y + 50,
      ),
      anchor: Anchor.center,
    );

    // アニメーション効果を追加
    _addAnimationEffects(elements, startPosition, finalPosition, modalSize);

    return elements;
  }

  /// アニメーション効果を追加
  void _addAnimationEffects(
    ModalUIElements elements,
    Vector2 startPosition,
    Vector2 finalPosition,
    Vector2 modalSize,
  ) {
    // モーダルパネルの初期位置を開始位置に設定
    elements.modalPanel.position = startPosition.clone();

    // スライドアップアニメーション
    final slideEffect = MoveToEffect(
      finalPosition,
      EffectController(duration: 0.8, curve: Curves.bounceOut),
    );
    elements.modalPanel.add(slideEffect);

    // スケールアニメーション（小さく始まって通常サイズに）
    elements.modalPanel.scale = Vector2.all(0.3);
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.8, curve: Curves.elasticOut),
    );
    elements.modalPanel.add(scaleEffect);

    // フェードインアニメーション
    elements.modalPanel.opacity = 0.0;
    final fadeEffect = OpacityEffect.to(1.0, LinearEffectController(0.5));
    elements.modalPanel.add(fadeEffect);

    // 集中線エフェクト（遅延実行）
    Future.delayed(const Duration(milliseconds: 300), () {
      final center = Vector2(
        finalPosition.x + elements.modalPanel.size.x / 2,
        finalPosition.y + elements.modalPanel.size.y / 2,
      );

      _concentrationLinesManager?.playConcentrationLines(
        effectId: 'item_discovery',
        center: center,
        maxRadius: 400.0,
        lineCount: 32,
        lineColor: Colors.orange,
        animationDuration: 1.5,
      );
    });

    // パーティクルエフェクト（さらに遅延実行）
    Future.delayed(const Duration(milliseconds: 500), () {
      final center = Vector2(
        finalPosition.x + elements.modalPanel.size.x / 2,
        finalPosition.y + elements.modalPanel.size.y / 2,
      );

      _particleEffectManager?.playEffect('itemDiscovery', center);
    });
  }

  /// エフェクトマネージャーを設定
  void setEffectManagers({
    ConcentrationLinesManager? concentrationLinesManager,
    ParticleEffectManager? particleEffectManager,
  }) {
    _concentrationLinesManager = concentrationLinesManager;
    _particleEffectManager = particleEffectManager;
  }

  @override
  bool validateInput(String input, ModalConfig config) {
    // アイテム発見演出は入力検証不要
    return true;
  }

  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    debugPrint(
      '🎊 Item discovery confirmed: ${config.data['itemId'] ?? 'unknown'}',
    );
    config.onConfirm?.call();
  }
}
