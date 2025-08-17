import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'ui_system.dart';
import 'number_puzzle_input_component.dart';
import 'modal_config.dart';

/// モーダルUI構築クラス
/// Component-based設計準拠、単一責任原則適用
class ModalUIBuilder {
  /// モーダルUI設定（80%正方形・95%画像表示・文字なし）
  static ModalUIElements setupModalUI(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    final elements = ModalUIElements();
    
    // 背景オーバーレイ（半透明黒）
    elements.background = RectangleComponent(
      size: modalSize,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
    
    // モーダルパネル（80%正方形）
    final squareSize = modalSize.x * 0.8;
    final squarePanelSize = Vector2(squareSize, squareSize);
    final squarePanelPosition = Vector2(
      (modalSize.x - squareSize) / 2,
      (modalSize.y - squareSize) / 2,
    );
    
    elements.modalPanel = RectangleComponent(
      position: squarePanelPosition,
      size: squarePanelSize,
      paint: Paint()..color = Colors.white,
    );
    
    // 画像表示（95%サイズ・文字表示なし）
    if (config.imagePath.isNotEmpty) {
      elements.imageComponent = _createImageComponent(
        config.imagePath,
        squarePanelPosition,
        squarePanelSize,
        config.onTap,
      );
    }
    
    // モーダルタイプ別の追加UI（画像なしの場合のみ）
    if (config.imagePath.isEmpty && config.type == ModalType.puzzle) {
      final correctAnswer = config.data['correctAnswer'] as String? ?? '';
      elements.puzzleInput = NumberPuzzleInputComponent(
        correctAnswer: correctAnswer,
        position: Vector2(
          squarePanelPosition.x + 20,
          squarePanelPosition.y + 120,
        ),
        size: Vector2(squarePanelSize.x - 40, 100),
      );
    }
    
    return elements;
  }
  
  /// 画像コンポーネント作成（95%表示・タップ対応）
  static Component _createImageComponent(
    String imagePath,
    Vector2 panelPosition,
    Vector2 panelSize,
    VoidCallback? onTap,
  ) {
    final imageSize = Vector2(panelSize.x * 0.95, panelSize.y * 0.95);
    final imagePosition = Vector2(
      panelPosition.x + (panelSize.x - imageSize.x) / 2,
      panelPosition.y + (panelSize.y - imageSize.y) / 2,
    );
    
    return _ImageModalComponent(
      imagePath: imagePath,
      position: imagePosition,
      size: imageSize,
      onTap: onTap,
    );
  }
  
  /// 確認ボタン作成
  static ButtonUIComponent createConfirmButton(
    Vector2 panelPosition,
    Vector2 panelSize,
    ModalConfig config,
    NumberPuzzleInputComponent? puzzleInput,
    VoidCallback onPressed,
  ) {
    final buttonSize = Vector2(100, 40);
    final buttonPosition = Vector2(
      panelPosition.x + panelSize.x - buttonSize.x - 20,
      panelPosition.y + panelSize.y - buttonSize.y - 20,
    );
    
    return ButtonUIComponent(
      text: 'OK',
      position: buttonPosition,
      size: buttonSize,
      onPressed: onPressed,
    );
  }
  
  /// キャンセルボタン作成
  static ButtonUIComponent createCancelButton(
    Vector2 panelPosition,
    Vector2 panelSize,
    VoidCallback onPressed,
  ) {
    final buttonSize = Vector2(100, 40);
    final buttonPosition = Vector2(
      panelPosition.x + panelSize.x - 220, // OK button左側
      panelPosition.y + panelSize.y - buttonSize.y - 20,
    );
    
    return ButtonUIComponent(
      text: 'キャンセル',
      position: buttonPosition,
      size: buttonSize,
      onPressed: onPressed,
    );
  }
}

/// モーダルUI要素格納クラス（画像表示対応）
class ModalUIElements {
  late RectangleComponent background;
  late RectangleComponent modalPanel;
  TextComponent? titleText;
  TextComponent? contentText;
  Component? imageComponent;
  NumberPuzzleInputComponent? puzzleInput;
}

/// 画像モーダルコンポーネント（タップ対応）
class _ImageModalComponent extends PositionComponent with TapCallbacks {
  final String imagePath;
  final VoidCallback? onTap;
  
  _ImageModalComponent({
    required this.imagePath,
    required Vector2 position,
    required Vector2 size,
    this.onTap,
  }) : super(position: position, size: size);
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      final sprite = await Sprite.load(imagePath);
      final spriteComponent = SpriteComponent(
        sprite: sprite,
        size: size,
        position: Vector2.zero(),
      );
      add(spriteComponent);
    } catch (e) {
      debugPrint('❌ Failed to load modal image $imagePath: $e');
      // フォールバック：色付き矩形
      final fallbackComponent = RectangleComponent(
        size: size,
        position: Vector2.zero(),
        paint: Paint()..color = Colors.grey.shade300,
      );
      add(fallbackComponent);
    }
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    onTap?.call();
  }
}