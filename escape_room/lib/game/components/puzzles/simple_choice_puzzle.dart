import 'package:flutter/material.dart';
import 'base_puzzle.dart';
import '../../../gen/assets.gen.dart';

/// シンプル選択パズル - 3つのアイテムを順番に選択
class SimpleChoicePuzzle extends BasePuzzle {
  const SimpleChoicePuzzle({
    super.key,
    super.onSuccess,
    super.onCancel,
  }) : super(
          title: '',
          description: '',
        );

  @override
  String get puzzleType => 'simple_choice';

  @override
  int get difficulty => 1;

  @override
  int get estimatedDuration => 30;

  @override
  State<SimpleChoicePuzzle> createState() => _SimpleChoicePuzzleState();
}

class SimpleItem {
  final String name;
  final IconData icon;
  final Color color;
  final String type;

  SimpleItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class _SimpleChoicePuzzleState extends State<SimpleChoicePuzzle> {
  final List<SimpleItem> _selectedItems = [];
  
  // 正解の順番: 動物 → 食べ物 → 乗り物
  final List<String> _correctSequence = ['動物', '食べ物', '乗り物'];
  
  final List<SimpleItem> _allItems = [
    SimpleItem(name: 'ネコ', icon: Icons.pets, color: Colors.orange, type: '動物'),
    SimpleItem(name: 'イヌ', icon: Icons.pets, color: Colors.brown, type: '動物'),
    SimpleItem(name: 'トリ', icon: Icons.flutter_dash, color: Colors.blue, type: '動物'),
    
    SimpleItem(name: 'リンゴ', icon: Icons.apple, color: Colors.red, type: '食べ物'),
    SimpleItem(name: 'バナナ', icon: Icons.local_dining, color: Colors.yellow, type: '食べ物'),
    SimpleItem(name: 'オレンジ', icon: Icons.circle, color: Colors.orange, type: '食べ物'),
    
    SimpleItem(name: '車', icon: Icons.directions_car, color: Colors.blue, type: '乗り物'),
    SimpleItem(name: '自転車', icon: Icons.directions_bike, color: Colors.green, type: '乗り物'),
    SimpleItem(name: '飛行機', icon: Icons.airplanemode_active, color: Colors.grey, type: '乗り物'),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemSelected(SimpleItem item) {
    if (_selectedItems.length < 3) {
      setState(() {
        _selectedItems.add(item);
      });
      
      // 3つ選択完了時にチェック
      if (_selectedItems.length == 3) {
        _checkSequence();
      }
    }
  }
  
  void _checkSequence() {
    bool isCorrect = true;
    for (int i = 0; i < 3; i++) {
      if (_selectedItems[i].type != _correctSequence[i]) {
        isCorrect = false;
        break;
      }
    }
    
    if (isCorrect) {
      // 正解時はアイテム取得処理のみ実行
      widget.onSuccess?.call();
    } else {
      // 不正解時はリセット
      _resetSelections();
    }
  }
  
  void _resetSelections() {
    setState(() {
      _selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 地下への階段の背景画像
        image: DecorationImage(
          image: Assets.images.items.woodenStairs.provider(),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // 選択されたアイテム表示エリア（中央上部）
            Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 左のスロット
                  _buildSelectedSlot(0),
                  // 中央のスロット
                  _buildSelectedSlot(1),
                  // 右のスロット
                  _buildSelectedSlot(2),
                ],
              ),
            ),
            
            const Spacer(),
            
            // 選択可能なアイテム一覧（下部）
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: _allItems.length,
                itemBuilder: (context, index) {
                  final item = _allItems[index];
                  return GestureDetector(
                    onTap: () => _onItemSelected(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 24,
                            color: item.color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
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

  Widget _buildSelectedSlot(int index) {
    final hasItem = _selectedItems.length > index;
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasItem ? Colors.green : Colors.amber, 
          width: 2,
        ),
      ),
      child: hasItem
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedItems[index].icon,
                  size: 32,
                  color: _selectedItems[index].color,
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedItems[index].name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}