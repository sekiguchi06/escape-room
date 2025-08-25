import 'package:flutter/material.dart';
import 'room_hotspot_system.dart';
import 'room_navigation_system.dart';
import 'inventory_system.dart';
import '../../gen/assets.gen.dart';
import '../../framework/ui/multi_floor_navigation_system.dart';
import '../../framework/escape_room/core/room_types.dart';
import 'models/hotspot_models.dart';

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
        return _HotspotDetailModal(hotspot: hotspot);
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

/// ホットスポット詳細モーダル
class _HotspotDetailModal extends StatelessWidget {
  final HotspotData hotspot;

  const _HotspotDetailModal({required this.hotspot});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalSize = screenWidth * 0.9; // 横幅の90%を正方形に

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20), // 画面端との余白
      child: SizedBox(
        width: modalSize,
        height: modalSize,
        child: GestureDetector(
          onTap: () => _onModalTap(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.brown[800],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber[700]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hotspot.asset.image(
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
      ),
    );
  }

  /// ギミック実行可能かチェック
  bool _canExecuteGimmick() {
    final inventorySystem = InventorySystem();
    switch (hotspot.id) {
      case 'treasure_chest':
        return inventorySystem.inventory.contains('master_key');
      case 'entrance_door':
        return inventorySystem.inventory.contains('escape_key');
      default:
        return false;
    }
  }

  /// ギミック実行
  void _executeGimmick(BuildContext context) {
    if (!_canExecuteGimmick()) return;

    final inventorySystem = InventorySystem();

    switch (hotspot.id) {
      case 'treasure_chest':
        // 宝箱のギミック解除
        final success = inventorySystem.addItem('escape_key');
        if (success) {
          // master_keyを消費
          inventorySystem.removeItemById('master_key');

          debugPrint('🗝️ 脱出の鍵を取得しました！master_keyを消費');
          RoomHotspotSystem().notifyItemDiscovered(
            itemId: 'escape_key',
            itemName: '脱出の鍵',
            description: '宝箱から取り出した最終的な脱出の鍵。これで城から脱出できる！',
            itemAsset: Assets.images.items.key,
          );

          Navigator.of(context).pop();
          _showGimmickSuccessMessage(context, '宝箱が開いた！最終的な脱出の鍵を発見！');
        }
        break;

      case 'entrance_door':
        // 扉のギミック解除
        // escape_keyを消費
        inventorySystem.removeItemById('escape_key');

        debugPrint('🎉 脱出成功！ゲームクリア！escape_keyを消費');
        Navigator.of(context).pop();
        _showGameClearMessage(context);
        break;
    }
  }

  /// ギミック成功メッセージを表示
  void _showGimmickSuccessMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.brown[800],
        title: Text(
          '🔓 ギミック解除成功！',
          style: TextStyle(
            color: Colors.amber[200],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(message, style: TextStyle(color: Colors.brown[100])),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.brown[800],
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// ゲームクリアメッセージを表示
  void _showGameClearMessage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.amber[800],
        title: Text(
          '🎉 ゲームクリア！',
          style: TextStyle(
            color: Colors.brown[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Text(
          '脱出成功！\n城から無事に脱出することができました！',
          style: TextStyle(color: Colors.brown[700], fontSize: 16),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // ゲームリスタート処理（オプション）
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[800],
              foregroundColor: Colors.amber[200],
            ),
            child: const Text('もう一度プレイ'),
          ),
        ],
      ),
    );
  }

  /// モーダル内タップ処理
  void _onModalTap(BuildContext context) {
    final inventorySystem = InventorySystem();
    final selectedItem = inventorySystem.selectedItemId;

    switch (hotspot.id) {
      case 'underground_stairs':
        // 地下への移動処理（main_escape_keyが必要）
        if (selectedItem == 'main_escape_key') {
          // main_escape_keyを使って地下の階段を解放
          inventorySystem.removeItemById('main_escape_key');
          debugPrint('🗝️ main_escape_keyを使用して地下の階段が解放されました');
          Navigator.of(context).pop();
        }
        // 条件が満たされていない場合は何も起こらない（モーダルも閉じない）
        break;

      case 'treasure_chest':
        if (selectedItem == 'master_key') {
          _executeGimmick(context);
        }
        break;

      case 'entrance_door':
        if (selectedItem == 'escape_key') {
          _executeGimmick(context);
        }
        break;

      // 隠し部屋入口の処理
      case 'hidden_room_entrance_a':
        // 1階にいる場合のみ隠し部屋Aに移動
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.floor1) {
          navigationSystem.moveToRoom(RoomType.hiddenA);
          debugPrint('🏠 隠し部屋Aに移動');
          Navigator.of(context).pop(); // モーダルを閉じる
        } else {
          debugPrint('❌ 1階でのみ隠し部屋Aに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_b':
        // 1階にいる場合のみ隠し部屋Bに移動
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.floor1) {
          navigationSystem.moveToRoom(RoomType.hiddenB);
          debugPrint('🏠 隠し部屋Bに移動');
          Navigator.of(context).pop(); // モーダルを閉じる
        } else {
          debugPrint('❌ 1階でのみ隠し部屋Bに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_c':
        // 地下にいる場合のみ隠し部屋Cに移動
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenC);
          debugPrint('🏠 隠し部屋Cに移動');
          Navigator.of(context).pop(); // モーダルを閉じる
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Cに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_d':
        // 地下にいる場合のみ隠し部屋Dに移動
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenD);
          debugPrint('🏠 隠し部屋Dに移動');
          Navigator.of(context).pop(); // モーダルを閉じる
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Dに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_e':
        // 1階にいる場合のみ隠し部屋Eに移動
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.floor1) {
          navigationSystem.moveToRoom(RoomType.hiddenE);
          debugPrint('🏠 隠し部屋Eに移動');
          Navigator.of(context).pop(); // モーダルを閉じる
        } else {
          debugPrint('❌ 1階でのみ隠し部屋Eに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_f':
        // 地下にいる場合のみ隠し部屋Fに移動
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenF);
          debugPrint('🏠 隠し部屋Fに移動');
          Navigator.of(context).pop(); // モーダルを閉じる
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Fに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_g':
        // 地下にいる場合のみ隠し部屋Gに移動
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenG);
          debugPrint('🏠 隠し部屋Gに移動');
          Navigator.of(context).pop(); // モーダルを閉じる
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Gに移動できます');
        }
        break;

      default:
        // その他のホットスポットでは何もしない
        break;
    }
  }
}

/// パズルモーダルダイアログ
class _PuzzleModalDialog extends StatefulWidget {
  final String title;
  final String description;
  final String correctAnswer;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const _PuzzleModalDialog({
    required this.title,
    required this.description,
    required this.correctAnswer,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_PuzzleModalDialog> createState() => _PuzzleModalDialogState();
}

class _PuzzleModalDialogState extends State<_PuzzleModalDialog> {
  final TextEditingController _controller = TextEditingController();
  String _inputValue = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.brown[800],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber[700]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // タイトル
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.amber[200],
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 説明
            Text(
              widget.description,
              style: TextStyle(color: Colors.brown[100], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 数字入力フィールド
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.brown[700],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[600]!, width: 1),
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber[100],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '4桁の数字',
                  hintStyle: TextStyle(color: Colors.brown[400], fontSize: 16),
                  counterText: '',
                ),
                onChanged: (value) {
                  setState(() {
                    _inputValue = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: widget.onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.brown[100],
                  ),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: _inputValue.length == 4 ? _checkAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.brown[800],
                  ),
                  child: const Text('確認'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer() {
    if (_inputValue == widget.correctAnswer) {
      // 正解
      widget.onSuccess();
    } else {
      // 不正解
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '間違った暗号です。もう一度お試しください。',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
        ),
      );
      _controller.clear();
      setState(() {
        _inputValue = '';
      });
    }
  }
}
