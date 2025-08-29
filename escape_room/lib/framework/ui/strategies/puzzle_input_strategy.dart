import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../modal_config.dart';
import '../modal_display_strategy_base.dart';
import '../number_puzzle_input_component.dart';
import '../japanese_message_system.dart';

/// パズル入力戦略
/// Strategy Pattern + Component組み合わせ
class PuzzleInputStrategy implements ModalDisplayStrategy {
  @override
  String get strategyName => 'puzzle_input';

  @override
  bool canHandle(ModalType type) => type == ModalType.puzzle;

  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🧩 Creating puzzle modal UI: ${config.title}');

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
      paint: Paint()..color = Colors.black.withValues(alpha: 0.7),
    );

    // 正方形パズル専用パネル
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
            squarePanelPosition.y + squarePanelSize.y * 0.1,
          )
          ..size = Vector2(squarePanelSize.x * 0.8, squarePanelSize.y * 0.5);

    // タイトル（パズル名）
    elements.titleText = TextComponent(
      text: config.title,
      textRenderer: JapaneseFontSystem.getTextPaint(
        20,
        Colors.orange,
        FontWeight.bold,
      ),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.65,
      ),
      anchor: Anchor.center,
    );

    // パズル説明
    elements.contentText = TextComponent(
      text: config.content,
      textRenderer: JapaneseFontSystem.getTextPaint(14, Colors.black87),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.72,
      ),
      anchor: Anchor.center,
    );

    // パズル入力コンポーネント
    final correctAnswer = config.data['correctAnswer'] as String? ?? '';
    elements.puzzleInput = NumberPuzzleInputComponent(
      correctAnswer: correctAnswer,
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.78,
      ),
      size: Vector2(squarePanelSize.x * 0.8, squarePanelSize.y * 0.15),
    );

    return elements;
  }

  @override
  bool validateInput(String input, ModalConfig config) {
    final correctAnswer = config.data['correctAnswer'] as String? ?? '';
    final isCorrect = input.trim() == correctAnswer.trim();
    debugPrint(
      '🧩 Puzzle validation: input="$input", correct="$correctAnswer", result=$isCorrect',
    );
    return isCorrect;
  }

  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    if (userInput != null && validateInput(userInput, config)) {
      debugPrint('🧩 Puzzle solved correctly: ${config.title}');
      config.onConfirm?.call();
      config.onPuzzleSuccess?.call(); // パズル成功時のコールバック呼び出し
    } else {
      debugPrint('🧩 Puzzle answer incorrect: ${config.title}');
      // 不正解時の処理（振動、エラー音等）
    }
  }
}