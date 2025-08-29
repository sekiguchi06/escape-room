import 'package:flame/components.dart';
import '../utils/polygon_helper.dart';

/// ホットスポット作成の基底ヘルパークラス
abstract class BaseHotspotHelpers {
  
  /// 多角形ホットスポット作成ヘルパー
  static Map<String, dynamic> createPolygonHotspot({
    required String id,
    required String description,
    required List<List<double>> gridCoordinates,
  }) {
    final points = PolygonHelper.gridListToRelative(gridCoordinates);
    
    // 境界ボックスを計算
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;
    
    for (final point in points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }
    
    return {
      'id': id,
      'relativePosition': Vector2(minX, minY),
      'relativeSize': Vector2(maxX - minX, maxY - minY),
      'description': description,
      'shape': 'polygon',
      'polygonPoints': points.map((p) => Vector2(p.dx, p.dy)).toList(),
    };
  }

  /// 四角形ホットスポット作成ヘルパー
  static Map<String, dynamic> createRectangleHotspot({
    required String id,
    required String description,
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  }) {
    return createPolygonHotspot(
      id: id,
      description: description,
      gridCoordinates: [
        [startX, startY],
        [endX, startY],
        [endX, endY],
        [startX, endY],
      ],
    );
  }
}