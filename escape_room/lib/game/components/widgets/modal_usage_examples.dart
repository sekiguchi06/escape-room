import 'package:flutter/material.dart';
import 'universal_polygon_tap.dart';
import '../utils/polygon_helper.dart';

/// モーダル内での多角形タップ使用例
class ModalUsageExamples {
  
  /// 例1: パズルピース選択モーダル
  static Widget buildPuzzleSelectionModal(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 300,
        child: ModalImageWithPolygonTaps(
          imagePath: 'assets/images/puzzle_pieces.png',
          tapAreas: [
            // パズルピース1（三角形）
            PolygonTapArea(
              points: PolygonHelper.createTriangle(
                x1: 1, y1: 1,
                x2: 3, y2: 1,
                x3: 2, y3: 3,
              ),
              onTap: () {
                Navigator.of(context).pop('piece_1');
              },
              showDebugBorder: true,
              debugBorderColor: Colors.blue,
            ),
            
            // パズルピース2（L字型）
            PolygonTapArea(
              points: PolygonHelper.createLShape(
                startX: 4, startY: 1,
                width: 3, height: 4,
                cutWidth: 2, cutHeight: 2,
              ),
              onTap: () {
                Navigator.of(context).pop('piece_2');
              },
              showDebugBorder: true,
              debugBorderColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// 例2: アイテム詳細モーダル（複数の操作領域）
  static Widget buildItemDetailModal({
    required String itemImagePath,
    required VoidCallback onUse,
    required VoidCallback onInspect,
    required VoidCallback onCombine,
  }) {
    return Dialog(
      child: Container(
        width: 300,
        height: 400,
        child: Stack(
          children: [
            // メイン画像
            Image.asset(
              itemImagePath,
              fit: BoxFit.cover,
              width: 300,
              height: 400,
            ),
            
            // 使用ボタン領域（円形）
            UniversalPolygonTap(
              points: PolygonHelper.createCircle(
                centerX: 2, centerY: 8,
                radius: 1,
              ),
              onTap: onUse,
              child: const SizedBox.expand(),
            ),
            
            // 調べるボタン領域（四角形）
            UniversalPolygonTap(
              points: PolygonHelper.createRectangle(
                startX: 4, startY: 8,
                endX: 6, endY: 10,
              ),
              onTap: onInspect,
              child: const SizedBox.expand(),
            ),
            
            // 組み合わせボタン領域（三角形）
            UniversalPolygonTap(
              points: PolygonHelper.createTriangle(
                x1: 6, y1: 8,
                x2: 8, y2: 8,
                x3: 7, y3: 10,
              ),
              onTap: onCombine,
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }

  /// 例3: マップ画面での領域選択
  static Widget buildMapSelectionScreen({
    required String mapImagePath,
    required Function(String) onAreaSelected,
  }) {
    return Scaffold(
      body: ModalImageWithPolygonTaps(
        imagePath: mapImagePath,
        tapAreas: [
          // 森エリア（不規則な形）
          PolygonTapArea(
            points: PolygonHelper.createCustomPolygon([
              [1, 1], [3, 0.5], [4, 2], [3.5, 4], [2, 4.5], [0.5, 3],
            ]),
            onTap: () => onAreaSelected('forest'),
          ),
          
          // 城エリア（六角形）
          PolygonTapArea(
            points: PolygonHelper.createCustomPolygon([
              [5, 2], [7, 2], [8, 4], [7, 6], [5, 6], [4, 4],
            ]),
            onTap: () => onAreaSelected('castle'),
          ),
        ],
      ),
    );
  }

  /// 例4: ホットスポット詳細モーダルでの多角形インタラクション
  static void showHotspotDetailWithPolygonAreas(
    BuildContext context,
    String hotspotImagePath,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 350,
          height: 350,
          child: Stack(
            children: [
              // ホットスポット画像
              Image.asset(
                hotspotImagePath,
                fit: BoxFit.cover,
                width: 350,
                height: 350,
              ),
              
              // 左側の本（多角形エリア）
              UniversalPolygonTap(
                points: [
                  const Offset(0.1, 0.2),
                  const Offset(0.45, 0.15),
                  const Offset(0.48, 0.8),
                  const Offset(0.05, 0.85),
                ],
                onTap: () {
                  Navigator.of(context).pop();
                  // 左側の本の処理
                  debugPrint('左側の本をタップ');
                },
                showDebugBorder: true,
                child: Container(),
              ),
              
              // 右側の本（多角形エリア）
              UniversalPolygonTap(
                points: [
                  const Offset(0.52, 0.15),
                  const Offset(0.9, 0.2),
                  const Offset(0.95, 0.85),
                  const Offset(0.52, 0.8),
                ],
                onTap: () {
                  Navigator.of(context).pop();
                  // 右側の本の処理
                  debugPrint('右側の本をタップ');
                },
                showDebugBorder: true,
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}