import 'package:flutter/material.dart';

/// 多角形ホットスポット用のCustomPainter
class PolygonHotspotPainter extends CustomPainter {
  final List<Offset> points;
  final Color borderColor;
  final double borderWidth;
  final Path _path = Path();

  PolygonHotspotPainter({
    required this.points,
    this.borderColor = Colors.red,
    this.borderWidth = 2.0,
  }) {
    _buildPath();
  }

  void _buildPath() {
    if (points.isEmpty) return;
    _path.reset();
    _path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      _path.lineTo(points[i].dx, points[i].dy);
    }
    _path.close(); // パスを閉じる（必須）
  }

  @override
  bool? hitTest(Offset position) {
    // 公式API: Path.contains()でタップ判定
    return _path.contains(position);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // 境界線を描画
    final paint = Paint()
      ..color = borderColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(_path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is! PolygonHotspotPainter ||
           oldDelegate.points != points ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.borderWidth != borderWidth;
  }
}

/// 多角形ホットスポットウィジェット
class PolygonHotspotWidget extends StatelessWidget {
  final List<Offset> gridPoints; // グリッド座標（0.0-1.0の相対座標）
  final Size gameSize;
  final VoidCallback onTap;
  final int? hotspotNumber;
  final Color borderColor;

  const PolygonHotspotWidget({
    super.key,
    required this.gridPoints,
    required this.gameSize,
    required this.onTap,
    this.hotspotNumber,
    this.borderColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    // グリッド座標を画面座標に変換
    final screenPoints = gridPoints.map((point) => Offset(
      point.dx * gameSize.width,
      point.dy * gameSize.height,
    )).toList();

    return Positioned.fill(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            // 多角形のタップ領域
            CustomPaint(
              painter: PolygonHotspotPainter(
                points: screenPoints,
                borderColor: borderColor,
              ),
              size: gameSize,
            ),
            // 番号表示（左上）
            if (hotspotNumber != null && gridPoints.isNotEmpty)
              Positioned(
                left: gridPoints[0].dx * gameSize.width + 2,
                top: gridPoints[0].dy * gameSize.height + 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$hotspotNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// グリッド座標変換ヘルパー
class GridCoordinateHelper {
  /// グリッド座標を相対座標に変換
  /// gridX: 0-8, gridY: 0-12
  static Offset gridToRelative(double gridX, double gridY) {
    return Offset(
      gridX / 8.0,  // 8列のグリッド
      gridY / 12.0, // 12行のグリッド
    );
  }

  /// 指定された4つのグリッド座標から多角形の点を生成
  static List<Offset> createQuadrilateral({
    required double x1, required double y1, // 0,7の右下
    required double x2, required double y2, // 0,11の右上  
    required double x3, required double y3, // 7,8の中央
    required double x4, required double y4, // 5,6の中央下
  }) {
    return [
      gridToRelative(x1, y1),
      gridToRelative(x2, y2),
      gridToRelative(x3, y3),
      gridToRelative(x4, y4),
    ];
  }
}