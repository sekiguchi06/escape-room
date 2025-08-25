import 'package:flutter/material.dart';
import 'components/test_room_with_hotspots.dart';

/// ホットスポットテスト用デモページ
/// Issue #4の透明ホットスポット機能検証用
class HotspotTestDemo extends StatefulWidget {
  const HotspotTestDemo({super.key});

  @override
  State<HotspotTestDemo> createState() => _HotspotTestDemoState();
}

class _HotspotTestDemoState extends State<HotspotTestDemo> {
  String _currentRoom = 'assets/images/room_left.png';
  final List<String> _availableRooms = [
    'assets/images/room_left.png',
    'assets/images/room_right.png',
    'assets/images/room_leftmost.png',
    'assets/images/room_rightmost.png',
  ];
  int _currentRoomIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ゲームサイズ（統一規格400x600）
    final gameSize = const Size(400, 600);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: const Text('ホットスポット機能テスト'),
        actions: [
          // ルーム切り替えボタン
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: _switchToNextRoom,
            tooltip: '次の部屋',
          ),
          // ホットスポット情報表示ボタン
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTestInfo,
            tooltip: 'テスト情報',
          ),
        ],
      ),
      body: Column(
        children: [
          // テスト情報バー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '現在の部屋: ${_getRoomName(_currentRoom)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'サイズ: ${gameSize.width.toInt()}×${gameSize.height.toInt()}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // メインテストエリア
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: gameSize.width,
                  maxHeight: gameSize.height,
                ),
                child: AspectRatio(
                  aspectRatio: gameSize.width / gameSize.height,
                  child: TestRoomWithHotspots(
                    key: ValueKey(_currentRoom), // ルーム変更時に再構築
                    roomImagePath: _currentRoom,
                    gameSize: gameSize,
                  ),
                ),
              ),
            ),
          ),

          // コントロールパネル
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[800],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _switchToNextRoom,
                      icon: const Icon(Icons.room_preferences),
                      label: const Text('部屋変更'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showTestInfo,
                      icon: const Icon(Icons.help),
                      label: const Text('ヘルプ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'タップボタンでホットスポットの可視性を切り替えできます',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _switchToNextRoom() {
    setState(() {
      _currentRoomIndex = (_currentRoomIndex + 1) % _availableRooms.length;
      _currentRoom = _availableRooms[_currentRoomIndex];
    });
  }

  String _getRoomName(String roomPath) {
    final roomNames = {
      'assets/images/room_left.png': '左の部屋（石造回廊）',
      'assets/images/room_right.png': '右の部屋（錬金術室）',
      'assets/images/room_leftmost.png': '最左の部屋（地下通路）',
      'assets/images/room_rightmost.png': '最右の部屋（宝物庫）',
    };
    return roomNames[roomPath] ?? '不明な部屋';
  }

  void _showTestInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            '🧪 ホットスポットテスト',
            style: TextStyle(
              color: Colors.amber[200],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('📋 テスト目的', [
                  'GitHub Issue #4の透明ホットスポット機能検証',
                  '400×600統一サイズでの座標精度確認',
                  'タップ判定の正確性確認',
                ]),
                const SizedBox(height: 16),
                _buildInfoSection('🎯 配置されたホットスポット', [
                  '左側: 石柱想定ホットスポット (10%, 40%)',
                  '中央上: 天井装飾想定 (40%, 10%)',
                  '右側: 壁面紋章想定 (75%, 30%)',
                  '中央下: 床のオブジェクト想定 (35%, 70%)',
                ]),
                const SizedBox(height: 16),
                _buildInfoSection('⚙️ 操作方法', [
                  '目のアイコン: ホットスポット可視性切り替え',
                  'ホットスポットタップ: 詳細情報表示',
                  '部屋変更ボタン: 4つの部屋を順次切り替え',
                ]),
                const SizedBox(height: 16),
                _buildInfoSection('✅ 確認ポイント', [
                  '透明時でもタップ判定が正常に動作する',
                  '可視化時は黄色い境界線が表示される',
                  '座標が各部屋で一定している',
                  'タップフィードバックが適切に表示される',
                ]),
              ],
            ),
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

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.amber[300],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: Colors.brown[200])),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(color: Colors.brown[100], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
