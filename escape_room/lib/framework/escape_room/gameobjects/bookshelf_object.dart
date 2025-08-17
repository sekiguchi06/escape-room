import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'interactable_game_object.dart';
import '../strategies/item_provider_strategy.dart';
import '../components/dual_sprite_component.dart';
import '../../ui/japanese_message_system.dart';

/// 本棚オブジェクト - AI生成画像使用
/// 🎯 目的: 鍵アイテムの提供
class BookshelfObject extends InteractableGameObject {
  BookshelfObject({required Vector2 position, required Vector2 size}) 
      : super(objectId: 'bookshelf') {
    this.position = position;
    this.size = size;
  }
  
  @override
  Future<void> initialize() async {
    // アイテム提供戦略を設定
    setInteractionStrategy(ItemProviderStrategy(
      itemId: 'key',
      message: JapaneseMessageSystem.getMessage('bookshelf_discovery_message'),
    ));
  }
  
  @override
  Future<void> loadAssets() async {
    // DualSpriteComponentで画像管理
    dualSpriteComponent = DualSpriteComponent(
      inactiveAssetPath: 'hotspots/prison_bucket.png',
      activeAssetPath: 'hotspots/bookshelf_empty.png',
      fallbackColor: Colors.brown,
      componentSize: size,
    );
  }
  
  @override
  void onActivated() {
    debugPrint('Bookshelf activated: key item added');
  }
}