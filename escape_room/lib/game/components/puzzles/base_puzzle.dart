import 'package:flutter/material.dart';

/// パズルの基本インターフェース
abstract class BasePuzzle extends StatefulWidget {
  final String title;
  final String description;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const BasePuzzle({
    super.key,
    required this.title,
    required this.description,
    this.onSuccess,
    this.onCancel,
  });

  /// パズルタイプを識別する文字列
  String get puzzleType;
  
  /// パズルの推定難易度（1-5）
  int get difficulty => 2;
  
  /// パズルの推定プレイ時間（秒）
  int get estimatedDuration => 60;
}

/// パズル成功時のコールバック情報
class PuzzleResult {
  final String puzzleType;
  final int duration;
  final bool success;
  final Map<String, dynamic>? metadata;

  const PuzzleResult({
    required this.puzzleType,
    required this.duration,
    required this.success,
    this.metadata,
  });
}

/// パズル一覧で表示するための情報
class PuzzleInfo {
  final String id;
  final String title;
  final String description;
  final int difficulty;
  final int estimatedDuration;
  final IconData icon;
  final Widget Function() builder;

  const PuzzleInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedDuration,
    required this.icon,
    required this.builder,
  });
}