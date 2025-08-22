import 'package:flutter/material.dart';
import 'room_navigation_system.dart';
import 'inventory_system.dart';
import '../../gen/assets.gen.dart';

/// ホットスポットデータ
class HotspotData {
  final String id;
  final AssetGenImage asset;
  final String name;
  final String description;
  final Offset position;
  final Size size;
  final Function(Offset tapPosition)? onTap;

  const HotspotData({
    required this.id,
    required this.asset,
    required this.name,
    required this.description,
    required this.position,
    required this.size,
    this.onTap,
  });
}

/// アイテム発見時のコールバック関数型
typedef ItemDiscoveryCallback =
    void Function({
      required String itemId,
      required String itemName,
      required String description,
      required AssetGenImage itemAsset,
    });

/// パズルモーダル表示要求のコールバック関数型
typedef PuzzleModalCallback =
    void Function({
      required String hotspotId,
      required String title,
      required String description,
      required String correctAnswer,
      required String rewardItemId,
      required String rewardItemName,
      required String rewardDescription,
      required AssetGenImage rewardAsset,
    });

/// 部屋別ホットスポットシステム
class RoomHotspotSystem extends ChangeNotifier {
  static final RoomHotspotSystem _instance = RoomHotspotSystem._internal();
  factory RoomHotspotSystem() => _instance;
  RoomHotspotSystem._internal();

  /// アイテム発見モーダル表示用コールバック
  ItemDiscoveryCallback? _onItemDiscovered;

  /// パズルモーダル表示用コールバック
  PuzzleModalCallback? _onPuzzleModalRequested;

  /// 操作されたホットスポットのID記録
  final Set<String> _interactedHotspots = <String>{};

  /// アイテム発見コールバックを設定
  void setItemDiscoveryCallback(ItemDiscoveryCallback? callback) {
    _onItemDiscovered = callback;
    debugPrint('🎊 Item discovery callback set: ${callback != null}');
  }

  /// パズルモーダルコールバックを設定
  void setPuzzleModalCallback(PuzzleModalCallback? callback) {
    _onPuzzleModalRequested = callback;
    debugPrint('🧩 Puzzle modal callback set: ${callback != null}');
  }

  /// アイテム発見を通知
  void notifyItemDiscovered({
    required String itemId,
    required String itemName,
    required String description,
    required AssetGenImage itemAsset,
  }) {
    _onItemDiscovered?.call(
      itemId: itemId,
      itemName: itemName,
      description: description,
      itemAsset: itemAsset,
    );
  }

  /// ホットスポット操作を記録
  void recordHotspotInteraction(String hotspotId) {
    _interactedHotspots.add(hotspotId);
    debugPrint('🔧 Hotspot interaction recorded: $hotspotId');
  }

  /// 操作されたホットスポットのリストを取得
  List<String> getInteractedHotspots() {
    return _interactedHotspots.toList();
  }

  /// 特定のホットスポットが操作されたかチェック
  bool hasInteractedWith(String hotspotId) {
    return _interactedHotspots.contains(hotspotId);
  }

  /// 現在の部屋のホットスポットを取得
  List<HotspotData> getCurrentRoomHotspots() {
    final currentRoom = RoomNavigationSystem().currentRoom;

    switch (currentRoom) {
      case RoomType.leftmost:
        return _getPrisonHotspots();
      case RoomType.left:
        return _getEntranceHotspots();
      case RoomType.center:
        return _getLibraryHotspots();
      case RoomType.right:
        return _getAlchemyHotspots();
      case RoomType.rightmost:
        return _getTreasureHotspots();
      case RoomType.testRoom:
        return _getTestRoomHotspots();
    }
  }

  /// 牢獄のホットスポット
  List<HotspotData> _getPrisonHotspots() {
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
          recordHotspotInteraction('prison_shackles');
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
          recordHotspotInteraction('prison_bucket');

          // アイテム取得機能（重複取得防止付き）
          final success = InventorySystem().acquireItemFromHotspot(
            'prison_bucket',
            'coin',
          );
          if (success) {
            debugPrint('✨ アイテム発見！ コインを手に入れました！');
            // itemDiscovery モーダルを表示
            _onItemDiscovered?.call(
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

  /// 城の入口のホットスポット
  List<HotspotData> _getEntranceHotspots() {
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
          debugPrint('🚪 扉を調べています...');
          recordHotspotInteraction('entrance_door');

          // 扉は特別なギミックなので、詳細処理はHotspotDisplayで実行
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
          recordHotspotInteraction('entrance_emblem');

          // パズル未解決の場合のみパズルモーダルを表示
          if (!InventorySystem().isItemAcquiredFromHotspot(
            'entrance_emblem',
            'escape_cipher',
          )) {
            debugPrint('🔍 調査結果: 紋章に4桁の暗号が刻まれている。解読が必要だ');
            // パズルモーダル表示のトリガー（HotspotDisplayで処理）
            _showEmblemPuzzleModal();
          } else {
            debugPrint('🔍 調査結果: 既に暗号を解読済みです');
          }
        },
      ),
    ];
  }

  /// 図書館のホットスポット
  List<HotspotData> _getLibraryHotspots() {
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
            // itemDiscovery モーダルを表示
            _onItemDiscovered?.call(
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

  /// 錬金術室のホットスポット
  List<HotspotData> _getAlchemyHotspots() {
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
          debugPrint('🔍 調査結果: 脱出の呪文が記されている');
        },
      ),
    ];
  }

  /// 宝物庫のホットスポット
  List<HotspotData> _getTreasureHotspots() {
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
          recordHotspotInteraction('treasure_chest');

          // 宝箱は特別なギミックなので、詳細処理はHotspotDisplayで実行
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
    ];
  }

  /// 紋章パズルモーダルを表示要求
  void _showEmblemPuzzleModal() {
    _onPuzzleModalRequested?.call(
      hotspotId: 'entrance_emblem',
      title: '古代の暗号解読',
      description: '紋章に刻まれた4桁の数字を解読してください',
      correctAnswer: '5297', // 城の入口にふさわしい暗号
      rewardItemId: 'escape_cipher',
      rewardItemName: '脱出の暗号',
      rewardDescription: '紋章から解読した古代の暗号。脱出の手がかりとなるかもしれない。',
      rewardAsset: Assets.images.items.book, // 古文書のアイテム画像
    );
  }

  /// パズル解決成功時の処理
  void onPuzzleSolved({
    required String hotspotId,
    required String rewardItemId,
    required String rewardItemName,
    required String rewardDescription,
    required AssetGenImage rewardAsset,
  }) {
    // アイテム取得機能（重複取得防止付き）
    final success = InventorySystem().acquireItemFromHotspot(
      hotspotId,
      rewardItemId,
    );
    if (success) {
      debugPrint('✨ パズル解決！ $rewardItemNameを手に入れました！');
      // itemDiscovery モーダルを表示
      _onItemDiscovered?.call(
        itemId: rewardItemId,
        itemName: rewardItemName,
        description: rewardDescription,
        itemAsset: rewardAsset,
      );
    }
  }

  /// テスト部屋のホットスポット
  List<HotspotData> _getTestRoomHotspots() {
    return [
      HotspotData(
        id: 'test_button',
        asset: Assets.images.hotspots.entranceDoor, // テスト用にドアアセット使用
        name: 'テストボタン',
        description: 'テスト用のインタラクティブボタン',
        position: const Offset(0.3, 0.5),
        size: const Size(0.2, 0.15),
        onTap: (tapPosition) {
          debugPrint('🧪 テストボタンがタップされました');
        },
      ),
      HotspotData(
        id: 'test_object',
        asset: Assets.images.hotspots.treasureChest, // テスト用に宝箱アセット使用
        name: 'テストオブジェクト',
        description: 'テスト用のオブジェクト',
        position: const Offset(0.6, 0.4),
        size: const Size(0.15, 0.2),
        onTap: (tapPosition) {
          debugPrint('🔍 テストオブジェクトを調査中...');
        },
      ),
    ];
  }
}
