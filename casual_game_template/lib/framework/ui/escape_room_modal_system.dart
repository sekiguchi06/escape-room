import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ui_system.dart';
import 'modal_config.dart';
import 'modal_display_strategy.dart';


/// モーダルコンポーネント（Strategy Pattern適用）
class ModalComponent extends PositionComponent with TapCallbacks {
  final ModalConfig config;
  final ModalDisplayContext _displayContext = ModalDisplayContext();
  late ModalUIElements _uiElements;
  late ButtonUIComponent _confirmButton;
  late ButtonUIComponent? _cancelButton;
  ModalDisplayStrategy? _strategy;
  
  bool _isVisible = false;
  
  ModalComponent({
    required this.config,
    super.position,
    super.size,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Strategy Pattern初期化
    _displayContext.initializeDefaultStrategies();
    _strategy = _displayContext.selectStrategy(config.type);
    
    if (_strategy != null) {
      _setupModalUI();
    } else {
      debugPrint('❌ No strategy found for modal type: ${config.type}');
    }
  }
  
  /// モーダル表示
  void show() {
    _isVisible = true;
    debugPrint('📱 Modal shown: ${config.title}');
  }
  
  /// モーダル非表示
  void hide() {
    if (!_isVisible) return;
    _isVisible = false;
    removeFromParent();
    debugPrint('📱 Modal hidden: ${config.title}');
  }
  
  /// モーダルUI設定（Strategy Pattern適用）
  void _setupModalUI() {
    if (_strategy == null) return;
    
    // パネルサイズ計算
    final panelSize = Vector2(size.x * 0.8, size.y * 0.6);
    final panelPosition = Vector2(
      (size.x - panelSize.x) / 2,
      (size.y - panelSize.y) / 2,
    );
    
    // Strategy Patternで UI要素を構築
    _uiElements = _strategy!.createUIElements(
      config,
      size,
      panelPosition,
      panelSize,
    );
    
    // UI要素を追加
    add(_uiElements.background);
    add(_uiElements.modalPanel);
    add(_uiElements.titleText);
    add(_uiElements.contentText);
    
    // 画像コンポーネントを追加（存在する場合）
    if (_uiElements.imageComponent != null) {
      add(_uiElements.imageComponent!);
    }
    
    if (_uiElements.puzzleInput != null) {
      add(_uiElements.puzzleInput!);
    }
    
    // ボタン追加
    _addConfirmButton(panelPosition, panelSize);
    if (config.onCancel != null) {
      _addCancelButton(panelPosition, panelSize);
    }
  }
  
  /// 確認ボタン追加（Strategy Pattern適用）
  void _addConfirmButton(Vector2 panelPosition, Vector2 panelSize) {
    final buttonSize = Vector2(100, 40);
    final buttonPosition = Vector2(
      panelPosition.x + panelSize.x - buttonSize.x - 20,
      panelPosition.y + panelSize.y - buttonSize.y - 20,
    );
    
    _confirmButton = ButtonUIComponent(
      text: 'OK',
      position: buttonPosition,
      size: buttonSize,
      onPressed: () {
        if (_strategy != null) {
          String? userInput;
          if (_uiElements.puzzleInput != null) {
            userInput = _uiElements.puzzleInput!.getCurrentInput();
          }
          
          // Strategy Pattern適用での確認処理
          _strategy!.executeConfirm(config, userInput);
          hide();
        }
      },
    );
    add(_confirmButton);
  }
  
  /// キャンセルボタン追加
  void _addCancelButton(Vector2 panelPosition, Vector2 panelSize) {
    final buttonSize = Vector2(100, 40);
    final buttonPosition = Vector2(
      panelPosition.x + panelSize.x - 220, // OK button左側
      panelPosition.y + panelSize.y - buttonSize.y - 20,
    );
    
    _cancelButton = ButtonUIComponent(
      text: 'キャンセル',
      position: buttonPosition,
      size: buttonSize,
      onPressed: () {
        config.onCancel?.call();
        hide();
      },
    );
    add(_cancelButton!);
  }
  
  
  @override
  void onTapUp(TapUpEvent event) {
    // 背景タップでモーダルを閉じる
    final localPosition = event.localPosition;
    if (!_uiElements.modalPanel.containsLocalPoint(localPosition - _uiElements.modalPanel.position)) {
      config.onCancel?.call();
      hide();
    }
    // Flame公式: continuePropagationを設定しないことでイベント伝播を停止
  }
  
  /// モーダルが表示中かチェック
  bool get isVisible => _isVisible;
}



