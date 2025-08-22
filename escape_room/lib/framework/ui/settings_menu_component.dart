import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'ui_layer_priority.dart';
import 'text_ui_component.dart';
import 'button_ui_component.dart';

/// 設定メニューUIコンポーネント
/// ゲーム設定の変更を提供するモーダルメニュー
class SettingsMenuComponent extends PositionComponent {
  late RectangleComponent _background;
  late TextUIComponent _titleText;
  final List<ButtonUIComponent> _buttons = [];

  final void Function(String difficulty)? onDifficultyChanged;
  final void Function()? onClosePressed;

  SettingsMenuComponent({this.onDifficultyChanged, this.onClosePressed}) {
    size = Vector2(300, 400);
    // 設定メニューはモーダル内コンテンツとして高優先度
    priority = UILayerPriority.modal + 1;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 背景（不透明な白）
    _background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    add(_background);

    // タイトル
    _titleText = TextUIComponent(
      text: 'Settings',
      styleId: 'large',
      position: Vector2(size.x / 2, 40),
    );
    _titleText.anchor = Anchor.center;
    _titleText.setTextColor(Colors.black);
    add(_titleText);

    // 難易度変更ボタン
    _createDifficultyButtons();

    // 閉じるボタン
    final closeButton = ButtonUIComponent(
      text: 'Close',
      colorId: 'danger',
      position: Vector2(size.x / 2 - 60, size.y - 60),
      size: Vector2(120, 40),
      onPressed: () => onClosePressed?.call(),
    );
    _buttons.add(closeButton);
    add(closeButton);
  }

  void _createDifficultyButtons() {
    final difficulties = ['Easy', 'Default', 'Hard'];
    final buttonWidth = 80.0;
    final buttonHeight = 40.0;
    final spacing = 10.0;
    final totalWidth =
        difficulties.length * buttonWidth + (difficulties.length - 1) * spacing;
    final startX = (size.x - totalWidth) / 2;

    for (int i = 0; i < difficulties.length; i++) {
      final difficulty = difficulties[i];
      final button = ButtonUIComponent(
        text: difficulty,
        colorId: 'secondary',
        position: Vector2(startX + i * (buttonWidth + spacing), 150),
        size: Vector2(buttonWidth, buttonHeight),
        onPressed: () => onDifficultyChanged?.call(difficulty.toLowerCase()),
      );
      _buttons.add(button);
      add(button);
    }
  }

  /// 設定項目を追加
  void addSettingItem(
    String label,
    List<String> options,
    void Function(String) onChanged,
  ) {
    // 新しい設定項目のボタンを作成
    final buttonY = 200.0 + _buttons.length * 50.0;

    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      final button = ButtonUIComponent(
        text: option,
        colorId: 'secondary',
        position: Vector2(50 + i * 80, buttonY),
        size: Vector2(70, 30),
        onPressed: () => onChanged(option),
      );
      _buttons.add(button);
      add(button);
    }
  }

  /// ボタンの状態を更新
  void updateButtonState(String text, bool isSelected) {
    for (final button in _buttons) {
      if (button.text == text) {
        button.setColor(isSelected ? 'primary' : 'secondary');
        break;
      }
    }
  }

  @override
  void onRemove() {
    // ボタンのクリーンアップ
    for (final button in _buttons) {
      if (button.isMounted) {
        button.removeFromParent();
      }
    }
    _buttons.clear();
    super.onRemove();
  }
}
