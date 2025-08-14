import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import '../core/base_game_object.dart';
import '../core/interactable_interface.dart';
import '../core/interaction_result.dart';
import '../strategies/interaction_strategy.dart';
import '../components/dual_sprite_component.dart';

/// インタラクション可能ゲームオブジェクト
/// 🎯 目的: 戦略パターンを使用したインタラクション制御
class InteractableGameObject extends BaseGameObject implements InteractableInterface {
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
    
    debugPrint('Loaded $objectId successfully');
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
      return InteractionResult.failure('インタラクション戦略が設定されていません');
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
      
      // UI表示は後フェーズで実装
      if (result.message.isNotEmpty) {
        print('Message: ${result.message}');
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