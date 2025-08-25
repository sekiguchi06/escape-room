import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';
import '../../../framework/escape_room/core/room_types.dart';
import '../models/hotspot_models.dart';
import '../inventory_system.dart';
import '../../../framework/ui/multi_floor_navigation_system.dart';

/// 地下部屋の設定クラス
class UndergroundRoomConfig {
  /// 地下部屋の背景画像パス
  static const Map<RoomType, String> backgroundPaths = {
    RoomType.undergroundLeftmost: 'images/undergroundLeftmost.png',
    RoomType.undergroundLeft: 'images/undergroundLeft.png', 
    RoomType.undergroundCenter: 'images/undergroundCenter.png',
    RoomType.undergroundRight: 'images/undergroundRight.png',
    RoomType.undergroundRightmost: 'images/undergroundRightmost.png',
  };
  
  /// 地下部屋のホットスポット定義を取得
  static Map<RoomType, List<HotspotData>> getUndergroundHotspots({
    required ItemDiscoveryCallback? onItemDiscovered,
  }) {
    return {
      RoomType.undergroundLeftmost: _getLeftmostHotspots(onItemDiscovered),
      RoomType.undergroundLeft: _getLeftHotspots(onItemDiscovered), 
      RoomType.undergroundCenter: _getCenterHotspots(onItemDiscovered),
      RoomType.undergroundRight: _getRightHotspots(onItemDiscovered),
      RoomType.undergroundRightmost: _getRightmostHotspots(onItemDiscovered),
    };
  }
  
  /// 地下最左端のホットスポット
  static List<HotspotData> _getLeftmostHotspots(ItemDiscoveryCallback? onItemDiscovered) {
    return [
      HotspotData(
        id: 'underground_crystal_formation',
        asset: Assets.images.hotspots.libraryDesk, // 仮画像
        name: '水晶の結晶',
        description: '暗闇の中で不思議な光を放つ水晶の結晶群。触ると冷たく、何かの力を秘めているようだ。',
        position: const Offset(0.3, 0.5),
        size: const Size(0.2, 0.25),
        onTap: (tapPosition) {
          debugPrint('💎 水晶の結晶を調べています...');
          final success = InventorySystem().acquireItemFromHotspot(
            'underground_crystal_formation',
            'dark_crystal',
          );
          if (success) {
            debugPrint('✨ 闇のクリスタルを発見！');
            onItemDiscovered?.call(
              itemId: 'dark_crystal',
              itemName: '闇のクリスタル',
              description: '地下深くで見つけた暗い光を放つクリスタル。何かの儀式に使われていたようだ。',
              itemAsset: Assets.images.items.key, // 仮画像
            );
          } else if (InventorySystem().isItemAcquiredFromHotspot('underground_crystal_formation', 'dark_crystal')) {
            debugPrint('🔍 既に闇のクリスタルは取得済みです');
          }
        },
      ),
      HotspotData(
        id: 'undergroundLeft_wall',
        asset: Assets.images.hotspots.libraryCandelabra, // 仮画像
        name: '古い壁画',
        description: '地下の壁に描かれた謎めいた古代の壁画。象形文字のような記号が刻まれている。',
        position: const Offset(0.1, 0.3),
        size: const Size(0.15, 0.3),
        onTap: (tapPosition) {
          debugPrint('🎨 古い壁画を調べています...');
          debugPrint('🔍 調査結果: 古代の儀式について記されている');
        },
      ),
      HotspotData(
        id: 'underground_mysterious_door',
        asset: Assets.images.hotspots.libraryChair, // 仮画像
        name: '謎の扉',
        description: '鉄でできた重厚な扉。複雑な錠前が付いているが、今は開けることができない。',
        position: const Offset(0.7, 0.4),
        size: const Size(0.2, 0.4),
        onTap: (tapPosition) {
          debugPrint('🚪 謎の扉を調べています...');
          debugPrint('🔍 調査結果: 特別な鍵が必要そうだ');
        },
      ),
    ];
  }
  
  /// 地下左のホットスポット
  static List<HotspotData> _getLeftHotspots(ItemDiscoveryCallback? onItemDiscovered) {
    return [
      HotspotData(
        id: 'underground_ancient_altar',
        asset: Assets.images.hotspots.libraryDesk, // 仮画像
        name: '古代の祭壇',
        description: '石でできた古い祭壇。表面には複雑な文様が彫り込まれ、何かの儀式に使われていたようだ。',
        position: const Offset(0.4, 0.6),
        size: const Size(0.25, 0.2),
        onTap: (tapPosition) {
          debugPrint('⛩️ 古代の祭壇を調べています...');
          final success = InventorySystem().acquireItemFromHotspot(
            'underground_ancient_altar',
            'ritual_stone',
          );
          if (success) {
            debugPrint('✨ 儀式の石を発見！');
            onItemDiscovered?.call(
              itemId: 'ritual_stone',
              itemName: '儀式の石',
              description: '古代の儀式に使われていたと思われる神秘的な石。温かみのある光を放っている。',
              itemAsset: Assets.images.items.key, // 仮画像
            );
          } else if (InventorySystem().isItemAcquiredFromHotspot('underground_ancient_altar', 'ritual_stone')) {
            debugPrint('🔍 既に儀式の石は取得済みです');
          }
        },
      ),
      HotspotData(
        id: 'underground_bone_pile',
        asset: Assets.images.hotspots.libraryCandelabra, // 仮画像  
        name: '骨の山',
        description: '古い動物の骨が積み重なっている。何年も前からここにあるようだ。',
        position: const Offset(0.1, 0.7),
        size: const Size(0.15, 0.15),
        onTap: (tapPosition) {
          debugPrint('🦴 骨の山を調べています...');
          debugPrint('🔍 調査結果: とても古い骨のようだ');
        },
      ),
      HotspotData(
        id: 'underground_torch_holder',
        asset: Assets.images.hotspots.libraryChair, // 仮画像
        name: '松明立て',
        description: '壁に設置された古い松明立て。まだ火が燃えている。',
        position: const Offset(0.8, 0.2),
        size: const Size(0.1, 0.2),
        onTap: (tapPosition) {
          debugPrint('🔥 松明立てを調べています...');
          debugPrint('🔍 調査結果: 長時間燃え続けている不思議な火');
        },
      ),
    ];
  }
  
  /// 地下中央のホットスポット（エントランス）
  static List<HotspotData> _getCenterHotspots(ItemDiscoveryCallback? onItemDiscovered) {
    return [
      HotspotData(
        id: 'underground_water_source',
        asset: Assets.images.hotspots.libraryDesk, // 仮画像
        name: '地下水源',
        description: '透明で清らかな水が湧き出る小さな泉。水は驚くほど澄んでいる。',
        position: const Offset(0.5, 0.7),
        size: const Size(0.2, 0.15),
        onTap: (tapPosition) {
          debugPrint('💧 地下水源を調べています...');
          final success = InventorySystem().acquireItemFromHotspot(
            'underground_water_source', 
            'pure_water',
          );
          if (success) {
            debugPrint('✨ 清浄な水を発見！');
            onItemDiscovered?.call(
              itemId: 'pure_water',
              itemName: '清浄な水',
              description: '地下水源から湧き出る透明で清らかな水。神聖な力を持っているかもしれない。',
              itemAsset: Assets.images.items.key, // 仮画像
            );
          } else if (InventorySystem().isItemAcquiredFromHotspot('underground_water_source', 'pure_water')) {
            debugPrint('🔍 既に清浄な水は取得済みです');
          }
        },
      ),
      HotspotData(
        id: 'underground_stairs_up',
        asset: Assets.images.hotspots.libraryCandelabra, // プレースホルダー画像
        name: '上への階段',
        description: '1階に戻るための石の階段。苔が生えていて滑りやすそうだ。',
        position: const Offset(0.2, 0.3),
        size: const Size(0.2, 0.3),
        onTap: (tapPosition) async {
          debugPrint('⬆️ 【1階への階段】をタップしました');
          final navigation = MultiFloorNavigationSystem();
          
          // 現在の状態を詳細表示
          debugPrint('📊 現在の状況:');
          debugPrint('  現在階層: ${navigation.currentFloorName}');
          debugPrint('  現在部屋: ${navigation.currentRoomName}');
          
          // 現在の部屋位置チェック
          if (navigation.currentFloor != FloorType.underground || 
              navigation.currentRoom != RoomType.undergroundCenter) {
            debugPrint('❌ 地下中央にいません（現在: ${navigation.currentRoomName}）');
            debugPrint('💡 左右矢印ボタンで地下中央に移動してください');
            return;
          }
          
          // 1階移動実行
          debugPrint('⬆️ 1階に上がっています...');
          try {
            await navigation.moveToFloor1();
            debugPrint('✅ 1階rightmost部屋に到着しました！');
            debugPrint('🗺️ 左右矢印で1階を探索できます');
          } catch (e) {
            debugPrint('❌ 1階移動エラー: $e');
          }
        },
      ),
      HotspotData(
        id: 'underground_pillar',
        asset: Assets.images.hotspots.libraryChair, // 仮画像
        name: '石の柱',
        description: '天井を支える太い石の柱。表面に古代文字が刻まれている。',
        position: const Offset(0.7, 0.5),
        size: const Size(0.15, 0.4),
        onTap: (tapPosition) {
          debugPrint('🗿 石の柱を調べています...');
          debugPrint('🔍 調査結果: 古代の歴史について記されている');
        },
      ),
    ];
  }
  
  /// 地下右のホットスポット
  static List<HotspotData> _getRightHotspots(ItemDiscoveryCallback? onItemDiscovered) {
    return [
      HotspotData(
        id: 'underground_rune_wall',
        asset: Assets.images.hotspots.libraryDesk, // 仮画像
        name: 'ルーンの壁',
        description: '壁一面に古代ルーンが刻まれている。文字は薄く光っており、魔法の力を感じる。',
        position: const Offset(0.2, 0.4),
        size: const Size(0.3, 0.3),
        onTap: (tapPosition) {
          debugPrint('🔮 ルーンの壁を調べています...');
          final success = InventorySystem().acquireItemFromHotspot(
            'underground_rune_wall',
            'ancient_rune',
          );
          if (success) {
            debugPrint('✨ 古代ルーンを発見！');
            onItemDiscovered?.call(
              itemId: 'ancient_rune',
              itemName: '古代ルーン',
              description: '謎めいた文字が刻まれた古代の石版。強い魔法の力を秘めている。',
              itemAsset: Assets.images.items.key, // 仮画像
            );
          } else if (InventorySystem().isItemAcquiredFromHotspot('underground_rune_wall', 'ancient_rune')) {
            debugPrint('🔍 既に古代ルーンは取得済みです');
          }
        },
      ),
      HotspotData(
        id: 'underground_magic_circle',
        asset: Assets.images.hotspots.libraryCandelabra, // 仮画像
        name: '魔法陣',
        description: '床に描かれた複雑な魔法陣。まだ微かに光っており、古い魔法の名残を感じる。',
        position: const Offset(0.6, 0.6),
        size: const Size(0.25, 0.25),
        onTap: (tapPosition) {
          debugPrint('⭐ 魔法陣を調べています...');
          debugPrint('🔍 調査結果: 古代の魔法が込められている');
        },
      ),
      HotspotData(
        id: 'underground_crystal_orb',
        asset: Assets.images.hotspots.libraryChair, // 仮画像
        name: '水晶玉',
        description: '台座に置かれた大きな水晶玉。中に何かの映像が見えるような気がする。',
        position: const Offset(0.8, 0.3),
        size: const Size(0.12, 0.15),
        onTap: (tapPosition) {
          debugPrint('🔮 水晶玉を調べています...');
          debugPrint('🔍 調査結果: 過去や未来の映像が見えるかもしれない');
        },
      ),
    ];
  }
  
  /// 地下最右端のホットスポット
  static List<HotspotData> _getRightmostHotspots(ItemDiscoveryCallback? onItemDiscovered) {
    return [
      HotspotData(
        id: 'underground_treasure_vault',
        asset: Assets.images.hotspots.libraryDesk, // 仮画像
        name: '宝物庫',
        description: '古い宝箱や貴重品が置かれた宝物庫。金銀財宝が山積みになっている。',
        position: const Offset(0.4, 0.5),
        size: const Size(0.3, 0.25),
        onTap: (tapPosition) {
          debugPrint('💰 宝物庫を調べています...');
          final success = InventorySystem().acquireItemFromHotspot(
            'underground_treasure_vault',
            'underground_key',
          );
          if (success) {
            debugPrint('✨ 地下の鍵を発見！');
            onItemDiscovered?.call(
              itemId: 'underground_key',
              itemName: '地下の鍵',
              description: '地下の奥深くで発見された重厚な鍵。特別な扉を開けることができそうだ。',
              itemAsset: Assets.images.items.key, // 仮画像
            );
          } else if (InventorySystem().isItemAcquiredFromHotspot('underground_treasure_vault', 'underground_key')) {
            debugPrint('🔍 既に地下の鍵は取得済みです');
          }
        },
      ),
      HotspotData(
        id: 'underground_final_door',
        asset: Assets.images.hotspots.libraryCandelabra, // 仮画像
        name: '最終の扉',
        description: '地下の最奥にある厳重な扉。複数の錠前が取り付けられ、特別な条件を満たさないと開かない。',
        position: const Offset(0.1, 0.3),
        size: const Size(0.2, 0.4),
        onTap: (tapPosition) {
          debugPrint('🚪 最終の扉を調べています...');
          debugPrint('🔍 調査結果: すべての条件をクリアしないと開かない');
        },
      ),
      HotspotData(
        id: 'underground_guardian_statue',
        asset: Assets.images.hotspots.libraryChair, // 仮画像
        name: '守護者の像',
        description: '地下を守る古代の守護者の石像。目が赤く光り、侵入者を監視している。',
        position: const Offset(0.7, 0.6),
        size: const Size(0.15, 0.3),
        onTap: (tapPosition) {
          debugPrint('🗿 守護者の像を調べています...');
          debugPrint('🔍 調査結果: 古代の魔法で動かされているようだ');
        },
      ),
      // デバッグ用: 地下から1階への階段ホットスポット
      HotspotData(
        id: 'stairs_to_floor1',
        asset: Assets.images.hotspots.libraryDesk,
        name: '1階への階段',
        description: '地下から1階へと続く石の階段。上へと続いている。',
        position: const Offset(0.05, 0.1), // 左上角
        size: const Size(0.15, 0.15),
        onTap: (tapPosition) async {
          debugPrint('🪜 【1階への階段ホットスポット】タップ - 既存モーダル表示');
          // 既存のモーダルシステムが自動的に処理します
        },
      ),
    ];
  }
}