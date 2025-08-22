import 'dart:math' as math;
import 'package:flutter/material.dart';

// オブジェクト検出サービスの型定義
enum ObjectType { button, text, image, interactive, decorative }

class DetectedObject {
  final String id;
  final Rect bounds;
  final ObjectType type;
  final double confidence;
  final String label;
  
  DetectedObject({
    required this.id,
    required this.bounds,
    required this.type,
    required this.confidence,
    required this.label,
  });

  /// Get the center point of the object
  Offset get center => bounds.center;

  /// Get the bounding box (same as bounds)
  Rect get boundingBox => bounds;
}

/// 最適化されたホットスポット位置
class OptimizedHotspotPosition {
  final String id;
  final String name;
  final String description;
  final Offset relativePosition;
  final Size relativeSize;
  final double confidence;
  final ObjectType detectedType;

  const OptimizedHotspotPosition({
    required this.id,
    required this.name,
    required this.description,
    required this.relativePosition,
    required this.relativeSize,
    required this.confidence,
    required this.detectedType,
  });
}

/// ホットスポット配置最適化サービス
class HotspotPositionOptimizer {
  static final HotspotPositionOptimizer _instance =
      HotspotPositionOptimizer._internal();
  factory HotspotPositionOptimizer() => _instance;
  HotspotPositionOptimizer._internal();

  /// 検出されたオブジェクトから最適なホットスポット配置を計算
  Future<List<OptimizedHotspotPosition>> optimizePositions({
    required List<DetectedObject> detectedObjects,
    required Size imageSize,
    required double minTapAreaSize,
    required double maxOverlapThreshold,
  }) async {
    debugPrint('🎯 Starting hotspot position optimization...');
    debugPrint(
      '📊 Input: ${detectedObjects.length} objects, image ${imageSize.width}x${imageSize.height}',
    );

    final optimizedPositions = <OptimizedHotspotPosition>[];

    // 1. 信頼度でソート（高い順）
    final sortedObjects = List<DetectedObject>.from(detectedObjects);
    sortedObjects.sort((a, b) => b.confidence.compareTo(a.confidence));

    // 2. 各オブジェクトに対して最適化を実行
    for (int i = 0; i < sortedObjects.length; i++) {
      final obj = sortedObjects[i];

      // 3. 相対座標に変換
      final relativePosition = Offset(
        obj.center.dx / imageSize.width,
        obj.center.dy / imageSize.height,
      );

      // 4. 適切なタップエリアサイズを計算
      final optimizedSize = _calculateOptimalTapSize(
        objectBounds: obj.boundingBox,
        imageSize: imageSize,
        minSize: minTapAreaSize,
        objectType: obj.type,
      );

      // 5. 重複チェックと位置調整
      final adjustedPosition = _adjustPositionToAvoidOverlap(
        candidatePosition: relativePosition,
        candidateSize: optimizedSize,
        existingPositions: optimizedPositions,
        maxOverlap: maxOverlapThreshold,
        imageBounds: const Rect.fromLTWH(0, 0, 1, 1),
      );

      // 6. 最適化結果を追加
      if (adjustedPosition != null) {
        final hotspotData = _createHotspotFromObject(
          object: obj,
          optimizedPosition: adjustedPosition,
          optimizedSize: optimizedSize,
          index: i,
        );

        optimizedPositions.add(hotspotData);
        debugPrint(
          '✅ Optimized hotspot: ${hotspotData.id} at (${(adjustedPosition.dx * 100).toInt()}%, ${(adjustedPosition.dy * 100).toInt()}%)',
        );
      } else {
        debugPrint(
          '⚠️ Could not place hotspot for ${obj.label} - overlap conflicts',
        );
      }
    }

    debugPrint(
      '🎯 Optimization complete: ${optimizedPositions.length} hotspots positioned',
    );
    return optimizedPositions;
  }

  /// 最適なタップサイズを計算
  Size _calculateOptimalTapSize({
    required Rect objectBounds,
    required Size imageSize,
    required double minSize,
    required ObjectType objectType,
  }) {
    // オブジェクトの相対サイズ
    final relativeWidth = objectBounds.width / imageSize.width;
    final relativeHeight = objectBounds.height / imageSize.height;

    // タイプ別の推奨サイズ倍率
    double sizeMultiplier = 1.0; // デフォルト値
    switch (objectType) {
      case ObjectType.button:
        sizeMultiplier = 1.3; // ボタンは少し大きめ
        break;
      case ObjectType.text:
        sizeMultiplier = 1.1; // テキストは適度なサイズ
        break;
      case ObjectType.interactive:
        sizeMultiplier = 1.5; // 相互作用可能オブジェクトは大きめ
        break;
      case ObjectType.decorative:
        sizeMultiplier = 1.2; // 装飾品は中程度
        break;
      case ObjectType.image:
        sizeMultiplier = 1.0; // 画像は基本サイズ
        break;
    }

    // 最適化されたサイズを計算
    double optimizedWidth = math.max(relativeWidth * sizeMultiplier, minSize);
    double optimizedHeight = math.max(relativeHeight * sizeMultiplier, minSize);

    // 最大サイズ制限（画面の30%まで）
    optimizedWidth = math.min(optimizedWidth, 0.3);
    optimizedHeight = math.min(optimizedHeight, 0.3);

    return Size(optimizedWidth, optimizedHeight);
  }

  /// 重複を避けるための位置調整
  Offset? _adjustPositionToAvoidOverlap({
    required Offset candidatePosition,
    required Size candidateSize,
    required List<OptimizedHotspotPosition> existingPositions,
    required double maxOverlap,
    required Rect imageBounds,
  }) {
    // 候補位置の矩形を計算
    final candidateRect = Rect.fromCenter(
      center: candidatePosition,
      width: candidateSize.width,
      height: candidateSize.height,
    );

    // 既存のホットスポットとの重複チェック
    for (final existing in existingPositions) {
      final existingRect = Rect.fromCenter(
        center: existing.relativePosition,
        width: existing.relativeSize.width,
        height: existing.relativeSize.height,
      );

      final overlapArea = _calculateOverlapArea(candidateRect, existingRect);
      final overlapRatio =
          overlapArea / (candidateRect.width * candidateRect.height);

      if (overlapRatio > maxOverlap) {
        // 重複が許容値を超えている場合、位置を調整
        final adjustedPosition = _findNearestNonOverlappingPosition(
          candidateRect: candidateRect,
          existingPositions: existingPositions,
          imageBounds: imageBounds,
          maxAttempts: 8,
        );

        if (adjustedPosition != null) {
          return adjustedPosition;
        } else {
          return null; // 適切な位置が見つからない
        }
      }
    }

    // 画面境界チェック
    if (_isWithinBounds(candidateRect, imageBounds)) {
      return candidatePosition;
    } else {
      // 境界内に収まるよう調整
      return _adjustPositionToBounds(
        candidatePosition,
        candidateSize,
        imageBounds,
      );
    }
  }

  /// 重複エリアを計算
  double _calculateOverlapArea(Rect rect1, Rect rect2) {
    final left = math.max(rect1.left, rect2.left);
    final top = math.max(rect1.top, rect2.top);
    final right = math.min(rect1.right, rect2.right);
    final bottom = math.min(rect1.bottom, rect2.bottom);

    if (left >= right || top >= bottom) {
      return 0.0; // 重複なし
    }

    return (right - left) * (bottom - top);
  }

  /// 最も近い非重複位置を探す
  Offset? _findNearestNonOverlappingPosition({
    required Rect candidateRect,
    required List<OptimizedHotspotPosition> existingPositions,
    required Rect imageBounds,
    required int maxAttempts,
  }) {
    final originalCenter = candidateRect.center;
    const searchRadius = 0.05; // 5%ずつ範囲を広げて検索

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final radius = searchRadius * attempt;

      // 円周上の8方向で試行
      for (int i = 0; i < 8; i++) {
        final angle = (i * math.pi * 2) / 8;
        final testPosition = Offset(
          originalCenter.dx + math.cos(angle) * radius,
          originalCenter.dy + math.sin(angle) * radius,
        );

        final testRect = Rect.fromCenter(
          center: testPosition,
          width: candidateRect.width,
          height: candidateRect.height,
        );

        // 境界チェック
        if (!_isWithinBounds(testRect, imageBounds)) continue;

        // 重複チェック
        bool hasOverlap = false;
        for (final existing in existingPositions) {
          final existingRect = Rect.fromCenter(
            center: existing.relativePosition,
            width: existing.relativeSize.width,
            height: existing.relativeSize.height,
          );

          if (_calculateOverlapArea(testRect, existingRect) > 0) {
            hasOverlap = true;
            break;
          }
        }

        if (!hasOverlap) {
          return testPosition;
        }
      }
    }

    return null; // 適切な位置が見つからない
  }

  /// 境界内チェック
  bool _isWithinBounds(Rect rect, Rect bounds) {
    return rect.left >= bounds.left &&
        rect.top >= bounds.top &&
        rect.right <= bounds.right &&
        rect.bottom <= bounds.bottom;
  }

  /// 境界内に収まるよう位置調整
  Offset _adjustPositionToBounds(Offset position, Size size, Rect bounds) {
    final halfWidth = size.width / 2;
    final halfHeight = size.height / 2;

    double adjustedX = position.dx;
    double adjustedY = position.dy;

    // X座標調整
    if (position.dx - halfWidth < bounds.left) {
      adjustedX = bounds.left + halfWidth;
    } else if (position.dx + halfWidth > bounds.right) {
      adjustedX = bounds.right - halfWidth;
    }

    // Y座標調整
    if (position.dy - halfHeight < bounds.top) {
      adjustedY = bounds.top + halfHeight;
    } else if (position.dy + halfHeight > bounds.bottom) {
      adjustedY = bounds.bottom - halfHeight;
    }

    return Offset(adjustedX, adjustedY);
  }

  /// オブジェクトからホットスポットデータを作成
  OptimizedHotspotPosition _createHotspotFromObject({
    required DetectedObject object,
    required Offset optimizedPosition,
    required Size optimizedSize,
    required int index,
  }) {
    // オブジェクトタイプに基づいて名前と説明を生成
    final nameAndDescription = _generateHotspotContent(
      object.label,
      object.type,
    );

    return OptimizedHotspotPosition(
      id: 'auto_${object.label}_$index',
      name: nameAndDescription['name']!,
      description: nameAndDescription['description']!,
      relativePosition: optimizedPosition,
      relativeSize: optimizedSize,
      confidence: object.confidence,
      detectedType: object.type,
    );
  }

  /// ホットスポットの名前と説明を生成
  Map<String, String> _generateHotspotContent(String label, ObjectType type) {
    switch (label.toLowerCase()) {
      case 'chandelier':
        return {
          'name': '黄金のシャンデリア',
          'description': '豪華な黄金のシャンデリア。蝋燭の炎が美しく揺れている。何か特別な仕掛けがありそうだ。',
        };
      case 'reading_stand':
        return {
          'name': '古の読書台',
          'description': '羊皮紙が開かれた古い読書台。古代文字で何かが書かれているようだ。重要な情報が記されているかもしれない。',
        };
      case 'desk_chair':
        return {
          'name': '学者の机',
          'description': '古い書物が積まれた学者の机と椅子。引き出しに何かが隠されているかも。長年の研究の跡が感じられる。',
        };
      case 'floor_light':
        return {
          'name': '神秘の光',
          'description': '床に差し込む神秘的な光。まるで何かが埋められているかのように光っている。調べる価値がありそうだ。',
        };
      case 'wall_decoration':
        return {
          'name': '古い絵画',
          'description': '壁に掛けられた古い絵画。よく見ると絵の中に隠されたメッセージがありそうだ。',
        };
      case 'desk':
        return {
          'name': '古の読書台',
          'description': '羊皮紙が開かれた古い読書台。重要な情報が記されているかもしれない。',
        };
      case 'chair':
        return {
          'name': '学者の椅子',
          'description': '古い革張りの椅子。長年の使用で座面がへこんでいる。何かが隠されているかも。',
        };
      case 'light_source':
        return {'name': '神秘の光', 'description': '床に差し込む神秘的な光。何かが埋められているかもしれない。'};
      default:
        return {
          'name': '謎めいた$label',
          'description': '注意深く調べる価値がありそうな$label。古い書斎には多くの秘密が隠されている。',
        };
    }
  }

  /// 最適化結果をデバッグ出力
  void debugPrintOptimization(List<OptimizedHotspotPosition> positions) {
    debugPrint('🎯 === Hotspot Position Optimization Results ===');
    for (int i = 0; i < positions.length; i++) {
      final pos = positions[i];
      debugPrint('🎮 Hotspot $i: ${pos.name}');
      debugPrint(
        '   📍 Position: (${(pos.relativePosition.dx * 100).toInt()}%, ${(pos.relativePosition.dy * 100).toInt()}%)',
      );
      debugPrint(
        '   📏 Size: ${(pos.relativeSize.width * 100).toInt()}% x ${(pos.relativeSize.height * 100).toInt()}%',
      );
      debugPrint('   🎯 Confidence: ${(pos.confidence * 100).toInt()}%');
      debugPrint('   🏷️ Type: ${pos.detectedType}');
    }
    debugPrint('🎯 =======================================');
  }
}
