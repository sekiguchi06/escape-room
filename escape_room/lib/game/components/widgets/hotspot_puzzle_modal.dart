import 'package:flutter/material.dart';

/// パズルモーダルダイアログ
class HotspotPuzzleModalDialog extends StatefulWidget {
  final String title;
  final String description;
  final String correctAnswer;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const HotspotPuzzleModalDialog({
    super.key,
    required this.title,
    required this.description,
    required this.correctAnswer,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<HotspotPuzzleModalDialog> createState() => _HotspotPuzzleModalDialogState();
}

class _HotspotPuzzleModalDialogState extends State<HotspotPuzzleModalDialog> {
  final TextEditingController _controller = TextEditingController();
  String _inputValue = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber[700]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.amber[200],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 説明
            Text(
              widget.description,
              style: TextStyle(color: Colors.brown[100], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 数字入力フィールド
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[600]!, width: 1),
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber[100],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '4桁の数字',
                  hintStyle: TextStyle(color: Colors.brown[400], fontSize: 16),
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {
                    _inputValue = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.brown[100],
                  ),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: _inputValue.length == 4 ? _checkAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.brown[800],
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
    if (_inputValue == widget.correctAnswer) {
      // 正解
      widget.onSuccess();
    } else {
      // 不正解
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '間違った暗号です。もう一度お試しください。',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
        ),
      );
      _controller.clear();
      setState(() {
        _inputValue = '';
      });
    }
  }
}