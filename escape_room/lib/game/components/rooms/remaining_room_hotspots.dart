import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../models/hotspot_models.dart';

/// 錬金術室のホットスポットコンフィグレーション
class AlchemyHotspots {
  static List<HotspotData> getHotspots() {
    return [
      HotspotData(
        id: 'alchemy_cauldron',
        asset: Assets.images.hotspots.alchemyCauldron,
        name: '錬金術の大釜',
        description: '泡立つ薬液が入った大きな釜。魔法の実験に使われていたようだ。',
        position: const Offset(0.3, 0.5),
        size: const Size(0.2, 0.25),
        onTap: (tapPosition) {
          debugPrint('🧪 大釜を調べています...');
          debugPrint('🔍 調査結果: 不思議な薬液が魔法のエネルギーを放っている');
        },
      ),
      HotspotData(
        id: 'alchemy_bottles',
        asset: Assets.images.hotspots.alchemyBottles,
        name: 'ポーション瓶',
        description: '色とりどりの液体が入ったガラス瓶。それぞれ異なる効果がありそうだ。',
        position: const Offset(0.7, 0.3),
        size: const Size(0.15, 0.3),
        onTap: (tapPosition) {
          debugPrint('🧫 薬瓶を調べています...');
          debugPrint('🔍 調査結果: 治癒のポーションと変身薬が見つかった');
        },
      ),
      HotspotData(
        id: 'alchemy_spellbook',
        asset: Assets.images.hotspots.alchemySpellbook,
        name: '魔法書',
        description: '古代の文字で書かれた魔法書。ページが光っている。',
        position: const Offset(0.5, 0.7),
        size: const Size(0.18, 0.15),
        onTap: (tapPosition) {
          debugPrint('📚 魔法書を調べています...');
          debugPrint('🔍 調査結果: 脱出の呢文が記されている');
        },
      ),
    ];
  }
}

/// 宝物庫のホットスポットコンフィグレーション
class TreasureHotspots {
  static List<HotspotData> getHotspots({
    required Function(String) recordInteraction,
    required BuildContext context,
  }) {
    return [
      HotspotData(
        id: 'treasure_chest',
        asset: Assets.images.hotspots.treasureChest,
        name: '黄金の宝箱',
        description: '宝石で装飾された豪華な宝箱。中には何が入っているのだろうか。',
        position: const Offset(0.3, 0.6),
        size: const Size(0.2, 0.15),
        onTap: (tapPosition) {
          debugPrint('💰 宝箱を調べています...');
          recordInteraction('treasure_chest');
          debugPrint('🔍 調査結果: 宝箱には特別な鍵が必要だ');
        },
      ),
      HotspotData(
        id: 'treasure_crown',
        asset: Assets.images.hotspots.treasureCrown,
        name: '王冠',
        description: '宝石がちりばめられた美しい王冠。王族の象徴だ。',
        position: const Offset(0.7, 0.3),
        size: const Size(0.12, 0.15),
        onTap: (tapPosition) {
          debugPrint('👑 王冠を調べています...');
          debugPrint('🔍 調査結果: 王家の印章が刻まれている');
        },
      ),
      HotspotData(
        id: 'treasure_goblet',
        asset: Assets.images.hotspots.treasureGoblet,
        name: '聖杯',
        description: 'ルビーで飾られた金の聖杯。神聖な力を感じる。',
        position: const Offset(0.5, 0.5),
        size: const Size(0.1, 0.2),
        onTap: (tapPosition) {
          debugPrint('🏆 聖杯を調べています...');
          debugPrint('🔍 調査結果: 古代の祝福が込められている');
        },
      ),
      // 地下への階段（2段階タップ仕様）
      HotspotData(
        id: 'underground_stairs',
        asset: Assets.images.hotspots.libraryDesk,
        name: '地下への階段',
        description: '宝物庫の奥に隠された古い石の階段。地下深くへと続いている。',
        position: const Offset(0.1, 0.8),
        size: const Size(0.15, 0.15),
        onTap: (tapPosition) async {
          debugPrint('🪜 【地下への階段ホットスポット】タップ - 既存モーダル表示');
          // 既存のモーダルシステムが自動的に処理します
        },
      ),
    ];
  }
}
