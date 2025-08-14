import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'interactable_game_object.dart';
import '../strategies/item_provider_strategy.dart';
import '../components/dual_sprite_component.dart';

/// 箱オブジェクト - AI生成画像使用
/// 🎯 目的: 工具アイテムの提供
class BoxObject extends InteractableGameObject {
  BoxObject({required Vector2 position, required Vector2 size}) 
      : super(objectId: 'box') {
    this.position = position;
    this.size = size;
  }
  
  @override
  Future<void> initialize() async {
    // アイテム提供戦略を設定
    setInteractionStrategy(ItemProviderStrategy(
      itemId: 'tool',
      message: '箱の中から古い工具を発見した！',
    ));
  }
  
  @override
  Future<void> loadAssets() async {
    // DualSpriteComponentで画像管理
    dualSpriteComponent = DualSpriteComponent(
      inactiveAssetPath: 'hotspots/box_closed.png',
      activeAssetPath: 'hotspots/box_opened.png',
      fallbackColor: Colors.orange.shade600,
      componentSize: size,
    );
  }
  
  @override
  void onActivated() {
    debugPrint('Box activated: tool item added');
  }
}