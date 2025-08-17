import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import '../core/base_game_object.dart';
import '../core/interactable_interface.dart';
import '../core/interaction_result.dart';
import '../strategies/interaction_strategy.dart';
import '../strategies/puzzle_strategy.dart';
import '../components/dual_sprite_component.dart';
import '../core/escape_room_game.dart';
import '../../ui/japanese_message_system.dart';

/// インタラクション可能ゲームオブジェクト
/// 🎯 目的: 戦略パターンを使用したインタラクション制御
class InteractableGameObject extends BaseGameObject with TapCallbacks implements InteractableInterface {
  // コンポーネント
  DualSpriteComponent? dualSpriteComponent;
  
  // 戦略
  InteractionStrategy? _interactionStrategy;
  
  // 状態
  bool isActivated = false;
  
  
  InteractableGameObject({required super.objectId});
  
  /// 戦略設定
  void setInteractionStrategy(InteractionStrategy strategy) {
    _interactionStrategy = strategy;
  }
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    debugPrint('Loading $objectId ($runtimeType)');
    
    // サブクラスで実装される初期化処理
    await initialize();
    await loadAssets();
    setupComponents();
    
    // 戦略にゲーム参照を設定（ここで実行）
    _setupStrategyGameReference();
    
    debugPrint('Loaded $objectId successfully');
  }
  
  /// 戦略にゲーム参照を設定
  void _setupStrategyGameReference() {
    if (_interactionStrategy is PuzzleStrategy) {
      final game = findGame();
      if (game is EscapeRoomGame) {
        (_interactionStrategy as PuzzleStrategy).setGame(game);
      }
    }
  }
  
  /// 初期化処理（サブクラスでオーバーライド）
  Future<void> initialize() async {}
  
  /// アセット読み込み（サブクラスでオーバーライド）
  Future<void> loadAssets() async {}
  
  /// コンポーネント設定（サブクラスでオーバーライド）
  void setupComponents() {
    if (dualSpriteComponent != null) {
      add(dualSpriteComponent!);
      debugPrint('$objectId: DualSpriteComponent added');
    }
  }
  
  @override
  bool canInteract() {
    return _interactionStrategy?.canInteract() ?? false;
  }
  
  @override
  InteractionResult performInteraction() {
    if (_interactionStrategy == null) {
      return InteractionResult.failure(JapaneseMessageSystem.getMessage('interaction_strategy_not_set'));
    }
    
    final result = _interactionStrategy!.execute();
    
    if (result.success && result.shouldActivate && !isActivated) {
      activate();
    }
    
    return result;
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    if (canInteract()) {
      final result = performInteraction();
      
      // インタラクション結果を処理
      if (result.success) {
        // オブジェクト操作をコントローラーに記録
        final game = findGame();
        if (game is EscapeRoomGame) {
          game.controller.recordObjectInteraction(objectId);
        }
        
        // アイテムをインベントリに追加
        for (final itemId in result.itemsToAdd) {
          if (game is EscapeRoomGame) {
            game.addItemToInventory(itemId);
            // UIManagerでインベントリ表示を更新
            game.uiManager.refreshInventoryUI();
          } else {
            debugPrint('⚠️ Warning: Could not access EscapeRoomGame for inventory');
          }
        }
        
        // モーダル表示
        if (result.message.isNotEmpty) {
          if (game is EscapeRoomGame) {
            game.showInteractionModal(objectId, result.message);
          }
        }
      } else {
        debugPrint('❌ Interaction failed: ${result.message}');
      }
    }
  }
  
  /// アクティベーション処理
  void activate() {
    if (isActivated) return;
    
    isActivated = true;
    debugPrint('Activating $objectId');
    
    // DualSpriteComponentでの状態切り替え
    dualSpriteComponent?.switchToActive();
    
    onActivated();
  }
  
  /// アクティベーション時の追加処理（サブクラスでオーバーライド）
  void onActivated() {}
  
  @override
  Map<String, dynamic> getState() {
    final baseState = super.getState();
    try {
      baseState.addAll({
        'isActivated': isActivated,
        'strategyName': _interactionStrategy?.strategyName ?? 'none',
        'currentSprite': dualSpriteComponent?.hasSprites == true ? 'loaded' : 'not_loaded',
      });
    } catch (e) {
      baseState.addAll({
        'isActivated': isActivated,
        'strategyName': _interactionStrategy?.strategyName ?? 'none',
        'currentSprite': 'not_loaded',
      });
    }
    return baseState;
  }
  
  @override
  void onRemove() {
    debugPrint('Removing $objectId');
    if (dualSpriteComponent != null) {
      remove(dualSpriteComponent!);
    }
    super.onRemove();
  }
}