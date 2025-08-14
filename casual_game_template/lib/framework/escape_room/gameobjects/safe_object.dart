import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'interactable_game_object.dart';
import '../strategies/puzzle_strategy.dart';
import '../components/dual_sprite_component.dart';

/// 金庫オブジェクト - AI生成画像使用
/// 🎯 目的: 鍵を必要とするパズル
class SafeObject extends InteractableGameObject {
  SafeObject({required Vector2 position, required Vector2 size}) 
      : super(objectId: 'safe') {
    this.position = position;
    this.size = size;
  }
  
  @override
  Future<void> initialize() async {
    // パズル戦略を設定
    setInteractionStrategy(PuzzleStrategy(
      requiredItemId: 'key',
      successMessage: '金庫が開いた！重要な書類を発見した',
      failureMessage: '金庫は鍵がかかっている。鍵が必要だ',
    ));
  }
  
  @override
  Future<void> loadAssets() async {
    // DualSpriteComponentで画像管理
    dualSpriteComponent = DualSpriteComponent(
      inactiveAssetPath: 'hotspots/safe_closed.png',
      activeAssetPath: 'hotspots/safe_opened.png',
      fallbackColor: Colors.grey.shade600,
      componentSize: size,
    );
  }
  
  @override
  void onActivated() {
    debugPrint('Safe activated: puzzle solved');
  }
}