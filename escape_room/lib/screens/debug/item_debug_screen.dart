import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/item_image_info.dart';
import 'widgets/item_card.dart';
import 'widgets/item_preview_dialog.dart';

/// アイテム画像デバッグ画面 - assets/items/ 内の全てのアイテム画像を表示・確認できる
class ItemDebugScreen extends StatefulWidget {
  const ItemDebugScreen({super.key});

  @override
  State<ItemDebugScreen> createState() => _ItemDebugScreenState();
}

class _ItemDebugScreenState extends State<ItemDebugScreen> {
  List<ItemImageInfo> _itemImages = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItemImages();
  }

  Future<void> _loadItemImages() async {
    setState(() => _isLoading = true);
    
    try {
      final List<ItemImageInfo> items = [];
      
      // 静的なアイテムリスト（実際のアセットファイル名に基づく）
      final List<String> itemFileNames = [
        'book.png',
        'key.png',
        'dark_crystal.png',
        'underground_key.png',
        'underground_master_key.png',
        'pure_water.png',
        'ritual_stone.png',
        'ancient_rune.png',
        'gem.png',
        'coin.png',
        'lightbulb.png',
        'red_crystal.png',
        'puzzle_box.png',
        'iron_crowbar.png',
        'rune_tablet.png',
        'golden_chalice.png',
        'spell_tome.png',
        'silver_key.png',
        'magic_lantern.png',
        'mystical_scroll.png',
        'brass_compass.png',
        'wooden_stairs.png',
      ];
      
      for (final fileName in itemFileNames) {
        final assetPath = 'assets/images/items/$fileName';
        
        // アセットが存在するかチェック
        try {
          await rootBundle.load(assetPath);
          final displayName = _getDisplayName(fileName);
          
          items.add(ItemImageInfo(
            fileName: fileName,
            displayName: displayName,
            fullPath: assetPath,
            category: 'item',
            createdAt: DateTime.now(), // アセットなので現在時刻を使用
          ));
        } catch (e) {
          // アセットが見つからない場合はスキップ
          debugPrint('アセット見つからず: $assetPath');
        }
      }
      
      // ファイル名でソート
      items.sort((a, b) => a.fileName.compareTo(b.fileName));
      
      setState(() {
        _itemImages = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('アイテム画像の読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getDisplayName(String fileName) {
    // ファイル名から拡張子を除去し、アンダースコアをスペースに変換
    final nameWithoutExt = fileName.split('.').first;
    return nameWithoutExt.replaceAll('_', ' ').toUpperCase();
  }

  List<ItemImageInfo> get _filteredImages {
    if (_searchQuery.isEmpty) {
      return _itemImages;
    }
    return _itemImages.where((item) {
      return item.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredImages = _filteredImages;

    return Scaffold(
      appBar: AppBar(
        title: Text('アイテム画像一覧 (${filteredImages.length}個)'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadItemImages,
            tooltip: '再読み込み',
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'アイテム名で検索...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // アイテム一覧
          Expanded(
            child: filteredImages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('アイテム画像がありません', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // アイテムは小さいので3列表示
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filteredImages.length,
                    itemBuilder: (context, index) {
                      final item = filteredImages[index];
                      return ItemCard(
                        item: item,
                        onTap: () => ItemPreviewDialog.show(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}