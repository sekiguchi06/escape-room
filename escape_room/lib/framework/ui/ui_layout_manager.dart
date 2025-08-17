import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// UIレイアウトマネージャー
/// 画面サイズに応じたUI要素の配置を管理
class UILayoutManager {
  /// 右寄せ配置（マージン付き）
  static Vector2 topRight(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      screenSize.x - componentSize.x - margin,
      margin,
    );
  }
  
  /// 左寄せ配置（マージン付き）
  static Vector2 topLeft(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(margin, margin);
  }
  
  /// 中央配置
  static Vector2 center(Vector2 screenSize, Vector2 componentSize) {
    return Vector2(
      (screenSize.x - componentSize.x) / 2,
      (screenSize.y - componentSize.y) / 2,
    );
  }
  
  /// 下部中央配置（マージン付き）
  static Vector2 bottomCenter(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      (screenSize.x - componentSize.x) / 2,
      screenSize.y - componentSize.y - margin,
    );
  }
  
  /// 右寄せ中央配置（マージン付き） - 互換性のため残す
  static Vector2 centerRight(Vector2 screenSize, Vector2 componentSize, double margin) {
    return topRight(screenSize, componentSize, margin);
  }
  
  /// 上下中央、左配置
  static Vector2 centerLeft(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      margin,
      (screenSize.y - componentSize.y) / 2,
    );
  }
  
  /// 上配置、左右中央
  static Vector2 topCenter(Vector2 screenSize, Vector2 componentSize, double margin) {
    return Vector2(
      (screenSize.x - componentSize.x) / 2,
      margin,
    );
  }
  
  /// グリッドレイアウト
  static List<Vector2> grid(
    Vector2 parentSize,
    Vector2 childSize,
    int columns,
    int rows, {
    EdgeInsets padding = EdgeInsets.zero,
    double spacing = 8.0,
  }) {
    final positions = <Vector2>[];
    final availableWidth = parentSize.x - padding.left - padding.right - (spacing * (columns - 1));
    final availableHeight = parentSize.y - padding.top - padding.bottom - (spacing * (rows - 1));
    
    final cellWidth = availableWidth / columns;
    final cellHeight = availableHeight / rows;
    
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final x = padding.left + col * (cellWidth + spacing) + (cellWidth - childSize.x) / 2;
        final y = padding.top + row * (cellHeight + spacing) + (cellHeight - childSize.y) / 2;
        positions.add(Vector2(x, y));
      }
    }
    
    return positions;
  }
  
  /// 縦並びレイアウト
  static List<Vector2> verticalList(
    Vector2 parentSize,
    Vector2 childSize,
    int count, {
    EdgeInsets padding = EdgeInsets.zero,
    double spacing = 8.0,
    MainAxisAlignment alignment = MainAxisAlignment.start,
  }) {
    final positions = <Vector2>[];
    
    double startY = padding.top;
    if (alignment == MainAxisAlignment.center) {
      final totalHeight = count * childSize.y + (count - 1) * spacing;
      startY = (parentSize.y - totalHeight) / 2;
    } else if (alignment == MainAxisAlignment.end) {
      final totalHeight = count * childSize.y + (count - 1) * spacing;
      startY = parentSize.y - totalHeight - padding.bottom;
    }
    
    for (int i = 0; i < count; i++) {
      final x = (parentSize.x - childSize.x) / 2; // 横方向は中央
      final y = startY + i * (childSize.y + spacing);
      positions.add(Vector2(x, y));
    }
    
    return positions;
  }
  
  /// 横並びレイアウト
  static List<Vector2> horizontalList(
    Vector2 parentSize,
    Vector2 childSize,
    int count, {
    EdgeInsets padding = EdgeInsets.zero,
    double spacing = 8.0,
    MainAxisAlignment alignment = MainAxisAlignment.start,
  }) {
    final positions = <Vector2>[];
    
    double startX = padding.left;
    if (alignment == MainAxisAlignment.center) {
      final totalWidth = count * childSize.x + (count - 1) * spacing;
      startX = (parentSize.x - totalWidth) / 2;
    } else if (alignment == MainAxisAlignment.end) {
      final totalWidth = count * childSize.x + (count - 1) * spacing;
      startX = parentSize.x - totalWidth - padding.right;
    }
    
    for (int i = 0; i < count; i++) {
      final x = startX + i * (childSize.x + spacing);
      final y = (parentSize.y - childSize.y) / 2; // 縦方向は中央
      positions.add(Vector2(x, y));
    }
    
    return positions;
  }
}