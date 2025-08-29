/// ダイヤルのデータモデル
class DialData {
  final List<String> symbols;
  int currentIndex;
  final int correctIndex;

  DialData({
    required this.symbols,
    required this.currentIndex,
    required this.correctIndex,
  });
}