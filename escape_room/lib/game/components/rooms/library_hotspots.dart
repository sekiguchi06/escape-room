import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../models/hotspot_models.dart';
import '../inventory_system.dart';

/// 図書館のホットスポットコンフィグレーション
class LibraryHotspots {
  static List<HotspotData> getHotspots({
    required ItemDiscoveryCallback? onItemDiscovered,
  }) {
    return [
      HotspotData(
        id: 'library_desk',
        asset: Assets.images.hotspots.libraryDesk,
        name: '古い机',
        description: '巻物や書類が散らばった古い木の机。重要な情報が隠されているかも。',
        position: const Offset(0.2, 0.6),
        size: const Size(0.25, 0.2),
        onTap: (tapPosition) {
          debugPrint('📜 机を調べています...');
          debugPrint('🔍 調査結果: 暗号化された古文書を発見');
        },
      ),
      HotspotData(
        id: 'library_candelabra',
        asset: Assets.images.hotspots.libraryCandelabra,
        name: '燭台',
        description: '金色に輝く美しい燭台。ろうそくが静かに燃えている。',
        position: const Offset(0.7, 0.3),
        size: const Size(0.12, 0.25),
        onTap: (tapPosition) {
          debugPrint('🕯️ 燭台を調べています...');
          debugPrint('🔍 調査結果: 秘密の仕掛けがありそうだ');
        },
      ),
      HotspotData(
        id: 'library_chair',
        asset: Assets.images.hotspots.libraryChair,
        name: '革の椅子',
        description: '使い込まれた革の肘掛け椅子。座布団の下に何かが隠されているかも。',
        position: const Offset(0.5, 0.7),
        size: const Size(0.15, 0.2),
        onTap: (tapPosition) {
          debugPrint('🪑 椅子を調べています...');

          // アイテム取得機能（重複取得防止付き）
          final success = InventorySystem().acquireItemFromHotspot(
            'library_chair',
            'key',
          );
          if (success) {
            debugPrint('✨ アイテム発見！ 小さな鍵を手に入れました！');
            onItemDiscovered?.call(
              itemId: 'key',
              itemName: '小さな鍵',
              description: '椅子のクッションの下から見つかった小さな鍵。どこかの扉を開けられるかもしれない。',
              itemAsset: Assets.images.items.key,
            );
          } else if (InventorySystem().isItemAcquiredFromHotspot(
            'library_chair',
            'key',
          )) {
            debugPrint('🔍 調査結果: 既に調べた椅子です。もう鍵はありません');
          } else {
            debugPrint('🔍 調査結果: 小さな鍵を発見しましたが、インベントリがフルです');
          }
        },
      ),
    ];
  }
}
