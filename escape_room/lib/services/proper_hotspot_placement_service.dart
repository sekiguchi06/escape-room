import 'package:flutter/material.dart';
import '../game/components/models/hotspot_models.dart';
import '../game/components/room_hotspot_system.dart' as room_system;
import '../gen/assets.gen.dart';

/// 脱出ゲームのベストプラクティスに基づく適切なホットスポット配置サービス
///
/// Web調査で発見されたポイント&クリックアドベンチャーゲームの
/// 設計原則に基づいて実装：
/// 1. シンプルな単一タッチインターフェース
/// 2. 明確な視覚的フィードバック
/// 3. モバイル最適化されたタップエリア
/// 4. テーマ的一貫性
class ProperHotspotPlacementService {
  static final ProperHotspotPlacementService _instance =
      ProperHotspotPlacementService._internal();
  factory ProperHotspotPlacementService() => _instance;
  ProperHotspotPlacementService._internal();

  /// テスト部屋用の画像に基づく正確なホットスポット配置
  /// 400x600px豪華書斎画像の実際の内容に対応
  List<HotspotData> generateTestRoomHotspots() {
    debugPrint('🖼️ Generating image-based hotspots for test room...');

    return [
      // 1. 上部中央のシャンデリア（画像の実際の位置）
      _createHotspot(
        id: 'golden_chandelier',
        name: '黄金のシャンデリア',
        description: '天井から吊り下げられた豪華な黄金のシャンデリア。多数の蝋燭が美しく燃えている。',
        position: const Offset(0.5, 0.18), // 画像内の実際のシャンデリア位置
        size: const Size(0.25, 0.20), // シャンデリアのサイズに合わせて調整
        asset: Assets.images.hotspots.libraryCandelabra,
        interactionType: InteractionType.examine,
        difficulty: DifficultyLevel.medium,
      ),

      // 2. 左側の書見台（画像の実際の位置、モバイル最適化）
      _createHotspot(
        id: 'left_lectern',
        name: '書見台',
        description: '開かれた本が置かれた書見台。古代の文字で何かが記されている。',
        position: const Offset(0.25, 0.60), // 画像内の左側書見台の実際の位置
        size: const Size(0.30, 0.32), // モバイル最適化サイズ（96px最小）
        asset: Assets.images.hotspots.libraryDesk,
        interactionType: InteractionType.puzzle,
        difficulty: DifficultyLevel.easy,
      ),

      // 3. 右側の机と椅子（画像の実際の位置、モバイル最適化）
      _createHotspot(
        id: 'right_desk',
        name: '木製の机',
        description: '装飾が施された木製の机。椅子と共に配置されている。机の上には何かが置かれているようだ。',
        position: const Offset(0.75, 0.58), // 画像内の右側机の実際の位置（重複回避で上に移動）
        size: const Size(0.32, 0.30), // モバイル最適化サイズ
        asset: Assets.images.hotspots.libraryChair,
        interactionType: InteractionType.inventory,
        difficulty: DifficultyLevel.medium,
      ),

      // 4. 床の光る部分（画像の実際の光の位置、重複回避）
      _createHotspot(
        id: 'floor_light',
        name: '床の光',
        description: '床に差し込む温かい光。光の下に何かが隠されているかもしれない。',
        position: const Offset(0.5, 0.88), // 床の光の位置（重複回避で下に移動）
        size: const Size(0.28, 0.18), // モバイル最適化サイズ
        asset: Assets.images.hotspots.treasureChest,
        interactionType: InteractionType.secret,
        difficulty: DifficultyLevel.hard,
      ),
    ];
  }

  /// ホットスポット作成ヘルパーメソッド
  HotspotData _createHotspot({
    required String id,
    required String name,
    required String description,
    required Offset position,
    required Size size,
    required AssetGenImage asset,
    required InteractionType interactionType,
    required DifficultyLevel difficulty,
  }) {
    return HotspotData(
      id: id,
      asset: asset,
      name: name,
      description: description,
      position: position,
      size: size,
      onTap: (tapPosition) => _handleHotspotInteraction(
        id: id,
        name: name,
        interactionType: interactionType,
        difficulty: difficulty,
        tapPosition: tapPosition,
      ),
    );
  }

  /// ホットスポットインタラクションの処理
  void _handleHotspotInteraction({
    required String id,
    required String name,
    required InteractionType interactionType,
    required DifficultyLevel difficulty,
    required Offset tapPosition,
  }) {
    debugPrint('🎯 Hotspot interaction: $name (${interactionType.name})');

    // インタラクションタイプに基づく処理
    switch (interactionType) {
      case InteractionType.examine:
        _handleExamineInteraction(id, name);
        break;
      case InteractionType.puzzle:
        _handlePuzzleInteraction(id, name, difficulty);
        break;
      case InteractionType.inventory:
        _handleInventoryInteraction(id, name);
        break;
      case InteractionType.secret:
        _handleSecretInteraction(id, name, difficulty);
        break;
      case InteractionType.hint:
        _handleHintInteraction(id, name);
        break;
    }
  }

  /// 調査インタラクションの処理
  void _handleExamineInteraction(String id, String name) {
    debugPrint('🔍 Examining: $name');
    // ベースシステムに記録
    room_system.RoomHotspotSystem().recordHotspotInteraction(id);
    // プレイヤーフィードバック（UI表示）
    _showExamineFeedback(name);
  }

  /// パズルインタラクションの処理
  void _handlePuzzleInteraction(
    String id,
    String name,
    DifficultyLevel difficulty,
  ) {
    debugPrint('🧩 Puzzle interaction: $name (${difficulty.name})');
    room_system.RoomHotspotSystem().recordHotspotInteraction(id);
    // 難易度に応じたパズル表示
    _showPuzzleForDifficulty(id, name, difficulty);
  }

  /// インベントリインタラクションの処理
  void _handleInventoryInteraction(String id, String name) {
    debugPrint('📦 Inventory interaction: $name');
    room_system.RoomHotspotSystem().recordHotspotInteraction(id);
    // アイテム発見処理
    _tryDiscoverItem(id, name);
  }

  /// 秘密インタラクションの処理
  void _handleSecretInteraction(
    String id,
    String name,
    DifficultyLevel difficulty,
  ) {
    debugPrint('🤫 Secret interaction: $name');
    room_system.RoomHotspotSystem().recordHotspotInteraction(id);
    // 秘密要素の発見
    _revealSecret(id, name, difficulty);
  }

  /// ヒントインタラクションの処理
  void _handleHintInteraction(String id, String name) {
    debugPrint('💡 Hint interaction: $name');
    room_system.RoomHotspotSystem().recordHotspotInteraction(id);
    // ヒントの提供
    _provideHint(id, name);
  }

  /// 調査フィードバックの表示
  void _showExamineFeedback(String name) {
    debugPrint('👁️ Player examined: $name');
  }

  /// 難易度に応じたパズル表示
  void _showPuzzleForDifficulty(
    String id,
    String name,
    DifficultyLevel difficulty,
  ) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        debugPrint('🟢 Easy puzzle activated: $name');
        break;
      case DifficultyLevel.medium:
        debugPrint('🟡 Medium puzzle activated: $name');
        break;
      case DifficultyLevel.hard:
        debugPrint('🔴 Hard puzzle activated: $name');
        break;
    }
  }

  /// アイテム発見の試行
  void _tryDiscoverItem(String id, String name) {
    debugPrint('✨ Item discovery attempt: $name');
  }

  /// 秘密要素の公開
  void _revealSecret(String id, String name, DifficultyLevel difficulty) {
    debugPrint('🎊 Secret revealed: $name (${difficulty.name})');
  }

  /// ヒントの提供
  void _provideHint(String id, String name) {
    debugPrint('💭 Hint provided for: $name');
  }

  /// モバイル最適化されたタップエリア検証
  bool validateTapArea(Size tapSize, Size screenSize) {
    // Appleのヒューマンインターフェースガイドライン：最小44pt (iOS)
    // Googleのマテリアルデザイン：最小48dp (Android)
    const minTapSizeInDp = 48.0;
    const screenDensity = 2.0; // 一般的なモバイル画面密度

    final minTapSizeInPx = minTapSizeInDp * screenDensity;
    final actualTapWidth = tapSize.width * screenSize.width;
    final actualTapHeight = tapSize.height * screenSize.height;

    return actualTapWidth >= minTapSizeInPx &&
        actualTapHeight >= minTapSizeInPx;
  }

  /// ホットスポットの重複検出
  bool checkOverlap(List<HotspotData> hotspots) {
    for (int i = 0; i < hotspots.length; i++) {
      for (int j = i + 1; j < hotspots.length; j++) {
        if (_hotspotsOverlap(hotspots[i], hotspots[j])) {
          debugPrint(
            '⚠️ Overlap detected: ${hotspots[i].id} and ${hotspots[j].id}',
          );
          return true;
        }
      }
    }
    return false;
  }

  /// 2つのホットスポットの重複判定
  bool _hotspotsOverlap(HotspotData hotspot1, HotspotData hotspot2) {
    final rect1 = Rect.fromCenter(
      center: hotspot1.position,
      width: hotspot1.size.width,
      height: hotspot1.size.height,
    );
    final rect2 = Rect.fromCenter(
      center: hotspot2.position,
      width: hotspot2.size.width,
      height: hotspot2.size.height,
    );
    return rect1.overlaps(rect2);
  }
}

/// インタラクションタイプの定義
enum InteractionType {
  examine, // 調査・観察
  puzzle, // パズル解決
  inventory, // アイテム取得
  secret, // 隠し要素
  hint, // ヒント要素
}

/// 難易度レベルの定義
enum DifficultyLevel {
  easy, // 簡単 - 明確で直感的
  medium, // 中程度 - 少し考える必要
  hard, // 困難 - 深い観察と推理が必要
}
