import 'package:flutter/material.dart';
import '../../framework/audio/integrated_audio_manager.dart';
import '../../framework/audio/enhanced_sfx_system.dart';

/// パズルモーダルダイアログ
class PuzzleModalDialog extends StatefulWidget {
  final String title;
  final String description;
  final String correctAnswer;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const PuzzleModalDialog({
    super.key,
    required this.title,
    required this.description,
    required this.correctAnswer,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<PuzzleModalDialog> createState() => _PuzzleModalDialogState();
}

class _PuzzleModalDialogState extends State<PuzzleModalDialog> {
  final TextEditingController _controller = TextEditingController();
  String _inputValue = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalWidth = screenWidth * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: modalWidth,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber[700]!, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
              '🧩 ${widget.title}',
              style: TextStyle(
                color: Colors.amber[200],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 説明文
            Text(
              widget.description,
              style: TextStyle(color: Colors.brown[100], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 入力フィールド
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber[600]!, width: 2),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _inputValue = value;
                  });
                },
                style: TextStyle(
                  color: Colors.brown[100],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '答えを入力してください...',
                  hintStyle: TextStyle(color: Colors.brown[300], fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // キャンセルボタン
                ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('キャンセル'),
                ),

                // 確認ボタン
                ElevatedButton(
                  onPressed: _inputValue.isNotEmpty ? _checkAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.brown[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('確認'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer() {
    final isCorrect =
        _inputValue.trim().toLowerCase() ==
        widget.correctAnswer.trim().toLowerCase();

    if (isCorrect) {
      debugPrint('🧩 パズル正解！答え: ${widget.correctAnswer}');
      IntegratedAudioManager().playUserActionSound(
        UserActionType.puzzleSuccess,
      );
      widget.onSuccess();
    } else {
      debugPrint('🧩 パズル不正解。入力: $_inputValue, 正解: ${widget.correctAnswer}');
      IntegratedAudioManager().playUserActionSound(UserActionType.errorAction);

      // 不正解時の視覚フィードバック
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('答えが違います。もう一度考えてみてください。'),
          backgroundColor: Colors.red[800],
          duration: const Duration(seconds: 2),
        ),
      );

      // 入力フィールドをクリア
      _controller.clear();
      setState(() {
        _inputValue = '';
      });
    }
  }
}
