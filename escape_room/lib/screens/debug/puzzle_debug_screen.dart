import 'package:flutter/material.dart';
import '../../game/components/puzzles/puzzle_registry.dart';
import '../../game/components/puzzles/base_puzzle.dart';
import '../../game/components/puzzles/color_tap_puzzle.dart';
import '../../game/components/puzzles/sequence_memory_puzzle.dart';
import '../../game/components/puzzles/simple_choice_puzzle.dart';
import '../../game/components/puzzles/rotation_dial_puzzle.dart';
import '../../game/components/puzzles/simple_tap_test_puzzle.dart';

/// パズルデバッグ画面 - 全てのパズルをテストできる
class PuzzleDebugScreen extends StatefulWidget {
  const PuzzleDebugScreen({super.key});

  @override
  State<PuzzleDebugScreen> createState() => _PuzzleDebugScreenState();
}

class _PuzzleDebugScreenState extends State<PuzzleDebugScreen> {
  String _searchQuery = '';
  int? _difficultyFilter;
  
  @override
  Widget build(BuildContext context) {
    final allPuzzles = PuzzleRegistry.getAllPuzzles();
    final stats = PuzzleRegistry.getStatistics();
    
    // デバッグ：全パズルのIDを出力
    print('🔧 DEBUG: All puzzle IDs: ${allPuzzles.map((p) => p.id).toList()}');
    
    // フィルタリング
    var filteredPuzzles = allPuzzles.where((puzzle) {
      final matchesSearch = _searchQuery.isEmpty ||
          puzzle.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          puzzle.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesDifficulty = _difficultyFilter == null ||
          puzzle.difficulty == _difficultyFilter;
      
      return matchesSearch && matchesDifficulty;
    }).toList();

    // 難易度順でソート
    filteredPuzzles.sort((a, b) => a.difficulty.compareTo(b.difficulty));
    
    // デバッグ：フィルタ後のパズルIDを出力
    print('🔧 DEBUG: Filtered puzzle IDs: ${filteredPuzzles.map((p) => p.id).toList()}');
    print('🔧 DEBUG: Filtered puzzles count: ${filteredPuzzles.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('パズルデバッグ'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // 統計情報
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'パズル統計',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatCard('総数', '${stats['total']}個 (表示:${filteredPuzzles.length})', Icons.apps),
                      const SizedBox(width: 16),
                      _buildStatCard('平均時間', '${stats['avg_duration']}秒', Icons.timer),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatCard('簡単', '${stats['difficulty_1'] ?? 0}個', Icons.sentiment_very_satisfied),
                      const SizedBox(width: 16),
                      _buildStatCard('普通', '${stats['difficulty_2'] ?? 0}個', Icons.sentiment_satisfied),
                      const SizedBox(width: 16),
                      _buildStatCard('難しい', '${stats['difficulty_3'] ?? 0}個', Icons.sentiment_dissatisfied),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // フィルタ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'パズルを検索...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<int?>(
                  initialValue: _difficultyFilter,
                  icon: Icon(
                    Icons.filter_alt,
                    color: _difficultyFilter != null ? Colors.blue : null,
                  ),
                  onSelected: (value) {
                    setState(() {
                      _difficultyFilter = value;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: null, child: Text('全ての難易度')),
                    const PopupMenuItem(value: 1, child: Text('簡単 (★)')),
                    const PopupMenuItem(value: 2, child: Text('普通 (★★)')),
                    const PopupMenuItem(value: 3, child: Text('難しい (★★★)')),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // パズル一覧
          Expanded(
            child: filteredPuzzles.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '条件に一致するパズルが見つかりません',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPuzzles.length,
                    itemBuilder: (context, index) {
                      final puzzle = filteredPuzzles[index];
                      return _buildPuzzleCard(context, puzzle);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleCard(BuildContext context, PuzzleInfo puzzle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getDifficultyColor(puzzle.difficulty).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            puzzle.icon,
            color: _getDifficultyColor(puzzle.difficulty),
            size: 30,
          ),
        ),
        title: Text(
          puzzle.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(puzzle.description),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildDifficultyStars(puzzle.difficulty),
                const SizedBox(width: 8),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 2),
                Text(
                  '${puzzle.estimatedDuration}秒',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _startPuzzle(context, puzzle),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getDifficultyColor(puzzle.difficulty),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('開始'),
        ),
      ),
    );
  }

  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      children: List.generate(3, (index) {
        return Icon(
          index < difficulty ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _startPuzzle(BuildContext context, PuzzleInfo puzzle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _buildPuzzleWidget(puzzle),
      ),
    );
  }

  Widget _buildPuzzleWidget(PuzzleInfo puzzle) {
    switch (puzzle.id) {
      case 'color_tap':
        return ColorTapPuzzle(
          onSuccess: () {
            Navigator.of(context).pop();
            _showSuccessSnackbar(context, puzzle.title);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      case 'sequence_memory':
        return SequenceMemoryPuzzle(
          onSuccess: () {
            Navigator.of(context).pop();
            _showSuccessSnackbar(context, puzzle.title);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      case 'simple_choice':
        return SimpleChoicePuzzle(
          onSuccess: () {
            Navigator.of(context).pop();
            _showSuccessSnackbar(context, puzzle.title);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      case 'rotation_dial':
        return RotationDialPuzzle(
          onSuccess: () {
            Navigator.of(context).pop();
            _showSuccessSnackbar(context, puzzle.title);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      case 'simple_tap_test':
        return SimpleTapTestPuzzle(
          onSuccess: () {
            Navigator.of(context).pop();
            _showSuccessSnackbar(context, puzzle.title);
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      default:
        return puzzle.builder();
    }
  }

  void _showSuccessSnackbar(BuildContext context, String puzzleTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration, color: Colors.white),
            const SizedBox(width: 8),
            Text('$puzzleTitle クリア！'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}