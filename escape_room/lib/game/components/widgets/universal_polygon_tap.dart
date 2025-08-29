import 'package:flutter/material.dart';

/// 汎用多角形タップ判定Widget
/// モーダル、ダイアログ、任意のUI要素で使用可能
class UniversalPolygonTap extends StatelessWidget {
  final List<Offset> points; // 絶対座標または相対座標
  final Widget child;
  final VoidCallback? onTap;
  final bool showDebugBorder;
  final Color debugBorderColor;
  final bool useRelativeCoordinates; // true: 0.0-1.0の相対座標, false: 絶対座標

  const UniversalPolygonTap({
    super.key,
    required this.points,
    required this.child,
    this.onTap,
    this.showDebugBorder = false,
    this.debugBorderColor = Colors.red,
    this.useRelativeCoordinates = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 座標を絶対座標に変換
        final absolutePoints = useRelativeCoordinates
            ? points.map((point) => Offset(
                point.dx * constraints.maxWidth,
                point.dy * constraints.maxHeight,
              )).toList()
            : points;

        return Stack(
          children: [
            // 子ウィジェット
            child,
            
            // 多角形タップ領域
            Positioned.fill(
              child: GestureDetector(
                onTap: onTap,
                child: showDebugBorder
                    ? CustomPaint(
                        painter: _DebugPolygonPainter(
                          points: absolutePoints,
                          color: debugBorderColor,
                        ),
                      )
                    : CustomPaint(
                        painter: _InvisiblePolygonPainter(points: absolutePoints),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 透明な多角形タップ領域
class _InvisiblePolygonPainter extends CustomPainter {
  final List<Offset> points;
  final Path _path = Path();

  _InvisiblePolygonPainter({required this.points}) {
    _buildPath();
  }

  void _buildPath() {
    if (points.isEmpty) return;
    _path.reset();
    _path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      _path.lineTo(points[i].dx, points[i].dy);
    }
    _path.close();
  }

  @override
  bool? hitTest(Offset position) => _path.contains(position);

  @override
  void paint(Canvas canvas, Size size) {
    // 何も描画しない（透明）
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// デバッグ用多角形描画
class _DebugPolygonPainter extends _InvisiblePolygonPainter {
  final Color color;

  _DebugPolygonPainter({
    required List<Offset> points,
    required this.color,
  }) : super(points: points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(_path, paint);
    canvas.drawPath(_path, borderPaint);
  }
}

/// モーダル内画像の特定部分タップ用Widget
class ModalImageWithPolygonTaps extends StatelessWidget {
  final String imagePath;
  final List<PolygonTapArea> tapAreas;
  final Size? imageSize;

  const ModalImageWithPolygonTaps({
    super.key,
    required this.imagePath,
    required this.tapAreas,
    this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景画像
        Image.asset(
          imagePath,
          fit: BoxFit.contain,
          width: imageSize?.width,
          height: imageSize?.height,
        ),
        
        // 多角形タップ領域群
        ...tapAreas.map((area) => UniversalPolygonTap(
          points: area.points,
          onTap: area.onTap,
          showDebugBorder: area.showDebugBorder,
          debugBorderColor: area.debugBorderColor,
          child: const SizedBox.expand(),
        )),
      ],
    );
  }
}

/// 多角形タップ領域の定義
class PolygonTapArea {
  final List<Offset> points;
  final VoidCallback? onTap;
  final bool showDebugBorder;
  final Color debugBorderColor;

  const PolygonTapArea({
    required this.points,
    this.onTap,
    this.showDebugBorder = false,
    this.debugBorderColor = Colors.red,
  });
}