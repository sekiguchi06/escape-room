import 'package:flutter/material.dart';
import 'room_navigation_system.dart';

/// ホットスポットデータ
class HotspotData {
  final String id;
  final String imagePath;
  final String name;
  final String description;
  final Offset position;
  final Size size;
  final VoidCallback? onTap;

  const HotspotData({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.description,
    required this.position,
    required this.size,
    this.onTap,
  });
}

/// 部屋別ホットスポットシステム
class RoomHotspotSystem extends ChangeNotifier {
  static final RoomHotspotSystem _instance = RoomHotspotSystem._internal();
  factory RoomHotspotSystem() => _instance;
  RoomHotspotSystem._internal();

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
    }
  }

  /// 牢獄のホットスポット
  List<HotspotData> _getPrisonHotspots() {
    return [
      HotspotData(
        id: 'prison_shackles',
        imagePath: 'assets/images/hotspots/new/prison_shackles.png',
        name: '鉄の足枷',
        description: '錆びた鉄の足枷が壁に掛けられている。昔の囚人が使っていたものだろうか。',
        position: const Offset(0.2, 0.3),
        size: const Size(0.15, 0.2),
        onTap: () => debugPrint('🔗 足枷を調べた: 古い鍵が隠されているかもしれない'),
      ),
      HotspotData(
        id: 'prison_bucket',
        imagePath: 'assets/images/hotspots/new/prison_bucket.png',
        name: '古い桶',
        description: '水が入った古い木の桶。底に何かが沈んでいるようだ。',
        position: const Offset(0.7, 0.6),
        size: const Size(0.12, 0.15),
        onTap: () => debugPrint('🪣 桶を調べた: 底からコインが見つかった'),
      ),
      HotspotData(
        id: 'prison_bed',
        imagePath: 'assets/images/hotspots/new/prison_bed.png',
        name: '石のベッド',
        description: '藁が敷かれた石のベッド。マットレスの下に何かが隠されているかも。',
        position: const Offset(0.5, 0.7),
        size: const Size(0.25, 0.2),
        onTap: () => debugPrint('🛏️ ベッドを調べた: 藁の下に地図の切れ端を発見'),
      ),
    ];
  }

  /// 城の入口のホットスポット
  List<HotspotData> _getEntranceHotspots() {
    return [
      HotspotData(
        id: 'entrance_fountain',
        imagePath: 'assets/images/hotspots/new/entrance_fountain.png',
        name: '石の泉',
        description: '古い石造りの泉。水の音が静寂を破っている。',
        position: const Offset(0.3, 0.5),
        size: const Size(0.2, 0.25),
        onTap: () => debugPrint('⛲ 泉を調べた: 水底に光る何かが見える'),
      ),
      HotspotData(
        id: 'entrance_door',
        imagePath: 'assets/images/hotspots/new/entrance_door.png',
        name: '重厚な扉',
        description: '鉄の金具で補強された重い木の扉。しっかりと閉ざされている。',
        position: const Offset(0.7, 0.4),
        size: const Size(0.15, 0.3),
        onTap: () => debugPrint('🚪 扉を調べた: 複雑な鍵穴がある、特別な鍵が必要だ'),
      ),
      HotspotData(
        id: 'entrance_emblem',
        imagePath: 'assets/images/hotspots/new/entrance_emblem.png',
        name: '紋章',
        description: '城の紋章が刻まれた石の装飾。何かの暗号になっているかもしれない。',
        position: const Offset(0.5, 0.2),
        size: const Size(0.18, 0.18),
        onTap: () => debugPrint('🛡️ 紋章を調べた: 数字の組み合わせが隠されている'),
      ),
    ];
  }

  /// 図書館のホットスポット
  List<HotspotData> _getLibraryHotspots() {
    return [
      HotspotData(
        id: 'library_desk',
        imagePath: 'assets/images/hotspots/new/library_desk.png',
        name: '古い机',
        description: '巻物や書類が散らばった古い木の机。重要な情報が隠されているかも。',
        position: const Offset(0.2, 0.6),
        size: const Size(0.25, 0.2),
        onTap: () => debugPrint('📜 机を調べた: 暗号化された古文書を発見'),
      ),
      HotspotData(
        id: 'library_candelabra',
        imagePath: 'assets/images/hotspots/new/library_candelabra.png',
        name: '燭台',
        description: '金色に輝く美しい燭台。ろうそくが静かに燃えている。',
        position: const Offset(0.7, 0.3),
        size: const Size(0.12, 0.25),
        onTap: () => debugPrint('🕯️ 燭台を調べた: 秘密の仕掛けがありそうだ'),
      ),
      HotspotData(
        id: 'library_chair',
        imagePath: 'assets/images/hotspots/new/library_chair.png',
        name: '革の椅子',
        description: '使い込まれた革の肘掛け椅子。座布団の下に何かが隠されているかも。',
        position: const Offset(0.5, 0.7),
        size: const Size(0.15, 0.2),
        onTap: () => debugPrint('🪑 椅子を調べた: クッションの下に小さな鍵を発見'),
      ),
    ];
  }

  /// 錬金術室のホットスポット
  List<HotspotData> _getAlchemyHotspots() {
    return [
      HotspotData(
        id: 'alchemy_cauldron',
        imagePath: 'assets/images/hotspots/new/alchemy_cauldron.png',
        name: '錬金術の大釜',
        description: '泡立つ薬液が入った大きな釜。魔法の実験に使われていたようだ。',
        position: const Offset(0.3, 0.5),
        size: const Size(0.2, 0.25),
        onTap: () => debugPrint('🧪 大釜を調べた: 不思議な薬液が魔法のエネルギーを放っている'),
      ),
      HotspotData(
        id: 'alchemy_bottles',
        imagePath: 'assets/images/hotspots/new/alchemy_bottles.png',
        name: 'ポーション瓶',
        description: '色とりどりの液体が入ったガラス瓶。それぞれ異なる効果がありそうだ。',
        position: const Offset(0.7, 0.3),
        size: const Size(0.15, 0.3),
        onTap: () => debugPrint('🧫 薬瓶を調べた: 治癒のポーションと変身薬が見つかった'),
      ),
      HotspotData(
        id: 'alchemy_spellbook',
        imagePath: 'assets/images/hotspots/new/alchemy_spellbook.png',
        name: '魔法書',
        description: '古代の文字で書かれた魔法書。ページが光っている。',
        position: const Offset(0.5, 0.7),
        size: const Size(0.18, 0.15),
        onTap: () => debugPrint('📚 魔法書を調べた: 脱出の呪文が記されている'),
      ),
    ];
  }

  /// 宝物庫のホットスポット
  List<HotspotData> _getTreasureHotspots() {
    return [
      HotspotData(
        id: 'treasure_chest',
        imagePath: 'assets/images/hotspots/new/treasure_chest.png',
        name: '黄金の宝箱',
        description: '宝石で装飾された豪華な宝箱。中には何が入っているのだろうか。',
        position: const Offset(0.3, 0.6),
        size: const Size(0.2, 0.15),
        onTap: () => debugPrint('💰 宝箱を調べた: 最終的な脱出の鍵が入っている'),
      ),
      HotspotData(
        id: 'treasure_crown',
        imagePath: 'assets/images/hotspots/new/treasure_crown.png',
        name: '王冠',
        description: '宝石がちりばめられた美しい王冠。王族の象徴だ。',
        position: const Offset(0.7, 0.3),
        size: const Size(0.12, 0.15),
        onTap: () => debugPrint('👑 王冠を調べた: 王家の印章が刻まれている'),
      ),
      HotspotData(
        id: 'treasure_goblet',
        imagePath: 'assets/images/hotspots/new/treasure_goblet.png',
        name: '聖杯',
        description: 'ルビーで飾られた金の聖杯。神聖な力を感じる。',
        position: const Offset(0.5, 0.5),
        size: const Size(0.1, 0.2),
        onTap: () => debugPrint('🏆 聖杯を調べた: 古代の祝福が込められている'),
      ),
    ];
  }
}