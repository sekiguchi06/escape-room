import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';

/// グリッド座標系でのホットスポットデータ
/// 400x600の画像を50x50のグリッド（8x12）に分割
class GridHotspotData {
  final String id;
  final AssetGenImage asset;
  final String name;
  final String description;
  final List<GridPoint> gridPoints; // グリッド座標の頂点リスト
  final Function(Offset tapPosition)? onTap;

  const GridHotspotData({
    required this.id,
    required this.asset,
    required this.name,
    required this.description,
    required this.gridPoints,
    this.onTap,
  });

  /// グリッド座標を相対座標（0.0-1.0）に変換
  List<Offset> get relativePoints {
    return gridPoints.map((point) => point.toRelativeOffset()).toList();
  }

  /// 境界ボックスを取得
  Rect get boundingBox {
    if (gridPoints.isEmpty) return Rect.zero;
    
    double minX = gridPoints.first.x.toDouble();
    double maxX = gridPoints.first.x.toDouble();
    double minY = gridPoints.first.y.toDouble();
    double maxY = gridPoints.first.y.toDouble();
    
    for (final point in gridPoints) {
      minX = minX < point.x ? minX : point.x.toDouble();
      maxX = maxX > point.x ? maxX : point.x.toDouble();
      minY = minY < point.y ? minY : point.y.toDouble();
      maxY = maxY > point.y ? maxY : point.y.toDouble();
    }
    
    return Rect.fromLTRB(
      minX / 8.0,  // 400px ÷ 50px = 8グリッド
      minY / 12.0, // 600px ÷ 50px = 12グリッド
      maxX / 8.0,
      maxY / 12.0,
    );
  }
}

/// グリッド座標の点
class GridPoint {
  final int x; // 0-8の範囲（400px ÷ 50px）
  final int y; // 0-12の範囲（600px ÷ 50px）

  const GridPoint(this.x, this.y);

  /// グリッド座標を相対座標に変換
  Offset toRelativeOffset() {
    return Offset(
      x / 8.0,  // x座標を0.0-1.0に正規化
      y / 12.0, // y座標を0.0-1.0に正規化
    );
  }

  /// グリッド座標をピクセル座標に変換
  Offset toPixelOffset() {
    return Offset(
      x * 50.0,  // グリッドサイズ50px
      y * 50.0,
    );
  }

  @override
  String toString() => '($x,$y)';
}

/// グリッド座標系でのホットスポット定義ヘルパー
class GridHotspotHelper {
  /// 四角形のホットスポットを作成
  static GridHotspotData createRectangle({
    required String id,
    required AssetGenImage asset,
    required String name,
    required String description,
    required int startX,
    required int startY,
    required int endX,
    required int endY,
    Function(Offset)? onTap,
  }) {
    return GridHotspotData(
      id: id,
      asset: asset,
      name: name,
      description: description,
      gridPoints: [
        GridPoint(startX, startY),
        GridPoint(endX, startY),
        GridPoint(endX, endY),
        GridPoint(startX, endY),
      ],
      onTap: onTap,
    );
  }

  /// 多角形のホットスポットを作成
  static GridHotspotData createPolygon({
    required String id,
    required AssetGenImage asset,
    required String name,
    required String description,
    required List<GridPoint> points,
    Function(Offset)? onTap,
  }) {
    return GridHotspotData(
      id: id,
      asset: asset,
      name: name,
      description: description,
      gridPoints: points,
      onTap: onTap,
    );
  }
}

/// グリッドホットスポット用のカスタムクリッパー
class GridPolygonClipper extends CustomClipper<Path> {
  final List<Offset> relativePoints;
  
  GridPolygonClipper(this.relativePoints);

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (relativePoints.isNotEmpty) {
      path.moveTo(
        relativePoints[0].dx * size.width,
        relativePoints[0].dy * size.height,
      );
      for (int i = 1; i < relativePoints.length; i++) {
        path.lineTo(
          relativePoints[i].dx * size.width,
          relativePoints[i].dy * size.height,
        );
      }
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}