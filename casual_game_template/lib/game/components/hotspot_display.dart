import 'package:flutter/material.dart';
import 'room_hotspot_system.dart';
import 'room_navigation_system.dart';

/// ホットスポット表示ウィジェット
class HotspotDisplay extends StatefulWidget {
  final Size gameSize;

  const HotspotDisplay({
    super.key,
    required this.gameSize,
  });

  @override
  State<HotspotDisplay> createState() => _HotspotDisplayState();
}

class _HotspotDisplayState extends State<HotspotDisplay> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RoomNavigationSystem(),
      builder: (context, _) {
        final hotspots = RoomHotspotSystem().getCurrentRoomHotspots();
        
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
            child: Image.asset(
              hotspot.imagePath,
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
    // デバッグ情報を出力
    debugPrint('🎯 ホットスポットタップ: ${hotspot.id}');
    debugPrint('🖼️ 画像パス: ${hotspot.imagePath}');
    
    // カスタムコールバックがある場合は実行
    if (hotspot.onTap != null) {
      hotspot.onTap!();
    }

    // ホットスポット詳細モーダルを表示（アイテムモーダルと同じスタイル）
    showDialog(
      context: context,
      barrierDismissible: true, // 外側タップで閉じる
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // 画像タップで閉じる
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 300,
                maxHeight: 300,
              ),
              decoration: BoxDecoration(
                color: Colors.brown[800], // 外枠の色
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.amber[700]!, // ゴールドの枠線
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(3), // 3pxの余白
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    hotspot.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // デバッグ情報を出力
                      debugPrint('❌ 画像読み込みエラー: ${hotspot.imagePath}');
                      debugPrint('❌ エラー詳細: $error');
                      
                      // 画像が見つからない場合の代替表示
                      return Container(
                        color: Colors.brown[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.help_outline,
                                size: 50,
                                color: Colors.brown[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'IMAGE NOT FOUND',
                                style: TextStyle(
                                  color: Colors.brown[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                hotspot.id,
                                style: TextStyle(
                                  color: Colors.brown[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}