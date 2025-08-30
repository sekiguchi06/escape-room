import 'package:flutter/material.dart';
import '../room_hotspot_system.dart';
import '../room_navigation_system.dart';
import '../models/hotspot_models.dart';
import 'hotspot_detail_modal.dart';

/// ホットスポット表示ウィジェット
class HotspotDisplay extends StatefulWidget {
  final Size gameSize;
  final dynamic game; // EscapeRoomGameインスタンス

  const HotspotDisplay({super.key, required this.gameSize, this.game});

  @override
  State<HotspotDisplay> createState() => _HotspotDisplayState();
}

class _HotspotDisplayState extends State<HotspotDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RoomNavigationSystem(),
      builder: (context, _) {
        final hotspots = RoomHotspotSystem().getCurrentRoomHotspots(context: context);

        return Stack(
          children: hotspots.map((hotspot) {
            return _buildHotspot(hotspot);
          }).toList(),
        );
      },
    );
  }

  Widget _buildHotspot(HotspotData hotspot) {
    final left = hotspot.position.dx * widget.gameSize.width;
    final top = hotspot.position.dy * widget.gameSize.height;
    final width = hotspot.size.width * widget.gameSize.width;
    final height = hotspot.size.height * widget.gameSize.height;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => _onHotspotTapped(hotspot),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // デバッグ用の薄い境界線（本番では削除可能）
            border: Border.all(
              color: Colors.yellow.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hotspot.asset.image(
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // 画像が見つからない場合のフォールバック
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
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onHotspotTapped(HotspotData hotspot) {
    // 背景タップエフェクトも発動させるため、手動でInkWellのタップを呼び出し

    // パーティクルエフェクトはGlobalTapDetectorが自動的に処理

    // ホットスポット操作を記録（RoomHotspotSystemのonTapで処理されるため、ここでは不要）

    // 特別なギミック処理
    if (widget.game != null) {
      _handleSpecialGimmicks(hotspot);
    }

    // カスタムコールバックがある場合は実行（ダミー座標）
    if (hotspot.onTap != null) {
      hotspot.onTap!(const Offset(0, 0)); // InkWellでは具体的な座標は不要
    }

    // ホットスポット詳細モーダルを表示（ギミック操作可能版）
    showDialog(
      context: context,
      barrierDismissible: true, // 外側タップで閉じる
      builder: (BuildContext context) {
        return HotspotDetailModal(hotspot: hotspot);
      },
    );
  }

  /// 特別なギミック処理（アイテム組み合わせと解除）
  void _handleSpecialGimmicks(HotspotData hotspot) {
    final game = widget.game;
    if (game == null) return;

    // 特別なギミックオブジェクトは何もしない（モーダル表示のみ）
    // ギミック発動はモーダル内のボタンで処理
    // 隠し部屋進入処理はモーダルタップ時に_onModalTapで処理
  }
}