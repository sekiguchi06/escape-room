import 'package:flutter/material.dart';
import 'base_puzzle.dart';

/// 最もシンプルなタップテストパズル - デバッグ用
class SimpleTapTestPuzzle extends BasePuzzle {
  const SimpleTapTestPuzzle({
    super.key,
    super.onSuccess,
    super.onCancel,
  }) : super(
          title: 'タップテストパズル',
          description: 'デバッグ用：3つのボタンを合計3回タップしてください',
        );

  @override
  String get puzzleType => 'simple_tap_test';

  @override
  int get difficulty => 1;

  @override
  int get estimatedDuration => 10;

  @override
  State<SimpleTapTestPuzzle> createState() => _SimpleTapTestPuzzleState();
}

class _SimpleTapTestPuzzleState extends State<SimpleTapTestPuzzle> {
  int _tapCount = 0;
  String _lastTapped = '';

  void _onButtonTapped(String buttonName) {
    print('🔧 TAP TEST: Button $buttonName tapped');
    setState(() {
      _tapCount++;
      _lastTapped = buttonName;
    });
    
    if (_tapCount >= 3) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            SizedBox(width: 8),
            Text('テスト成功！'),
          ],
        ),
        content: Text('${_tapCount}回タップしました。タップテストは正常に動作しています！'),
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
                _tapCount = 0;
                _lastTapped = '';
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
          onPressed: () {
            print('🔧 TAP TEST: Close button pressed');
            if (widget.onCancel != null) {
              widget.onCancel!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.description,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'タップ回数: $_tapCount',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_lastTapped.isNotEmpty)
              Text(
                '最後のタップ: $_lastTapped',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonTapped('A'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 60),
                  ),
                  child: const Text('ボタン A'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonTapped('B'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 60),
                  ),
                  child: const Text('ボタン B'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonTapped('C'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(100, 60),
                  ),
                  child: const Text('ボタン C'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                const Text(
                  '🎯 目標：合計3回タップするとクリア！',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'どのボタンを何回押してもOKです',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (_tapCount > 0)
                  Text(
                    'あと${3 - _tapCount}回タップで完成！',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}