import 'package:flame/components.dart';
import '../number_puzzle_input_component.dart';

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