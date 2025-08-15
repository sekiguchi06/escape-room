import 'package:flutter/material.dart';

/// アイテム詳細表示モーダル
class ItemDetailModal {
  /// アイテム詳細表示モーダルを表示
  static void show(BuildContext context, String itemId) {
    final itemInfo = _getItemInfo(itemId);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.brown[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.brown[400]!, width: 2),
          ),
          title: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: itemInfo['bgColor'],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: itemInfo['color'], width: 2),
                ),
                child: Icon(
                  itemInfo['icon'],
                  color: itemInfo['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemInfo['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      itemInfo['category'],
                      style: TextStyle(
                        color: Colors.brown[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Container(
            constraints: const BoxConstraints(minHeight: 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: itemInfo['bgColor'].withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: itemInfo['color'].withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📝 説明',
                        style: TextStyle(
                          color: Colors.brown[700],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        itemInfo['description'],
                        style: const TextStyle(
                          color: Colors.brown,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '🔧 使用方法',
                        style: TextStyle(
                          color: Colors.brown[700],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        itemInfo['usage'],
                        style: const TextStyle(
                          color: Colors.brown,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.brown[600],
                      side: BorderSide(color: Colors.brown[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('閉じる'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('🎮 Using item: $itemId');
                      Navigator.of(context).pop();
                      // TODO: アイテム使用ロジックを実装
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: itemInfo['color'],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '使用する',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  /// アイテム情報を取得
  static Map<String, dynamic> _getItemInfo(String itemId) {
    switch (itemId) {
      case 'key':
        return {
          'name': '古い鍵',
          'category': '重要アイテム',
          'icon': Icons.key,
          'color': Colors.amber[700]!,
          'bgColor': Colors.amber[100]!,
          'description': '錆びた古い鍵。どこかの扉や金庫を開けることができそうだ。',
          'usage': 'ドアや金庫の前でタップして使用。正しい場所で使えば新しいエリアに進める。'
        };
      case 'lightbulb':
        return {
          'name': '電球',
          'category': '照明器具',
          'icon': Icons.lightbulb,
          'color': Colors.orange[600]!,
          'bgColor': Colors.orange[100]!,
          'description': 'まだ使える電球。暗い場所を照らすのに役立つ。',
          'usage': '暗いエリアでタップして照明を点ける。隠された手がかりが見つかるかも。'
        };
      case 'book':
        return {
          'name': '古書',
          'category': '知識アイテム',
          'icon': Icons.book,
          'color': Colors.brown[600]!,
          'bgColor': Colors.brown[100]!,
          'description': '古い本。重要な情報やパズルの解き方が書かれている可能性がある。',
          'usage': 'パズルで困った時にタップして読む。ヒントや答えが見つかるかも。'
        };
      case 'coin':
        return {
          'name': '金貨',
          'category': '貴重品',
          'icon': Icons.monetization_on,
          'color': Colors.yellow[700]!,
          'bgColor': Colors.yellow[100]!,
          'description': '光る金貨。古代の通貨かもしれない。何かの対価として使えそう。',
          'usage': '特別な装置や商人のような存在と取引する時に使用。'
        };
      case 'gem':
        return {
          'name': '魔法の宝石',
          'category': '神秘アイテム',
          'icon': Icons.diamond,
          'color': Colors.blue[600]!,
          'bgColor': Colors.blue[100]!,
          'description': '美しく光る宝石。魔法の力を秘めているようだ。',
          'usage': '特殊な仕掛けや魔法陣で使用。最終的な脱出に必要な可能性が高い。'
        };
      default:
        return {
          'name': '不明なアイテム',
          'category': '謎のアイテム',
          'icon': Icons.help_outline,
          'color': Colors.grey[600]!,
          'bgColor': Colors.grey[100]!,
          'description': '正体不明のアイテム。用途が分からない。',
          'usage': '様々な場所で試してみよう。'
        };
    }
  }
}