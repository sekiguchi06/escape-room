import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../models/hotspot_models.dart';
import '../inventory_system.dart';

/// 牢獄のホットスポットコンフィグレーション
class PrisonHotspots {
  static List<HotspotData> getHotspots({
    required Function(String) recordInteraction,
    required ItemDiscoveryCallback? onItemDiscovered,
  }) {
    return [
      HotspotData(
        id: 'prison_shackles',
        asset: Assets.images.hotspots.prisonShackles,
        name: '鉄の足枷',
        description: '錆びた鉄の足枷が壁に掛けられている。昔の囚人が使っていたものだろうか。',
        position: const Offset(0.2, 0.3),
        size: const Size(0.15, 0.2),
        onTap: (tapPosition) {
          debugPrint('🔗 足枷を調べています...');
          recordInteraction('prison_shackles');
          debugPrint('🔍 調査結果: 古い鍵が隠されているかもしれない');
        },
      ),
      HotspotData(
        id: 'prison_bucket',
        asset: Assets.images.hotspots.prisonBucket,
        name: '古い桶',
        description: '水が入った古い木の桶。底に何かが沈んでいるようだ。',
        position: const Offset(0.7, 0.6),
        size: const Size(0.12, 0.15),
        onTap: (tapPosition) {
          debugPrint('🪣 桶を調べています...');
          recordInteraction('prison_bucket');

          // アイテム取得機能（重複取得防止付き）
          final success = InventorySystem().acquireItemFromHotspot(
            'prison_bucket',
            'coin',
          );
          if (success) {
            debugPrint('✨ アイテム発見！ コインを手に入れました！');
            onItemDiscovered?.call(
              itemId: 'coin',
              itemName: '古いコイン',
              description: '桶の底から見つかった古いコイン。何かの支払いに使えるかもしれない。',
              itemAsset: Assets.images.items.coin,
            );
          } else if (InventorySystem().isItemAcquiredFromHotspot(
            'prison_bucket',
            'coin',
          )) {
            debugPrint('🔍 調査結果: 既に調べた桶です。もうコインはありません');
          } else {
            debugPrint('🔍 調査結果: コインを発見しましたが、インベントリがフルです');
          }
        },
      ),
      HotspotData(
        id: 'prison_bed',
        asset: Assets.images.hotspots.prisonBed,
        name: '石のベッド',
        description: '藁が敷かれた石のベッド。マットレスの下に何かが隠されているかも。',
        position: const Offset(0.5, 0.7),
        size: const Size(0.25, 0.2),
        onTap: (tapPosition) {
          debugPrint('🛏️ ベッドを調べています...');
          debugPrint('🔍 調査結果: 藁の下に地図の切れ端を発見');
        },
      ),
    ];
  }
}
