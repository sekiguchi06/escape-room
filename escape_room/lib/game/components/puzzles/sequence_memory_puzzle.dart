import 'package:flutter/material.dart';
import 'dart:math';
import 'base_puzzle.dart';

/// 順番記憶パズル - ボタンが光る順番を覚えて再現する
class SequenceMemoryPuzzle extends BasePuzzle {
  const SequenceMemoryPuzzle({
    super.key,
    super.onSuccess,
    super.onCancel,
  }) : super(
          title: '順番記憶パズル',
          description: 'ボタンが光る順番を覚えて、同じ順番でタップしてください',
        );

  @override
  String get puzzleType => 'sequence_memory';

  @override
  int get difficulty => 2;

  @override
  int get estimatedDuration => 90;

  @override
  State<SequenceMemoryPuzzle> createState() => _SequenceMemoryPuzzleState();
}

enum GamePhase { waiting, showing, inputting, success, failed }

class _SequenceMemoryPuzzleState extends State<SequenceMemoryPuzzle>
    with TickerProviderStateMixin {
  static const List<Color> _buttonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
  ];

  List<int> _sequence = [];
  List<int> _userInput = [];
  int _currentLevel = 1;
  GamePhase _phase = GamePhase.waiting;
  int _showingIndex = 0;
  int _highlightedButton = -1;
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _startLevel();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startLevel() {
    if (!mounted) return;
    
    setState(() {
      _phase = GamePhase.waiting;
      _userInput.clear();
      _highlightedButton = -1;
    });

    // シーケンスを生成（レベル + 2個）
    final random = Random();
    _sequence = List.generate(
      _currentLevel + 2,
      (index) => random.nextInt(4),
    );

    // 1秒後にシーケンス表示開始
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _showSequence();
      }
    });
  }

  void _showSequence() async {
    if (!mounted) return;
    
    setState(() {
      _phase = GamePhase.showing;
      _showingIndex = 0;
    });

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _highlightedButton = _sequence[i];
        _showingIndex = i;
      });
      
      _animationController.forward();
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (!mounted) return;
      _animationController.reverse();
      
      if (!mounted) return;
      setState(() {
        _highlightedButton = -1;
      });
      
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!mounted) return;
    setState(() {
      _phase = GamePhase.inputting;
    });
  }

  void _onButtonTapped(int buttonIndex) {
    if (_phase != GamePhase.inputting) return;

    setState(() {
      _userInput.add(buttonIndex);
    });

    // 入力チェック
    if (_userInput.last != _sequence[_userInput.length - 1]) {
      _onFailed();
      return;
    }

    // 全部正解した場合
    if (_userInput.length == _sequence.length) {
      _onLevelComplete();
    }
  }

  void _onLevelComplete() {
    setState(() {
      _phase = GamePhase.success;
    });

    if (_currentLevel >= 3) {
      // パズル完全クリア
      final duration = DateTime.now().difference(_startTime).inSeconds;
      _showCompleteDialog(duration);
    } else {
      // 次のレベルへ
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _currentLevel++;
          });
          _startLevel();
        }
      });
    }
  }

  void _onFailed() {
    if (!mounted) return;
    
    setState(() {
      _phase = GamePhase.failed;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _startLevel();
      }
    });
  }

  void _showCompleteDialog(int duration) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.amber),
            SizedBox(width: 8),
            Text('記憶力抜群！'),
          ],
        ),
        content: Text('全レベルクリア！\n完了時間: ${duration}秒'),
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
              if (mounted) {
                setState(() {
                  _currentLevel = 1;
                  _startTime = DateTime.now();
                });
                _startLevel();
              }
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
        title: Text('${widget.title} - レベル $_currentLevel'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (mounted) {
                setState(() {
                  _currentLevel = 1;
                  _startTime = DateTime.now();
                });
                _startLevel();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ステータス表示
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPhaseMessage(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPhaseColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // ボタンエリア
            Expanded(
              child: Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final isHighlighted = _highlightedButton == index;
                    final buttonColor = _buttonColors[index];
                    
                    return AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: isHighlighted ? _scaleAnimation.value : 1.0,
                          child: GestureDetector(
                            onTap: () => _onButtonTapped(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isHighlighted 
                                    ? buttonColor.withValues(alpha: 1.0)
                                    : buttonColor.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isHighlighted ? Colors.white : Colors.black26,
                                  width: isHighlighted ? 4 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isHighlighted 
                                        ? buttonColor.withValues(alpha: 0.5)
                                        : Colors.black12,
                                    blurRadius: isHighlighted ? 20 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isHighlighted ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            
            // 進行状況
            if (_phase == GamePhase.inputting)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: LinearProgressIndicator(
                  value: _userInput.length / _sequence.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getPhaseMessage() {
    switch (_phase) {
      case GamePhase.waiting:
        return 'まもなく順番を表示します...';
      case GamePhase.showing:
        return '順番を覚えてください (${_showingIndex + 1}/${_sequence.length})';
      case GamePhase.inputting:
        return '覚えた順番でタップしてください (${_userInput.length}/${_sequence.length})';
      case GamePhase.success:
        return _currentLevel >= 3 ? '全レベルクリア！' : 'レベル $_currentLevel クリア！';
      case GamePhase.failed:
        return '間違いです。もう一度挑戦しましょう';
    }
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case GamePhase.waiting:
        return Colors.blue;
      case GamePhase.showing:
        return Colors.orange;
      case GamePhase.inputting:
        return Colors.green;
      case GamePhase.success:
        return Colors.amber;
      case GamePhase.failed:
        return Colors.red;
    }
  }
}