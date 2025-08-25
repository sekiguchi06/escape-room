import 'package:flutter/material.dart';

/// テスト用ルームコンポーネント（透明ホットスポット配置テスト）
/// Issue #4のホットスポット実装検証用
class TestRoomWithHotspots extends StatefulWidget {
  final String roomImagePath;
  final Size gameSize;

  const TestRoomWithHotspots({
    super.key,
    required this.roomImagePath,
    required this.gameSize,
  });

  @override
  State<TestRoomWithHotspots> createState() => _TestRoomWithHotspotsState();
}

class _TestRoomWithHotspotsState extends State<TestRoomWithHotspots> {
  final List<TestHotspot> _hotspots = [];

  @override
  void initState() {
    super.initState();
    _initializeTestHotspots();
  }

  /// テスト用ホットスポットを初期化（400x600統一サイズを想定）
  void _initializeTestHotspots() {
    _hotspots.addAll([
      // 左側ホットスポット（石柱想定）
      TestHotspot(
        id: 'test_left_pillar',
        position: const Offset(0.1, 0.4), // 相対座標（10%、40%）
        size: const Size(0.15, 0.2), // 相対サイズ（15%、20%）
        description: '古い石柱',
        isVisible: true, // 最初は可視化
      ),

      // 中央上部ホットスポット（天井装飾想定）
      TestHotspot(
        id: 'test_ceiling_decoration',
        position: const Offset(0.4, 0.1), // 相対座標（40%、10%）
        size: const Size(0.2, 0.15), // 相対サイズ（20%、15%）
        description: '天井のレリーフ',
        isVisible: true,
      ),

      // 右側ホットスポット（壁の装飾想定）
      TestHotspot(
        id: 'test_wall_decoration',
        position: const Offset(0.75, 0.3), // 相対座標（75%、30%）
        size: const Size(0.15, 0.25), // 相対サイズ（15%、25%）
        description: '壁面の紋章',
        isVisible: true,
      ),

      // 中央下部ホットスポット（床のオブジェクト想定）
      TestHotspot(
        id: 'test_floor_object',
        position: const Offset(0.35, 0.7), // 相対座標（35%、70%）
        size: const Size(0.3, 0.2), // 相対サイズ（30%、20%）
        description: '床に置かれた謎の箱',
        isVisible: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text('ホットスポットテスト'),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: _toggleHotspotVisibility,
            tooltip: 'ホットスポット可視性切り替え',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 背景画像
          Positioned.fill(
            child: Image.asset(
              widget.roomImagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '背景画像が見つかりません',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ホットスポット配置
          ..._hotspots.map((hotspot) => _buildHotspot(hotspot)),

          // デバッグ情報表示
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ゲームサイズ: ${widget.gameSize.width.toInt()}x${widget.gameSize.height.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'ホットスポット数: ${_hotspots.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    '可視化: ${_hotspots.first.isVisible ? "ON" : "OFF"}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotspot(TestHotspot hotspot) {
    // 相対座標を絶対座標に変換
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
            // Issue #4要求: 透明ホットスポット実装
            color: hotspot.isVisible
                ? Colors.yellow.withValues(alpha: 0.3) // デバッグ用可視化
                : Colors.transparent, // 透明（本番想定）
            borderRadius: BorderRadius.circular(8),
            border: hotspot.isVisible
                ? Border.all(color: Colors.yellow, width: 2)
                : null,
          ),
          child: hotspot.isVisible
              ? Center(
                  child: Text(
                    hotspot.id,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  void _onHotspotTapped(TestHotspot hotspot) {
    debugPrint('🎯 ホットスポットタップ: ${hotspot.id}');

    // タップフィードバック（視覚効果）
    _showTapFeedback(hotspot);

    // ホットスポット詳細ダイアログ表示
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            '🔍 ${hotspot.description}',
            style: TextStyle(
              color: Colors.amber[200],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ID: ${hotspot.id}',
                style: TextStyle(color: Colors.brown[100], fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                '座標: (${(hotspot.position.dx * 100).toStringAsFixed(1)}%, ${(hotspot.position.dy * 100).toStringAsFixed(1)}%)',
                style: TextStyle(color: Colors.brown[100], fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                'サイズ: ${(hotspot.size.width * 100).toStringAsFixed(1)}% × ${(hotspot.size.height * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.brown[100], fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(
                'テスト用ホットスポットです。\n透明状態でのタップ判定が正常に動作しています。',
                style: TextStyle(color: Colors.brown[200]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.brown[800],
              ),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _showTapFeedback(TestHotspot hotspot) {
    // タップされた位置に一時的なフィードバック表示
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        final left = hotspot.position.dx * widget.gameSize.width;
        final top = hotspot.position.dy * widget.gameSize.height;

        return Positioned(
          left: left + (hotspot.size.width * widget.gameSize.width) / 2 - 25,
          top: top + (hotspot.size.height * widget.gameSize.height) / 2 - 25,
          child: IgnorePointer(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.touch_app, color: Colors.amber, size: 30),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    // 500ms後にフィードバックを削除
    Future.delayed(const Duration(milliseconds: 500), () {
      overlayEntry.remove();
    });
  }

  void _toggleHotspotVisibility() {
    setState(() {
      final newVisibility = !_hotspots.first.isVisible;
      for (final hotspot in _hotspots) {
        hotspot.isVisible = newVisibility;
      }
    });
  }
}

/// テスト用ホットスポットデータクラス
class TestHotspot {
  final String id;
  final Offset position; // 相対座標（0.0-1.0）
  final Size size; // 相対サイズ（0.0-1.0）
  final String description;
  bool isVisible; // 可視性フラグ（デバッグ用）

  TestHotspot({
    required this.id,
    required this.position,
    required this.size,
    required this.description,
    this.isVisible = false,
  });
}
