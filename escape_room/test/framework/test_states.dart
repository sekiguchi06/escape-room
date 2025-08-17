import 'package:flutter/material.dart';
import 'package:escape_room/framework/state/game_state_system.dart';

/// テスト用の汎用ゲーム状態定義
class TestGameIdleState extends GameState {
  const TestGameIdleState() : super();
  
  @override
  String get name => 'idle';
  
  @override
  String get description => 'アイドル状態';
}

class TestGameActiveState extends GameState {
  final int level;
  final double progress;
  
  const TestGameActiveState({
    required this.level,
    required this.progress,
  }) : super();
  
  @override
  String get name => 'active';
  
  @override
  String get description => 'アクティブ状態 (レベル$level, 進捗${(progress * 100).toStringAsFixed(1)}%)';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'level': level,
      'progress': progress,
    };
  }
  
  @override
  bool operator ==(Object other) {
    return other is TestGameActiveState && 
           other.level == level &&
           other.progress == progress;
  }
  
  @override
  int get hashCode => Object.hash(name, level, progress);
}

class TestGameCompletedState extends GameState {
  final int finalLevel;
  final Duration completionTime;
  
  const TestGameCompletedState({
    required this.finalLevel,
    required this.completionTime,
  }) : super();
  
  @override
  String get name => 'completed';
  
  @override
  String get description => '完了状態 (最終レベル$finalLevel, 時間${completionTime.inSeconds}秒)';
  
  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'finalLevel': finalLevel,
      'completionTime': completionTime.inMilliseconds,
    };
  }
}