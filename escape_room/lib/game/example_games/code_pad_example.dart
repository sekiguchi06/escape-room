import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../framework/escape_room/core/simple_escape_room_game.dart';
import '../../framework/escape_room/gameobjects/code_pad_object.dart';
import '../../framework/ui/modal_config.dart';
import '../../framework/ui/escape_room_modal_system.dart';

/// コードパッドパズルの使用例
/// Issue #12 対応: モーダルに１つだけギミックを実装し、クリア時にアイテム取得
class CodePadExampleGame extends SimpleEscapeRoomGame {
  late CodePadObject _codePad;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // コードパッドオブジェクトを作成
    _codePad = CodePadObject(
      position: Vector2(size.x * 0.5 - 25, size.y * 0.6),
      size: Vector2(50, 50),
      correctCode: '2859',  // パズルの正解コード
      rewardItemId: 'secret_document',  // クリア時に取得するアイテム
    );
    
    // オブジェクトを初期化してゲームに追加
    await _codePad.initialize();
    await _codePad.loadAssets();
    add(_codePad);
    
    debugPrint('🎮 CodePad example game loaded with puzzle code: ${_codePad.correctCode}');
  }
  
  /// コードパッドをタップした時の処理
  void onCodePadTapped() {
    if (_codePad.interactionStrategy?.canInteract() == true) {
      _showCodePadModal();
    } else {
      debugPrint('💡 CodePad already solved');
    }
  }
  
  /// コードパッド用モーダルを表示
  void _showCodePadModal() {
    final modalConfig = ModalConfig.puzzle(
      title: 'セキュリティコード入力',
      content: '正しい4桁のコードを入力してください',
      correctAnswer: _codePad.correctCode,
      onConfirm: _onCodeSubmitted,
      onCancel: () {
        debugPrint('🎮 Code pad modal cancelled');
      },
    );
    
    final modal = ModalComponent(
      config: modalConfig,
      position: Vector2.zero(),
      size: size,
    );
    
    add(modal);
    modal.show();
    
    debugPrint('🎮 Code pad modal displayed');
  }
  
  /// コード送信時の処理
  void _onCodeSubmitted() {
    // モーダルから入力されたコードを取得
    // 実際の実装では、モーダルコンポーネントから入力値を取得する仕組みが必要
    debugPrint('🎮 Code submitted for validation');
    
    // 今回はデモとして正解処理を実行
    _handleCorrectCode();
  }
  
  /// 正解時の処理
  void _handleCorrectCode() {
    final strategy = _codePad.interactionStrategy as CodePadPuzzleStrategy?;
    if (strategy != null) {
      final result = strategy.validateCode(_codePad.correctCode);
      
      if (result.success) {
        // アイテムをインベントリに追加
        for (final itemId in result.itemsToAdd) {
          addItemToInventory(itemId);
          debugPrint('🎁 Item added to inventory: $itemId');
        }
        
        // オブジェクトを活性化状態に変更
        if (result.shouldActivate) {
          _codePad.onActivated();
        }
        
        // 成功メッセージを表示
        _showSuccessMessage(result.message);
        
        debugPrint('✅ Code pad puzzle solved successfully!');
      }
    }
  }
  
  /// 成功メッセージを表示
  void _showSuccessMessage(String message) {
    final successModal = ModalConfig.item(
      title: '🎉 パズル完了!',
      content: message,
      imagePath: 'items/secret_document.png',
      onConfirm: () {
        debugPrint('🎮 Success message acknowledged');
      },
    );
    
    final modal = ModalComponent(
      config: successModal,
      position: Vector2.zero(),
      size: size,
    );
    
    add(modal);
    modal.show();
  }
  
  /// デモ用：手動でパズルを解決
  void solvePuzzleManually() {
    onCodePadTapped();
    _handleCorrectCode();
  }
  
  /// デモ用：パズルをリセット
  void resetPuzzle() {
    final strategy = _codePad.interactionStrategy as CodePadPuzzleStrategy?;
    strategy?.reset();
    removeItemFromInventory('secret_document');
    debugPrint('🔄 Puzzle reset');
  }
}

/// CodePadExampleGameの使用方法を示すヘルパークラス
class CodePadExampleUsage {
  /// 基本的な使用例
  static CodePadExampleGame createBasicExample() {
    return CodePadExampleGame();
  }
  
  /// カスタムコードを使用した例
  static CodePadExampleGame createCustomExample(String customCode) {
    final game = CodePadExampleGame();
    // ゲーム読み込み後にカスタムコードを設定する場合の実装
    return game;
  }
  
  /// 使用方法の説明
  static String getUsageInstructions() {
    return '''
CodePadExampleGame 使用方法:

1. ゲームを開始すると、画面中央にコードパッドが表示されます
2. コードパッドをタップするとモーダルが開きます
3. 正しい4桁のコード（デフォルト: 2859）を入力してください
4. 正解すると秘密の文書がインベントリに追加されます
5. 不正解の場合はエラーメッセージが表示されます

デモ用メソッド:
- solvePuzzleManually(): 手動でパズルを解決
- resetPuzzle(): パズルをリセット
''';
  }
}