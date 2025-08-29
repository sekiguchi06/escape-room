import 'package:flutter/material.dart';
import 'base_puzzle.dart';

/// 色変化タップパズル - 全ての円を同じ色にする
class ColorTapPuzzle extends BasePuzzle {
  const ColorTapPuzzle({
    super.key,
    super.onSuccess,
    super.onCancel,
  }) : super(
          title: '色合わせパズル',
          description: 'すべての円を同じ色にしてください',
        );

  @override
  String get puzzleType => 'color_tap';

  @override
  int get difficulty => 1;

  @override
  int get estimatedDuration => 30;

  @override
  State<ColorTapPuzzle> createState() => _ColorTapPuzzleState();
}

class _ColorTapPuzzleState extends State<ColorTapPuzzle> {
  static const List<Color> _colors = [
    Colors.red,
    Colors.blue,
  ];

  late List<int> _circleColors;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _resetPuzzle();
  }

  void _resetPuzzle() {
    // 固定パターンで初期化（解けることが保証された配置）
    // パターン: 0=赤, 1=青
    // 0 1 0
    // 1 0 1
    // 0 1 0
    _circleColors = [
      0, 1, 0,  // 上段
      1, 0, 1,  // 中段
      0, 1, 0   // 下段
    ];
  }

  void _onCircleTapped(int index) {
    setState(() {
      // タップした円とその上下左右の円の色を次の色に変える
      final row = index ~/ 3;
      final col = index % 3;
      
      _changeColor(index); // 中央
      if (row > 0) _changeColor(index - 3); // 上
      if (row < 2) _changeColor(index + 3); // 下
      if (col > 0) _changeColor(index - 1); // 左
      if (col < 2) _changeColor(index + 1); // 右
    });

    _checkWin();
  }

  void _changeColor(int index) {
    _circleColors[index] = (_circleColors[index] + 1) % _colors.length;
  }

  void _checkWin() {
    if (_circleColors.every((color) => color == _circleColors.first)) {
      final duration = DateTime.now().difference(_startTime).inSeconds;
      
      // 成功アニメーション
      _showSuccessDialog(duration);
    }
  }

  void _showHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.amber),
            SizedBox(width: 8),
            Text('ヒント'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '解法手順:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text('1. 中央（真ん中）をタップ'),
              SizedBox(height: 8),
              Text('2. 左上の角をタップ'),
              SizedBox(height: 8),
              Text('3. 右下の角をタップ'),
              SizedBox(height: 12),
              Text(
                'これで全ての円が同じ色になります！',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              SizedBox(height: 8),
              Text(
                'ヒント: 円をタップすると、その円と上下左右の円の色が変わります',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(int duration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber),
            SizedBox(width: 8),
            Text('クリア！'),
          ],
        ),
        content: Text('完了時間: ${duration}秒'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSuccess?.call();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _startTime = DateTime.now();
                _resetPuzzle();
              });
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHint,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _startTime = DateTime.now();
                _resetPuzzle();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 説明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  widget.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // パズル本体
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _onCircleTapped(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colors[_circleColors[index]],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black26,
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // ヒント
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'ヒント: 円をタップすると、その円と上下左右の円の色が変わります',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}