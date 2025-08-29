import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 多角形作成のヘルパークラス
class PolygonHelper {
  static const double _gridCols = 8.0;  // 8列
  static const double _gridRows = 12.0; // 12行

  /// グリッド座標を相対座標(0.0-1.0)に変換
  static Offset gridToRelative(double gridX, double gridY) {
    return Offset(
      gridX / _gridCols,
      gridY / _gridRows,
    );
  }

  /// グリッド座標のリストを相対座標に変換
  static List<Offset> gridListToRelative(List<List<double>> gridCoordinates) {
    return gridCoordinates.map((coord) => 
      gridToRelative(coord[0], coord[1])
    ).toList();
  }

  /// よく使われる形状のテンプレート
  
  /// 四角形を作成
  static List<Offset> createRectangle({
    required double startX,
    required double startY,
    required double endX,
    required double endY,
  }) {
    return gridListToRelative([
      [startX, startY],
      [endX, startY],
      [endX, endY],
      [startX, endY],
    ]);
  }

  /// 三角形を作成
  static List<Offset> createTriangle({
    required double x1, required double y1,
    required double x2, required double y2,
    required double x3, required double y3,
  }) {
    return gridListToRelative([
      [x1, y1],
      [x2, y2],
      [x3, y3],
    ]);
  }

  /// L字型を作成
  static List<Offset> createLShape({
    required double startX,
    required double startY,
    required double width,
    required double height,
    required double cutWidth,
    required double cutHeight,
  }) {
    return gridListToRelative([
      [startX, startY],
      [startX + width, startY],
      [startX + width, startY + cutHeight],
      [startX + cutWidth, startY + cutHeight],
      [startX + cutWidth, startY + height],
      [startX, startY + height],
    ]);
  }

  /// 円形（多角形近似）を作成
  static List<Offset> createCircle({
    required double centerX,
    required double centerY,
    required double radius,
    int sides = 8,
  }) {
    final points = <List<double>>[];
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * 3.14159) / sides;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      points.add([x, y]);
    }
    return gridListToRelative(points);
  }

  /// カスタム多角形を作成
  static List<Offset> createCustomPolygon(List<List<double>> gridCoordinates) {
    return gridListToRelative(gridCoordinates);
  }
}