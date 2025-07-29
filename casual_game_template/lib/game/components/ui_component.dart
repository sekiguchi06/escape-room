import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// ゲームのUI表示を管理するコンポーネント
/// テキスト表示、状態に応じたUI変更を担当
class UIComponent extends PositionComponent {
  late TextComponent _stateText;
  
  // UI状態更新のコールバック
  void Function(String text)? onTextUpdate;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // 状態表示用のテキストコンポーネント
    _stateText = TextComponent(
      text: 'TAP TO START',
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    add(_stateText);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // 画面中央に配置
    position = Vector2(size.x / 2, size.y / 2);
  }

  /// 開始画面のUIを表示
  void showStartScreen() {
    _stateText.text = 'TAP TO START';
    _stateText.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// ゲーム中のタイマー表示を更新
  void updateTimer(double time) {
    _stateText.text = 'TIME: ${time.toStringAsFixed(1)}';
    
    // 時間に応じて色を変更（視覚的フィードバック）
    Color textColor = Colors.white;
    if (time <= 2.0) {
      textColor = Colors.red;
    } else if (time <= 3.0) {
      textColor = Colors.orange;
    }
    
    _stateText.textRenderer = TextPaint(
      style: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// ゲームオーバー画面のUIを表示
  void showGameOverScreen() {
    _stateText.text = 'GAME OVER\nTAP TO RESTART';
    _stateText.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.red,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// カスタムテキスト表示
  void displayText(String text, {Color? color, double? fontSize}) {
    _stateText.text = text;
    _stateText.textRenderer = TextPaint(
      style: TextStyle(
        color: color ?? Colors.white,
        fontSize: fontSize ?? 24,
        fontWeight: FontWeight.bold,
      ),
    );
    
    onTextUpdate?.call(text);
  }

  /// 現在のテキストを取得
  String get currentText => _stateText.text;
}