import 'package:flutter/material.dart';
import '../models/enhanced_hotspot_models.dart';

/// 任意の形状に対応したホットスポットウィジェット
class EnhancedHotspotWidget extends StatelessWidget {
  final EnhancedHotspotData hotspot;
  final Size gameSize;
  final VoidCallback onTap;
  final bool showDebugBorders;

  const EnhancedHotspotWidget({
    super.key,
    required this.hotspot,
    required this.gameSize,
    required this.onTap,
    this.showDebugBorders = false,
  });

  @override
  Widget build(BuildContext context) {
    final left = hotspot.position.dx * gameSize.width;
    final top = hotspot.position.dy * gameSize.height;
    final width = hotspot.size.width * gameSize.width;
    final height = hotspot.size.height * gameSize.height;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: _buildShapeWidget(),
    );
  }

  Widget _buildShapeWidget() {
    switch (hotspot.shape) {
      case HotspotShape.circle:
        return _buildCircularHotspot();
      case HotspotShape.polygon:
        return _buildPolygonHotspot();
      case HotspotShape.rectangle:
      default:
        return _buildRectangularHotspot();
    }
  }

  Widget _buildRectangularHotspot() {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.8),
            width: 2,
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildCircularHotspot() {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.8),
            width: 2,
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildPolygonHotspot() {
    if (hotspot.polygonPoints == null || hotspot.polygonPoints!.isEmpty) {
      return _buildRectangularHotspot(); // フォールバック
    }

    return ClipPath(
      clipper: CustomPolygonClipper(hotspot.polygonPoints!),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.8),
              width: 2,
            ),
            color: Colors.transparent,
          ),
          child: CustomPaint(
            painter: PolygonBorderPainter(
              points: hotspot.polygonPoints!,
              borderColor: Colors.red.withValues(alpha: 0.8),
              borderWidth: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// 多角形の境界線を描画するカスタムペインター
class PolygonBorderPainter extends CustomPainter {
  final List<Offset> points;
  final Color borderColor;
  final double borderWidth;

  PolygonBorderPainter({
    required this.points,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // 相対座標を実際のサイズに変換
    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}