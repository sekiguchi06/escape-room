import 'package:flame/components.dart';
import 'package:flame/game.dart';
import '../gameobjects/interactable_game_object.dart';
import '../gameobjects/bookshelf_object.dart';
import '../gameobjects/safe_object.dart';
import '../gameobjects/box_object.dart';

/// Escape Room Game - 新アーキテクチャ版
/// 🎯 目的: Strategy Patternベースのゲーム管理
class EscapeRoomGame extends FlameGame {
  final List<InteractableGameObject> gameObjects = [];
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _spawnGameObjects();
  }
  
  Future<void> _spawnGameObjects() async {
    // Strategy Pattern + Component組み合わせでオブジェクト生成
    final bookshelf = BookshelfObject(
      position: Vector2(50, 300),
      size: Vector2(100, 150),
    );
    
    final safe = SafeObject(
      position: Vector2(300, 200),
      size: Vector2(80, 100),
    );
    
    final box = BoxObject(
      position: Vector2(200, 400),
      size: Vector2(120, 80),
    );
    
    gameObjects.addAll([bookshelf, safe, box]);
    
    for (final obj in gameObjects) {
      add(obj);
    }
    
    print('EscapeRoomGame: ${gameObjects.length} objects loaded');
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
}