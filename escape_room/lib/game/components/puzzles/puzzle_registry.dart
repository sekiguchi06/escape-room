import 'package:flutter/material.dart';
import 'base_puzzle.dart';
import 'color_tap_puzzle.dart';
import 'sequence_memory_puzzle.dart';
import 'simple_choice_puzzle.dart';
import 'rotation_dial_puzzle.dart';
import 'simple_tap_test_puzzle.dart';

/// パズル一覧を管理するレジストリ
class PuzzleRegistry {
  static final List<PuzzleInfo> _puzzles = [
    PuzzleInfo(
      id: 'color_tap',
      title: '色合わせパズル',
      description: '3x3の円をタップして、すべて同じ色にしてください（ヒント付き）',
      difficulty: 1,
      estimatedDuration: 15,
      icon: Icons.palette,
      builder: () => const ColorTapPuzzle(),
    ),
    PuzzleInfo(
      id: 'sequence_memory',
      title: '順番記憶パズル',
      description: 'ボタンが光る順番を覚えて再現してください',
      difficulty: 2,
      estimatedDuration: 90,
      icon: Icons.psychology,
      builder: () => const SequenceMemoryPuzzle(),
    ),
    PuzzleInfo(
      id: 'simple_choice',
      title: 'シンプル選択パズル',
      description: '指示に従って正しいアイテムを選んでください',
      difficulty: 1,
      estimatedDuration: 30,
      icon: Icons.touch_app,
      builder: () => const SimpleChoicePuzzle(),
    ),
    PuzzleInfo(
      id: 'rotation_dial',
      title: '回転ダイヤルパズル',
      description: 'ダイヤルを回して正しい組み合わせにしてください',
      difficulty: 2,
      estimatedDuration: 90,
      icon: Icons.rotate_right,
      builder: () => const RotationDialPuzzle(),
    ),
    PuzzleInfo(
      id: 'simple_tap_test',
      title: 'タップテストパズル',
      description: 'ボタンをタップしてください（デバッグ用）',
      difficulty: 1,
      estimatedDuration: 10,
      icon: Icons.touch_app,
      builder: () => const SimpleTapTestPuzzle(),
    ),
  ];

  /// 全てのパズル情報を取得
  static List<PuzzleInfo> getAllPuzzles() {
    return List.unmodifiable(_puzzles);
  }

  /// IDでパズル情報を取得
  static PuzzleInfo? getPuzzleById(String id) {
    try {
      return _puzzles.firstWhere((puzzle) => puzzle.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 難易度でフィルタ
  static List<PuzzleInfo> getPuzzlesByDifficulty(int difficulty) {
    return _puzzles.where((puzzle) => puzzle.difficulty == difficulty).toList();
  }

  /// カテゴリー別統計
  static Map<String, int> getStatistics() {
    final stats = <String, int>{};
    
    for (var puzzle in _puzzles) {
      final difficultyKey = 'difficulty_${puzzle.difficulty}';
      stats[difficultyKey] = (stats[difficultyKey] ?? 0) + 1;
    }
    
    stats['total'] = _puzzles.length;
    stats['avg_duration'] = _puzzles.isNotEmpty 
        ? (_puzzles.map((p) => p.estimatedDuration).reduce((a, b) => a + b) / _puzzles.length).round()
        : 0;
    
    return stats;
  }

  /// パズルをランダムに選択
  static PuzzleInfo getRandomPuzzle([int? difficulty]) {
    final candidates = difficulty != null 
        ? getPuzzlesByDifficulty(difficulty)
        : _puzzles;
    
    if (candidates.isEmpty) return _puzzles.first;
    
    final random = DateTime.now().millisecondsSinceEpoch % candidates.length;
    return candidates[random];
  }
}