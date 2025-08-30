import 'package:flutter/material.dart';
import '../room_hotspot_system.dart';
import '../inventory_system.dart';
import '../../../gen/assets.gen.dart';
import '../../../framework/ui/multi_floor_navigation_system.dart';
import '../../../framework/escape_room/core/room_types.dart';
import '../models/hotspot_models.dart';

class HotspotDetailModal extends StatelessWidget {
  final HotspotData hotspot;

  const HotspotDetailModal({super.key, required this.hotspot});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalSize = screenWidth * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
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

  void _executeGimmick(BuildContext context) {
    if (!_canExecuteGimmick()) return;

    final inventorySystem = InventorySystem();

    switch (hotspot.id) {
      case 'treasure_chest':
        final success = inventorySystem.addItem('escape_key');
        if (success) {
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
        inventorySystem.removeItemById('escape_key');

        debugPrint('🎉 脱出成功！ゲームクリア！escape_keyを消費');
        Navigator.of(context).pop();
        _showGameClearMessage(context);
        break;
    }
  }

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

  void _onModalTap(BuildContext context) {
    final inventorySystem = InventorySystem();
    final selectedItem = inventorySystem.selectedItemId;

    switch (hotspot.id) {
      case 'underground_stairs':
        if (selectedItem == 'main_escape_key') {
          inventorySystem.removeItemById('main_escape_key');
          debugPrint('🗝️ main_escape_keyを使用して地下の階段が解放されました');
          Navigator.of(context).pop();
        }
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

      case 'hidden_room_entrance_a':
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.floor1) {
          navigationSystem.moveToRoom(RoomType.hiddenA);
          debugPrint('🏠 隠し部屋Aに移動');
          Navigator.of(context).pop();
        } else {
          debugPrint('❌ 1階でのみ隠し部屋Aに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_b':
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.floor1) {
          navigationSystem.moveToRoom(RoomType.hiddenB);
          debugPrint('🏠 隠し部屋Bに移動');
          Navigator.of(context).pop();
        } else {
          debugPrint('❌ 1階でのみ隠し部屋Bに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_c':
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenC);
          debugPrint('🏠 隠し部屋Cに移動');
          Navigator.of(context).pop();
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Cに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_d':
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenD);
          debugPrint('🏠 隠し部屋Dに移動');
          Navigator.of(context).pop();
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Dに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_e':
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.floor1) {
          navigationSystem.moveToRoom(RoomType.hiddenE);
          debugPrint('🏠 隠し部屋Eに移動');
          Navigator.of(context).pop();
        } else {
          debugPrint('❌ 1階でのみ隠し部屋Eに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_f':
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenF);
          debugPrint('🏠 隠し部屋Fに移動');
          Navigator.of(context).pop();
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Fに移動できます');
        }
        break;
        
      case 'hidden_room_entrance_g':
        final navigationSystem = MultiFloorNavigationSystem();
        if (navigationSystem.currentFloor == FloorType.underground) {
          navigationSystem.moveToRoom(RoomType.hiddenG);
          debugPrint('🏠 隠し部屋Gに移動');
          Navigator.of(context).pop();
        } else {
          debugPrint('❌ 地下でのみ隠し部屋Gに移動できます');
        }
        break;

      default:
        break;
    }
  }
}