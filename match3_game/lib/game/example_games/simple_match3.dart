import '../../framework/framework.dart';
import 'package:flutter/material.dart';

/// 使用例: 5分で作成できるシンプルなマッチ3パズル
class SimpleMatch3 extends QuickMatch3Template {
  @override
  Match3Config get gameConfig => const Match3Config(
    gridSize: Size(8, 8),
    pieceTypes: ['red', 'blue', 'green', 'yellow', 'purple', 'orange'],
    targetScore: 2000,
    gameTime: Duration(minutes: 3),
    minMatchCount: 3,
  );
  
  @override
  void onMatchFound(List<GridCell> matches, int score) {
    // カスタムマッチ処理（オプション）
    if (matches.length >= 5) {
      // 5個以上のマッチで特別なエフェクト
      managers.audioManager.playSfx('big_match');
    }
  }
}

/// 使用例: 小さなグリッドの高速ゲーム
class QuickMatch3 extends QuickMatch3Template {
  @override
  Match3Config get gameConfig => const Match3Config(
    gridSize: Size(6, 6),
    pieceTypes: ['red', 'blue', 'green', 'yellow'],
    targetScore: 1000,
    gameTime: Duration(minutes: 1),
    minMatchCount: 3,
  );
}

/// 使用例: 大きなグリッドの戦略的ゲーム
class BigMatch3 extends QuickMatch3Template {
  @override
  Match3Config get gameConfig => const Match3Config(
    gridSize: Size(10, 10),
    pieceTypes: ['red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink'],
    targetScore: 5000,
    gameTime: Duration(minutes: 5),
    minMatchCount: 3,
  );
}