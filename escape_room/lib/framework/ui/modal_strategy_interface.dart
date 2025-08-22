import 'package:flame/components.dart';
import 'modal_config.dart';
import 'number_puzzle_input_component.dart';

/// モーダル表示戦略インターフェース
/// Strategy Pattern適用による表示方法の抽象化
abstract interface class ModalDisplayStrategy {
  /// 戦略名取得
  String get strategyName;

  /// 対応可能なモーダルタイプ判定
  bool canHandle(ModalType type);

  /// モーダルUI要素作成
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  );

  /// 入力検証（パズル等）
  bool validateInput(String input, ModalConfig config);

  /// 確認処理実行
  void executeConfirm(ModalConfig config, String? userInput);
}

/// モーダルUI要素格納クラス
/// Component-based設計準拠
class ModalUIElements {
  late RectangleComponent background;
  late RectangleComponent modalPanel;
  late TextComponent titleText;
  late TextComponent contentText;
  RectangleComponent? imageComponent;
  NumberPuzzleInputComponent? puzzleInput;
}
