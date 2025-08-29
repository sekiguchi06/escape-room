import 'package:flutter/material.dart';
import '../../../gen/assets.gen.dart';

/// ホットスポットデータ
class HotspotData {
  final String id;
  final AssetGenImage asset;
  final String name;
  final String description;
  final Offset position;
  final Size size;
  final Function(Offset tapPosition)? onTap;
  final int? hotspotNumber; // ホットスポット番号（左上表示用）

  const HotspotData({
    required this.id,
    required this.asset,
    required this.name,
    required this.description,
    required this.position,
    required this.size,
    this.onTap,
    this.hotspotNumber,
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
