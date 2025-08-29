import 'package:flutter/material.dart';
import '../../gen/assets.gen.dart';
import '../../framework/persistence/data_manager.dart';
import 'inventory_system.dart';
import 'room_hotspot_system.dart';
import 'puzzles/simple_choice_puzzle.dart';
import 'models/hotspot_models.dart';
import 'widgets/hotspot_puzzle_modal.dart';

/// ホットスポットのパズル処理を管理するクラス
class HotspotPuzzleHandler {
  /// 光源調査ポイントのパズル処理
  static void handleLightSourcePuzzle(BuildContext context) async {
    final dataManager = DataManager.defaultInstance();
    final isCompleted = await dataManager.loadData<bool>('back_light_source_completed', defaultValue: false) ?? false;

    if (isCompleted) {
      // パズル完了済み - 仮画像を表示してタップ無効
      _showCompletedItemModal(context);
      return;
    }

    // パズル未完了 - パズルを開始
    _showLightSourcePuzzle(context);
  }

  /// パズル完了後の仮画像モーダル
  static void _showCompletedItemModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.brown[800],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber[700]!, width: 2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb,
                      size: 80,
                      color: Colors.amber[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '光のクリスタル\n(既に取得済み)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 光源パズル表示
  static void _showLightSourcePuzzle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final modalSize = screenWidth * 0.9; // 横幅の90%を正方形に

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: SizedBox(
            width: modalSize,
            height: modalSize,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SimpleChoicePuzzle(
                  onSuccess: () {
                    Navigator.of(context).pop();
                    _onPuzzleCompleted(context);
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// パズル完了時の処理
  static void _onPuzzleCompleted(BuildContext context) async {
    final dataManager = DataManager.defaultInstance();
    final inventorySystem = InventorySystem();
    
    // 完了フラグを設定
    await dataManager.saveData('back_light_source_completed', true);
    
    // アイテム取得
    final success = inventorySystem.addItem('light_crystal');
    if (success) {
      // アイテム発見通知
      RoomHotspotSystem().notifyItemDiscovered(
        itemId: 'light_crystal',
        itemName: '光のクリスタル',
        description: 'パズルを解いて手に入れた光るクリスタル',
        itemAsset: Assets.images.items.gem, // 仮アセット
      );
    }
  }

  /// 特別なギミック処理（アイテム組み合わせと解除）
  static void handleSpecialGimmicks(HotspotData hotspot, dynamic game) {
    if (game == null) return;

    // 特別なギミックオブジェクトは何もしない（モーダル表示のみ）
    // ギミック発動はモーダル内のボタンで処理
    // 隠し部屋進入処理はモーダルタップ時に_onModalTapで処理
  }
}