import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../models/hotspot_models.dart';
import '../inventory_system.dart';

/// 城の入口のホットスポットコンフィグレーション
class EntranceHotspots {
  static List<HotspotData> getHotspots({
    required Function(String) recordInteraction,
    required PuzzleModalCallback? onPuzzleModalRequested,
  }) {
    return [
      HotspotData(
        id: 'entrance_fountain',
        asset: Assets.images.hotspots.entranceFountain,
        name: '石の泉',
        description: '古い石造りの泉。水の音が静寂を破っている。',
        position: const Offset(0.3, 0.5),
        size: const Size(0.2, 0.25),
        onTap: (tapPosition) {
          debugPrint('⛲ 泉を調べています...');
          debugPrint('🔍 調査結果: 水底に光る何かが見える');
        },
      ),
      HotspotData(
        id: 'entrance_door',
        asset: Assets.images.hotspots.entranceDoor,
        name: '重厚な扉',
        description: '鉄の金具で補強された重い木の扉。しっかりと閉ざされている。',
        position: const Offset(0.7, 0.4),
        size: const Size(0.15, 0.3),
        onTap: (tapPosition) {
          debugPrint('🚦 扉を調べています...');
          recordInteraction('entrance_door');
          debugPrint('🔍 調査結果: 複雑な鍵穴がある、脱出の鍵が必要だ');
        },
      ),
      HotspotData(
        id: 'entrance_emblem',
        asset: Assets.images.hotspots.entranceEmblem,
        name: '紋章',
        description: '城の紋章が刻まれた石の装飾。何かの暗号になっているかもしれない。',
        position: const Offset(0.5, 0.2),
        size: const Size(0.18, 0.18),
        onTap: (tapPosition) {
          debugPrint('🛡️ 紋章を調べています...');
          recordInteraction('entrance_emblem');

          // パズル未解決の場合のみパズルモーダルを表示
          if (!InventorySystem().isItemAcquiredFromHotspot(
            'entrance_emblem',
            'escape_cipher',
          )) {
            debugPrint('🔍 調査結果: 紋章に4桁の暗号が刻まれている。解読が必要だ');
            onPuzzleModalRequested?.call(
              hotspotId: 'entrance_emblem',
              title: '古代の暗号解読',
              description: '紋章に刻まれた4桁の数字を解読してください',
              correctAnswer: '5297',
              rewardItemId: 'escape_cipher',
              rewardItemName: '脱出の暗号',
              rewardDescription: '紋章から解読した古代の暗号。脱出の手がかりとなるかもしれない。',
              rewardAsset: Assets.images.items.book,
            );
          } else {
            debugPrint('🔍 調査結果: 既に暗号を解読済みです');
          }
        },
      ),
    ];
  }
}
