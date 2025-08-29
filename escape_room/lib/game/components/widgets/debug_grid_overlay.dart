import 'package:flutter/material.dart';

/// デバッグ用のグリッドオーバーレイWidget
/// タップを通過させてグリッドのみを表示
class DebugGridOverlay extends StatelessWidget {
  final Size gameSize;
  final int gridSize;
  final bool showGrid;
  final Color gridColor;
  final double gridOpacity;

  const DebugGridOverlay({
    super.key,
    required this.gameSize,
    this.gridSize = 50,
    this.showGrid = false,
    this.gridColor = Colors.red,
    this.gridOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGrid) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(  // タップを通過させる
        child: CustomPaint(
          painter: GridPainter(
            gameSize: gameSize,
            gridSize: gridSize,
            gridColor: gridColor.withValues(alpha: gridOpacity),
          ),
        ),
      ),
    );
  }
}

/// グリッドを描画するカスタムペインター
class GridPainter extends CustomPainter {
  final Size gameSize;
  final int gridSize;
  final Color gridColor;

  GridPainter({
    required this.gameSize,
    required this.gridSize,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 細い線で描画
    final paint = Paint()
      ..color = Colors.green // 緑色
      ..strokeWidth = 1.0  // 細い線
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // 固定グリッド: 8×12（400÷50 × 600÷50）
    final gridCols = 8;
    final gridRows = 12;
    final cellWidth = width / gridCols;
    final cellHeight = height / gridRows;

    // 縦線を描画 (9本: 0~8)
    for (int i = 0; i <= gridCols; i++) {
      final x = i * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, height),
        paint,
      );
    }

    // 横線を描画 (13本: 0~12)
    for (int i = 0; i <= gridRows; i++) {
      final y = i * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(width, y),
        paint,
      );
    }

    // 座標ラベルを描画
    final textStyle = TextStyle(
      color: Colors.green, // 緑色
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int col = 0; col < gridCols; col++) {
      for (int row = 0; row < gridRows; row++) {
        final x = col * cellWidth;
        final y = row * cellHeight;
        
        final textSpan = TextSpan(
          text: '($col,$row)',
          style: textStyle,
        );
        
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        textPainter.paint(canvas, Offset(x + 2, y + 2));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! GridPainter ||
           oldDelegate.gameSize != gameSize ||
           oldDelegate.gridSize != gridSize ||
           oldDelegate.gridColor != gridColor;
  }
}

/// デバッグ設定を管理するクラス
class DebugSettings {
  static bool _showGrid = false; // デフォルトでOFF
  static double _gridOpacity = 1.0; // 完全不透明
  static Color _gridColor = Colors.green; // 緑色に変更

  static bool get showGrid => _showGrid;
  static double get gridOpacity => _gridOpacity;
  static Color get gridColor => _gridColor;

  static void toggleGrid() {
    _showGrid = !_showGrid;
  }

  static void setGridOpacity(double opacity) {
    _gridOpacity = opacity.clamp(0.0, 1.0);
  }

  static void setGridColor(Color color) {
    _gridColor = color;
  }
}

/// デバッグコントロールパネル
class DebugControlPanel extends StatefulWidget {
  final VoidCallback? onToggle;
  
  const DebugControlPanel({super.key, this.onToggle});

  @override
  State<DebugControlPanel> createState() => _DebugControlPanelState();
}

class _DebugControlPanelState extends State<DebugControlPanel> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // グリッド表示切り替えボタン
            ElevatedButton(
              onPressed: () {
                setState(() {
                  DebugSettings.toggleGrid();
                });
                widget.onToggle?.call(); // 親の再描画をトリガー
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DebugSettings.showGrid ? Colors.red : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(80, 32),
              ),
              child: Text(
                DebugSettings.showGrid ? 'Grid ON' : 'Grid OFF',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            
            if (DebugSettings.showGrid) ...[
              const SizedBox(height: 4),
              
              // 透明度調整スライダー
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('透明度', style: TextStyle(color: Colors.white, fontSize: 10)),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 80,
                    child: Slider(
                      value: DebugSettings.gridOpacity,
                      min: 0.1,
                      max: 1.0,
                      divisions: 9,
                      onChanged: (value) {
                        setState(() {
                          DebugSettings.setGridOpacity(value);
                        });
                        widget.onToggle?.call(); // 親の再描画をトリガー
                      },
                    ),
                  ),
                ],
              ),
              
              // 色選択ボタン
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _colorButton(Colors.green, '緑'), // 緑を最初に
                  _colorButton(Colors.red, '赤'),
                  _colorButton(Colors.blue, '青'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _colorButton(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () {
          setState(() {
            DebugSettings.setGridColor(color);
          });
          widget.onToggle?.call(); // 親の再描画をトリガー
        },
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: DebugSettings.gridColor == color ? Colors.white : Colors.grey,
              width: DebugSettings.gridColor == color ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}