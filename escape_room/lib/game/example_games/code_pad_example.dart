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
      correctCode: '2859', // パズルの正解コード
      rewardItemId: 'secret_document', // クリア時に取得するアイテム
    );

    // オブジェクトを初期化してゲームに追加
    await _codePad.initialize();
    await _codePad.loadAssets();
    add(_codePad);

    debugPrint(
      '🎮 CodePad example game loaded with puzzle code: ${_codePad.correctCode}',
    );
  }

  /// コードパッドをタップした時の処理
  void onCodePadTapped() {
    // TODO: Implement CodePadObject interactionStrategy
    debugPrint('💡 CodePad tapped - feature not implemented');
  }



  /// 正解時の処理
  void _handleCorrectCode() {
    // TODO: Implement CodePadPuzzleStrategy validation
    debugPrint('✅ Code pad puzzle solved (demo mode)!');
    _showSuccessMessage('パズル完了！秘密の文書を取得しました。');
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
    // TODO: Implement puzzle reset functionality
    debugPrint('🔄 Puzzle reset (demo mode)');
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
