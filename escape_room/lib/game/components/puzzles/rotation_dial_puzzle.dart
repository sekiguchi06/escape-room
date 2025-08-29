import 'package:flutter/material.dart';
import 'base_puzzle.dart';
import 'dial_data.dart';
import 'rotation_dial_ui.dart';

/// 回転ダイヤルパズル - 複数のダイヤルを回して正しい組み合わせにする
class RotationDialPuzzle extends BasePuzzle {
  const RotationDialPuzzle({
    super.key,
    super.onSuccess,
    super.onCancel,
  }) : super(
          title: '回転ダイヤルパズル',
          description: 'すべてのダイヤルを回して正しい組み合わせにしてください',
        );

  @override
  String get puzzleType => 'rotation_dial';

  @override
  int get difficulty => 2;

  @override
  int get estimatedDuration => 90;

  @override
  State<RotationDialPuzzle> createState() => _RotationDialPuzzleState();
}

class _RotationDialPuzzleState extends State<RotationDialPuzzle>
    with TickerProviderStateMixin, RotationDialUI {
  late List<DialData> _dials;
  late List<AnimationController> _animationControllers;
  late DateTime _startTime;

  // シンボルセット
  static const List<List<String>> _symbolSets = [
    ['♠', '♥', '♦', '♣'],
    ['☀', '☽', '★', '✦'],
    ['△', '□', '○', '◇'],
    ['Ⅰ', 'Ⅱ', 'Ⅲ', 'Ⅳ'],
    ['α', 'β', 'γ', 'δ'],
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializePuzzle();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializePuzzle() {
    // 3つのダイヤルを固定パターンで作成
    _dials = [
      DialData(
        symbols: _symbolSets[0], // ['♠', '♥', '♦', '♣']
        currentIndex: 0,  // 初期位置: ♠
        correctIndex: 2,  // 正解: ♦
      ),
      DialData(
        symbols: _symbolSets[1], // ['☀', '☽', '★', '✦']
        currentIndex: 1,  // 初期位置: ☽
        correctIndex: 3,  // 正解: ✦
      ),
      DialData(
        symbols: _symbolSets[2], // ['△', '□', '○', '◇']
        currentIndex: 3,  // 初期位置: ◇
        correctIndex: 1,  // 正解: □
      ),
    ];

    // アニメーション用のコントローラーを初期化
    _animationControllers = List.generate(3, (index) => 
        AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        ));
  }

  void _rotateDial(int dialIndex) async {
    if (_animationControllers[dialIndex].isAnimating) return;

    setState(() {
      _dials[dialIndex].currentIndex = 
          (_dials[dialIndex].currentIndex + 1) % _dials[dialIndex].symbols.length;
    });

    // 回転アニメーション
    await _animationControllers[dialIndex].forward();
    _animationControllers[dialIndex].reset();

    _checkWin();
  }

  void _checkWin() {
    bool allCorrect = true;
    for (final dial in _dials) {
      if (dial.currentIndex != dial.correctIndex) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      final duration = DateTime.now().difference(_startTime).inSeconds;
      _showSuccessDialog(duration);
    }
  }

  void _showSuccessDialog(int duration) {
    showSuccessDialog(
      context: context,
      duration: duration,
      onSuccess: widget.onSuccess,
      onRestart: () {
        setState(() {
          _startTime = DateTime.now();
          for (final controller in _animationControllers) {
            controller.dispose();
          }
          _initializePuzzle();
        });
      },
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _startTime = DateTime.now();
                for (final controller in _animationControllers) {
                  controller.dispose();
                }
                _initializePuzzle();
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
            const SizedBox(height: 40),
            
            // 正解のヒント表示
            buildCorrectAnswerHint(_dials),
            
            const SizedBox(height: 40),
            
            // ダイヤルエリア
            Expanded(
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _dials.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dial = entry.value;
                      
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width * 0.9) / 3 - 16,
                        height: (MediaQuery.of(context).size.width * 0.9) / 3 - 16,
                        child: buildDial(
                          index: index,
                          dial: dial,
                          onRotate: _rotateDial,
                          context: context,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 進捗表示
            buildProgressIndicator(_dials),
            
            const SizedBox(height: 20),
            
            // ヒント
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'ヒント: ダイヤルをタップして回転させ、上部の正解と同じ組み合わせにしてください',
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