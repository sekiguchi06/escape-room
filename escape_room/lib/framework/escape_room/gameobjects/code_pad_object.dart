import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'interactable_game_object.dart';
import '../strategies/interaction_strategy.dart';
import '../core/interaction_result.dart';
import '../components/dual_sprite_component.dart';

/// コードパッドオブジェクト - 数字入力パズル
/// 🎯 目的: 4桁数字の入力が必要なパズルギミック
class CodePadObject extends InteractableGameObject {
  final String correctCode;
  final String rewardItemId;
  
  CodePadObject({
    required Vector2 position, 
    required Vector2 size,
    this.correctCode = '2859',  // デフォルトの正解コード
    this.rewardItemId = 'puzzle_key',  // 報酬アイテム
  }) : super(objectId: 'code_pad') {
    this.position = position;
    this.size = size;
  }
  
  @override
  Future<void> initialize() async {
    // コードパッド専用戦略を設定
    setInteractionStrategy(CodePadPuzzleStrategy(
      correctCode: correctCode,
      successMessage: 'コードが正解です！隠し扉が開きました',
      failureMessage: 'コードが間違っています。正しい4桁の数字を入力してください',
      rewardItemId: rewardItemId,
    ));
  }
  
  @override
  Future<void> loadAssets() async {
    // DualSpriteComponentで画像管理
    dualSpriteComponent = DualSpriteComponent(
      inactiveAssetPath: 'hotspots/code_pad_inactive.png',
      activeAssetPath: 'hotspots/code_pad_active.png',
      fallbackColor: Colors.blue.shade700,
      componentSize: size,
    );
  }
  
  @override
  void onActivated() {
    debugPrint('CodePad activated: puzzle solved successfully');
  }
}

/// コードパッド専用のパズル戦略
/// 🎯 目的: 数字入力による認証パズル（モーダル表示対応）
class CodePadPuzzleStrategy implements InteractionStrategy {
  final String correctCode;
  final String successMessage;
  final String failureMessage;
  final String? rewardItemId;
  bool _isSolved = false;
  
  CodePadPuzzleStrategy({
    required this.correctCode,
    required this.successMessage,
    required this.failureMessage,
    this.rewardItemId,
  });
  
  @override
  bool canInteract() {
    return !_isSolved;
  }
  
  @override
  InteractionResult execute() {
    if (!canInteract()) {
      return InteractionResult.failure('既に解決済みです');
    }
    
    // パズルモーダルを表示する必要があることを示す
    // 実際のモーダル表示とコード検証は上位レイヤーで処理
    return InteractionResult.success(
      message: 'コードパッドにアクセスしています...',
      shouldActivate: false,  // まだ解決していない
    );
  }
  
  /// コード検証処理（モーダルからの入力用）
  InteractionResult validateCode(String inputCode) {
    if (!canInteract()) {
      return InteractionResult.failure('既に解決済みです');
    }
    
    if (inputCode == correctCode) {
      _isSolved = true;
      
      // 報酬アイテムを決定
      final itemsToAdd = <String>[];
      if (rewardItemId != null) {
        itemsToAdd.add(rewardItemId!);
      }
      
      return InteractionResult.success(
        message: successMessage,
        itemsToAdd: itemsToAdd,
        shouldActivate: true,
      );
    } else {
      return InteractionResult.failure(failureMessage);
    }
  }
  
  @override
  String get strategyName => 'CodePadPuzzle';
  
  /// 正解コードを取得（モーダル表示用）
  String get expectedCode => correctCode;
  
  /// 状態リセット（テスト用）
  void reset() {
    _isSolved = false;
  }
}

/// CodePadObject拡張メソッド
extension CodePadObjectExtensions on CodePadObject {
  /// CodePadPuzzleStrategyにアクセスするためのヘルパー
  CodePadPuzzleStrategy? getCodePadStrategy() {
    // performInteractionを使って間接的に戦略の状態を確認
    if (!canInteract()) return null;
    
    // 実際のStrategyインスタンスにアクセスする必要がある場合は
    // この実装では制限があるため、代替アプローチを使用
    return CodePadPuzzleStrategy(
      correctCode: correctCode,
      successMessage: 'コードが正解です！隠し扉が開きました',
      failureMessage: 'コードが間違っています。正しい4桁の数字を入力してください',
      rewardItemId: rewardItemId,
    );
  }
}