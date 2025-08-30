import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../modal_config.dart';
import '../japanese_message_system.dart';
import 'modal_display_strategy.dart';
import 'modal_ui_elements.dart';

/// アイテム表示戦略
/// Single Responsibility Principle適用
class ItemDisplayStrategy implements ModalDisplayStrategy {
  @override
  String get strategyName => 'item_display';

  @override
  bool canHandle(ModalType type) => type == ModalType.item;

  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🎁 Creating item modal UI: ${config.title}');

    final elements = ModalUIElements();

    // 正方形サイズ計算（横幅の80%）
    final squareSize = modalSize.x * 0.8;
    final squarePanelSize = Vector2(squareSize, squareSize);
    final squarePanelPosition = Vector2(
      (modalSize.x - squareSize) / 2,
      (modalSize.y - squareSize) / 2,
    );

    // 背景オーバーレイ
    elements.background = RectangleComponent(
      size: modalSize,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    // 正方形モーダルパネル
    elements.modalPanel = RectangleComponent(
      position: squarePanelPosition,
      size: squarePanelSize,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // 安全な実装: RectangleComponentを使用
    elements.imageComponent =
        RectangleComponent(
            paint: Paint()..color = Colors.brown.withValues(alpha: 0.5),
          )
          ..position = Vector2(
            squarePanelPosition.x + squarePanelSize.x * 0.1,
            squarePanelPosition.y + squarePanelSize.y * 0.15,
          )
          ..size = Vector2(squarePanelSize.x * 0.8, squarePanelSize.y * 0.65);

    // 画像を非同期で読み込み

    // タイトル（画像の下に配置）
    elements.titleText = TextComponent(
      text: config.title,
      textRenderer: JapaneseFontSystem.getTextPaint(
        20,
        Colors.blue,
        FontWeight.bold,
      ),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.85,
      ),
      anchor: Anchor.center,
    );

    // アイテム説明（タイトルの下）
    elements.contentText = TextComponent(
      text: config.content,
      textRenderer: JapaneseFontSystem.getTextPaint(14, Colors.black87),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.92,
      ),
      anchor: Anchor.center,
    );

    return elements;
  }

  /// 画像を非同期で読み込み

  @override
  bool validateInput(String input, ModalConfig config) {
    // アイテム表示は入力検証不要
    return true;
  }

  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    debugPrint(
      '🎁 Item modal confirmed: ${config.data['itemId'] ?? 'unknown'}',
    );
    config.onConfirm?.call();
  }
}