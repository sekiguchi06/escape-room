import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../modal_config.dart';
import '../japanese_message_system.dart';
import 'modal_display_strategy.dart';
import 'modal_ui_elements.dart';

/// 調査表示戦略
/// オブジェクト詳細調査用
class InspectionDisplayStrategy implements ModalDisplayStrategy {
  @override
  String get strategyName => 'inspection_display';

  @override
  bool canHandle(ModalType type) => type == ModalType.inspection;

  /// 画像を非同期で読み込み

  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🔍 Creating inspection modal UI: ${config.title}');

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
      paint: Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    // 正方形調査専用パネル
    elements.modalPanel = RectangleComponent(
      position: squarePanelPosition,
      size: squarePanelSize,
      paint: Paint()..color = Colors.white,
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

    // タイトル（調査対象）
    elements.titleText = TextComponent(
      text: '🔍 ${config.title}',
      textRenderer: JapaneseFontSystem.getTextPaint(
        20,
        Colors.green,
        FontWeight.bold,
      ),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.85,
      ),
      anchor: Anchor.center,
    );

    // 調査結果
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

  @override
  bool validateInput(String input, ModalConfig config) {
    // 調査表示は入力検証不要
    return true;
  }

  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    debugPrint(
      '🔍 Inspection completed: ${config.data['objectId'] ?? 'unknown'}',
    );
    config.onConfirm?.call();
  }
}