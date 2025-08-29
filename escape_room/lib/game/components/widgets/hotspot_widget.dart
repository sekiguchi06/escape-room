import 'package:flutter/material.dart';
import '../models/hotspot_models.dart';

/// 個別ホットスポットウィジェット
class HotspotWidget extends StatelessWidget {
  final HotspotData hotspot;
  final Size gameSize;
  final VoidCallback onTap;
  final bool showDebugBorders;
  final int? hotspotNumber; // ホットスポット番号

  const HotspotWidget({
    super.key,
    required this.hotspot,
    required this.gameSize,
    required this.onTap,
    this.showDebugBorders = false,
    this.hotspotNumber,
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
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque, // タップ領域を明確化
        child: Stack(
          children: [
            // タップ領域の枠
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // タップ可能領域を示す枠を常に表示
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.8),
                  width: 2,
                ),
                // 背景は完全に透明
                color: Colors.transparent,
              ),
            ),
            // 番号表示（左上）
            if (hotspotNumber != null)
              Positioned(
                left: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
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

  /// 画像ロードエラー時のフォールバックWidget
  Widget _buildErrorFallback() {
    return Container(
      color: Colors.amber.withValues(alpha: 0.5),
      child: const Center(
        child: Icon(
          Icons.help_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}