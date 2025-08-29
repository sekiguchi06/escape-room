import 'package:flutter/material.dart';
import 'dart:math';
import 'base_puzzle.dart';

/// 選択パズル - 正しいアイテムを選択する
class ChoiceSelectionPuzzle extends BasePuzzle {
  const ChoiceSelectionPuzzle({
    super.key,
    super.onSuccess,
    super.onCancel,
  }) : super(
          title: '選択パズル',
          description: '指示に従って正しいアイテムを選んでください',
        );

  @override
  String get puzzleType => 'choice_selection';

  @override
  int get difficulty => 1;

  @override
  int get estimatedDuration => 45;

  @override
  State<ChoiceSelectionPuzzle> createState() => _ChoiceSelectionPuzzleState();
}

class PuzzleItem {
  final String id;
  final IconData icon;
  final Color color;
  final String name;
  final String category;
  final int size; // 1=小, 2=中, 3=大

  PuzzleItem({
    required this.id,
    required this.icon,
    required this.color,
    required this.name,
    required this.category,
    required this.size,
  });
}

class _ChoiceSelectionPuzzleState extends State<ChoiceSelectionPuzzle> {
  late List<PuzzleItem> _items;
  late String _currentQuestion;
  late String _correctAnswer;
  int _currentRound = 1;
  int _maxRounds = 5;
  int _score = 0;
  late DateTime _startTime;

  // アイテムのカテゴリとアイコン
  static final List<PuzzleItem> _allItems = [
    // 動物
    PuzzleItem(id: 'cat', icon: Icons.pets, color: Colors.orange, name: 'ネコ', category: '動物', size: 2),
    PuzzleItem(id: 'dog', icon: Icons.pets, color: Colors.brown, name: 'イヌ', category: '動物', size: 2),
    PuzzleItem(id: 'bird', icon: Icons.flutter_dash, color: Colors.blue, name: 'トリ', category: '動物', size: 1),
    PuzzleItem(id: 'elephant', icon: Icons.pets, color: Colors.grey, name: 'ゾウ', category: '動物', size: 3),
    
    // 食べ物
    PuzzleItem(id: 'apple', icon: Icons.apple, color: Colors.red, name: 'リンゴ', category: '食べ物', size: 2),
    PuzzleItem(id: 'banana', icon: Icons.local_dining, color: Colors.yellow, name: 'バナナ', category: '食べ物', size: 2),
    PuzzleItem(id: 'cherry', icon: Icons.circle, color: Colors.red, name: 'サクランボ', category: '食べ物', size: 1),
    PuzzleItem(id: 'watermelon', icon: Icons.circle, color: Colors.green, name: 'スイカ', category: '食べ物', size: 3),
    
    // 乗り物
    PuzzleItem(id: 'car', icon: Icons.directions_car, color: Colors.blue, name: '車', category: '乗り物', size: 2),
    PuzzleItem(id: 'bike', icon: Icons.directions_bike, color: Colors.green, name: '自転車', category: '乗り物', size: 2),
    PuzzleItem(id: 'plane', icon: Icons.airplanemode_active, color: Colors.grey, name: '飛行機', category: '乗り物', size: 3),
    PuzzleItem(id: 'boat', icon: Icons.directions_boat, color: Colors.blue, name: '船', category: '乗り物', size: 3),
    
    // 色で分類
    PuzzleItem(id: 'red_heart', icon: Icons.favorite, color: Colors.red, name: '赤いハート', category: '赤色', size: 1),
    PuzzleItem(id: 'blue_star', icon: Icons.star, color: Colors.blue, name: '青い星', category: '青色', size: 1),
    PuzzleItem(id: 'green_leaf', icon: Icons.eco, color: Colors.green, name: '緑の葉', category: '緑色', size: 1),
    PuzzleItem(id: 'yellow_sun', icon: Icons.wb_sunny, color: Colors.yellow, name: '黄色い太陽', category: '黄色', size: 2),
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _generateRound();
  }

  void _generateRound() {
    final random = Random();
    
    // ランダムに6個のアイテムを選択
    final shuffledItems = List<PuzzleItem>.from(_allItems)..shuffle(random);
    _items = shuffledItems.take(6).toList();
    
    // 質問パターンをランダムに選択
    final questionPatterns = [
      '動物を選んでください',
      '食べ物を選んでください', 
      '乗り物を選んでください',
      '赤色のものを選んでください',
      '青色のものを選んでください',
      '緑色のものを選んでください',
      '黄色のものを選んでください',
      '一番大きいものを選んでください',
      '一番小さいものを選んでください',
    ];
    
    // 実際にアイテムが存在する質問のみを選択
    final validQuestions = questionPatterns.where((question) {
      return _getCorrectAnswersForQuestion(question, _items).isNotEmpty;
    }).toList();
    
    if (validQuestions.isEmpty) {
      // 再生成
      _generateRound();
      return;
    }
    
    _currentQuestion = validQuestions[random.nextInt(validQuestions.length)];
    final correctAnswers = _getCorrectAnswersForQuestion(_currentQuestion, _items);
    _correctAnswer = correctAnswers.first.id;
    
    setState(() {});
  }

  List<PuzzleItem> _getCorrectAnswersForQuestion(String question, List<PuzzleItem> items) {
    switch (question) {
      case '動物を選んでください':
        return items.where((item) => item.category == '動物').toList();
      case '食べ物を選んでください':
        return items.where((item) => item.category == '食べ物').toList();
      case '乗り物を選んでください':
        return items.where((item) => item.category == '乗り物').toList();
      case '赤色のものを選んでください':
        return items.where((item) => item.color == Colors.red || item.category == '赤色').toList();
      case '青色のものを選んでください':
        return items.where((item) => item.color == Colors.blue || item.category == '青色').toList();
      case '緑色のものを選んでください':
        return items.where((item) => item.color == Colors.green || item.category == '緑色').toList();
      case '黄色のものを選んでください':
        return items.where((item) => item.color == Colors.yellow || item.category == '黄色').toList();
      case '一番大きいものを選んでください':
        final maxSize = items.map((item) => item.size).reduce(max);
        return items.where((item) => item.size == maxSize).toList();
      case '一番小さいものを選んでください':
        final minSize = items.map((item) => item.size).reduce(min);
        return items.where((item) => item.size == minSize).toList();
      default:
        return [];
    }
  }

  void _onItemSelected(PuzzleItem item) {
    final correctAnswers = _getCorrectAnswersForQuestion(_currentQuestion, _items);
    final isCorrect = correctAnswers.any((correctItem) => correctItem.id == item.id);
    
    if (isCorrect) {
      _score++;
      _showFeedback(true, item);
    } else {
      _showFeedback(false, item);
    }
  }

  void _showFeedback(bool isCorrect, PuzzleItem selectedItem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(isCorrect ? '正解！' : '不正解'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('選択: ${selectedItem.name}'),
            if (!isCorrect) ...[
              const SizedBox(height: 8),
              Text('正解: ${_getCorrectAnswersForQuestion(_currentQuestion, _items).map((item) => item.name).join('、')}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nextRound();
            },
            child: const Text('次へ'),
          ),
        ],
      ),
    );
  }

  void _nextRound() {
    if (_currentRound >= _maxRounds) {
      _showCompleteDialog();
    } else {
      setState(() {
        _currentRound++;
      });
      _generateRound();
    }
  }

  void _showCompleteDialog() {
    final duration = DateTime.now().difference(_startTime).inSeconds;
    final accuracy = (_score / _maxRounds * 100).round();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('完了！'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('正解率: $accuracy% ($_score/$_maxRounds問正解)'),
            Text('完了時間: ${duration}秒'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSuccess?.call();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentRound = 1;
                _score = 0;
                _startTime = DateTime.now();
              });
              _generateRound();
            },
            child: const Text('もう一度'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} - ${_currentRound}/$_maxRounds'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentRound = 1;
                _score = 0;
                _startTime = DateTime.now();
              });
              _generateRound();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // スコア表示
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'スコア: $_score/$_maxRounds',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                LinearProgressIndicator(
                  value: _currentRound / _maxRounds,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 質問表示
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentQuestion,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // アイテム一覧
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return GestureDetector(
                    onTap: () => _onItemSelected(item),
                    child: Card(
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 48,
                            color: item.color,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getSizeText(item.size),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSizeText(int size) {
    switch (size) {
      case 1: return '小';
      case 2: return '中';
      case 3: return '大';
      default: return '';
    }
  }
}