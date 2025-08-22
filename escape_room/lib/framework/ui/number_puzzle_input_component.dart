import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'ui_system.dart';

/// 数字パズル入力システム
/// Component-based設計準拠、単一責任原則適用
class NumberPuzzleInputComponent extends PositionComponent with TapCallbacks {
  final String correctAnswer;
  String currentInput = '';
  late TextComponent _inputDisplay;
  late RectangleComponent _inputBackground;
  final List<ButtonUIComponent> _numberButtons = [];

  NumberPuzzleInputComponent({
    required this.correctAnswer,
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _setupPuzzleUI();
  }

  /// パズルUI設定
  void _setupPuzzleUI() {
    // 入力表示エリア
    _inputBackground = RectangleComponent(
      position: Vector2(0, 0),
      size: Vector2(size.x, 40),
      paint: Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.fill,
    );
    add(_inputBackground);

    _inputDisplay = TextComponent(
      text: currentInput.isEmpty ? 'パスコードを入力' : currentInput,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(10, 10),
    );
    add(_inputDisplay);

    // 数字ボタン（0-9）
    _setupNumberButtons();

    // クリアボタン
    _setupClearButton();
  }

  /// 数字ボタン設定
  void _setupNumberButtons() {
    const buttonSize = 40.0;
    const spacing = 5.0;
    const buttonsPerRow = 5;

    for (int i = 0; i <= 9; i++) {
      final row = i ~/ buttonsPerRow;
      final col = i % buttonsPerRow;

      final buttonPosition = Vector2(
        col * (buttonSize + spacing),
        50 + row * (buttonSize + spacing),
      );

      final button = ButtonUIComponent(
        text: i.toString(),
        position: buttonPosition,
        size: Vector2(buttonSize, buttonSize),
        onPressed: () => addDigit(i.toString()),
      );

      _numberButtons.add(button);
      add(button);
    }
  }

  /// クリアボタン設定
  void _setupClearButton() {
    final clearButton = ButtonUIComponent(
      text: 'クリア',
      position: Vector2(size.x - 80, 50),
      size: Vector2(70, 40),
      onPressed: reset,
    );
    add(clearButton);
  }

  /// 数字追加
  void addDigit(String digit) {
    if (currentInput.length < 6) {
      // 最大6桁
      currentInput += digit;
      _updateDisplay();
    }
  }

  /// 答えチェック
  bool checkAnswer() {
    return currentInput == correctAnswer;
  }

  /// リセット
  void reset() {
    currentInput = '';
    _updateDisplay();
  }

  /// 表示更新
  void _updateDisplay() {
    _inputDisplay.text = currentInput.isEmpty ? 'パスコードを入力' : currentInput;
  }

  /// 現在の入力値取得
  String get input => currentInput;

  /// 現在の入力値取得（Strategy Pattern用）
  String getCurrentInput() => currentInput;
}
