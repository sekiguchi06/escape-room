import 'package:flutter/material.dart';
import 'dart:math';
import 'dial_data.dart';

/// 回転ダイヤルパズルのUI構築を担当するミックスイン
mixin RotationDialUI {
  /// サクセスダイアログを表示
  void showSuccessDialog({
    required BuildContext context,
    required int duration,
    required VoidCallback? onSuccess,
    required VoidCallback onRestart,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_open, color: Colors.amber),
            SizedBox(width: 8),
            Text('解除成功！'),
          ],
        ),
        content: Text('正しい組み合わせを見つけました！\n完了時間: $duration秒'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSuccess?.call();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRestart();
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  /// 正解のヒント表示を構築
  Widget buildCorrectAnswerHint(List<DialData> dials) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '正解の組み合わせ:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: dials.asMap().entries.map((entry) {
                final dial = entry.value;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      dial.symbols[dial.correctIndex],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 進捗表示を構築
  Widget buildProgressIndicator(List<DialData> dials) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: dials.asMap().entries.map((entry) {
            final index = entry.key;
            final dial = entry.value;
            final isCorrect = dial.currentIndex == dial.correctIndex;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCorrect ? Colors.green : Colors.grey,
                ),
                Text(
                  'ダイヤル${index + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 個別のダイヤルウィジェットを構築
  Widget buildDial({
    required int index,
    required DialData dial,
    required Function(int) onRotate,
    required BuildContext context,
  }) {
    final isCorrect = dial.currentIndex == dial.correctIndex;
    
    return GestureDetector(
      onTap: () => onRotate(index),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          final center = size / 2;
          final symbolSize = size * 0.24;
          final radius = size * 0.3;
          
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect ? Colors.green.shade100 : Colors.grey.shade100,
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.black54,
                width: 4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 外周のシンボル配置（シンボル中心を円周上に正確配置）
                ...dial.symbols.asMap().entries.map((entry) {
                  final symbolIndex = entry.key;
                  final symbol = entry.value;
                  
                  // シンプルな角度計算：0番目が上、時計回りに配置
                  final angleStep = 2 * pi / dial.symbols.length; // 各シンボル間の角度
                  final currentRotation = dial.currentIndex * angleStep; // 現在の回転量
                  final symbolAngle = (symbolIndex * angleStep) - currentRotation - (pi / 2); // 上を0度に調整
                  
                  // シンボル中心を円周上に配置するための座標計算
                  final symbolCenterX = center + radius * cos(symbolAngle);
                  final symbolCenterY = center + radius * sin(symbolAngle);
                  
                  // Positioned用の左上座標（シンボル中心から左上への調整）
                  final left = symbolCenterX - (symbolSize / 2);
                  final top = symbolCenterY - (symbolSize / 2);
                  
                  return Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: symbolSize,
                      height: symbolSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black54,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          symbol,
                          style: TextStyle(
                            fontSize: symbolSize * 0.6,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                
                // 固定の指示器（上部の矢印）
                Positioned(
                  top: size * 0.02,
                  left: center - size * 0.06,
                  child: Container(
                    width: size * 0.12,
                    height: size * 0.12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: size * 0.1,
                    ),
                  ),
                ),
                
                // 中央に現在のシンボルを表示
                Center(
                  child: Container(
                    width: symbolSize,
                    height: symbolSize,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCorrect ? Colors.green.shade700 : Colors.black54,
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        dial.symbols[dial.currentIndex],
                        style: TextStyle(
                          fontSize: symbolSize * 0.6,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}