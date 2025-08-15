import 'package:flutter/foundation.dart';
import '../gameobjects/interactable_game_object.dart';
import '../../components/inventory_manager.dart';

/// Escape Room Game Controller - ゲームロジック専任
/// レイヤー分離原則に基づく設計
class EscapeRoomGameController {
  final List<InteractableGameObject> gameObjects = [];
  final InventoryManager inventoryManager;

  EscapeRoomGameController({
    required this.inventoryManager,
  });

  /// アイテムをインベントリに追加
  bool addItemToInventory(String itemId) {
    final success = inventoryManager.addItem(itemId);
    if (success) {
      debugPrint('🎒 Item added to inventory: $itemId');
    } else {
      debugPrint('❌ Failed to add item to inventory: $itemId');
    }
    return success;
  }

  /// アイテムをインベントリから削除
  bool removeItemFromInventory(String itemId) {
    final success = inventoryManager.removeItem(itemId);
    if (success) {
      debugPrint('🗑️ Item removed from inventory: $itemId');
    }
    return success;
  }

  /// インベントリ内のアイテム確認
  bool hasItemInInventory(String itemId) {
    return inventoryManager.hasItem(itemId);
  }

  /// GameObject検索（型による）
  T? findGameObject<T extends InteractableGameObject>() {
    return gameObjects.whereType<T>().firstOrNull;
  }

  /// GameObject検索（複数）
  List<T> findGameObjects<T extends InteractableGameObject>() {
    return gameObjects.whereType<T>().toList();
  }

  /// 全オブジェクト状態取得（デバッグ用）
  Map<String, dynamic> getAllObjectStates() {
    final states = <String, dynamic>{};
    for (final obj in gameObjects) {
      states[obj.objectId] = obj.getState();
    }
    return states;
  }

  /// GameObjectリストに追加
  void addGameObject(InteractableGameObject gameObject) {
    gameObjects.add(gameObject);
  }

  /// GameObjectリストから削除
  void removeGameObject(InteractableGameObject gameObject) {
    gameObjects.remove(gameObject);
  }
}