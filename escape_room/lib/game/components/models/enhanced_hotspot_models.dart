import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';

/// ホットスポットの形状タイプ
enum HotspotShape {
  rectangle,  // 四角形（現在のデフォルト）
  circle,     // 円形
  polygon,    // 多角形
}

/// 拡張されたホットスポットデータ（任意の形状対応）
class EnhancedHotspotData {
  final String id;
  final AssetGenImage asset;
  final String name;
  final String description;
  final Offset position;
  final Size size;
  final HotspotShape shape;
  final List<Offset>? polygonPoints; // 多角形の場合の頂点（相対座標）
  final Function(Offset tapPosition)? onTap;

  const EnhancedHotspotData({
    required this.id,
    required this.asset,
    required this.name,
    required this.description,
    required this.position,
    required this.size,
    this.shape = HotspotShape.rectangle,
    this.polygonPoints,
    this.onTap,
  });
}

/// カスタム多角形クリッパー
class CustomPolygonClipper extends CustomClipper<Path> {
  final List<Offset> points;
  
  CustomPolygonClipper(this.points);

  @override
  Path getClip(Size size) {
    Path path = Path();
    if (points.isNotEmpty) {
      // 相対座標を実際のサイズに変換
      path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
      }
      path.close();
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}