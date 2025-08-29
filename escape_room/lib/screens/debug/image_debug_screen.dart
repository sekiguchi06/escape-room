import 'dart:io';
import 'package:flutter/material.dart';
import '../../framework/image/generated_image_manager.dart';
import 'item_debug_screen.dart';

/// 画像デバッグ画面 - 背景画像とアイテム画像を表示・確認できる
class ImageDebugScreen extends StatefulWidget {
  const ImageDebugScreen({super.key});

  @override
  State<ImageDebugScreen> createState() => _ImageDebugScreenState();
}

class _ImageDebugScreenState extends State<ImageDebugScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String? _categoryFilter;
  List<GeneratedImageInfo> _images = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadImages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    
    try {
      final images = await GeneratedImageManager.instance.getGeneratedImages();
      final stats = await GeneratedImageManager.instance.getStatistics();
      
      setState(() {
        _images = images;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像の読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像デバッグ'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadImages,
            tooltip: '再読み込み',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.landscape),
              text: '背景画像',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'アイテム画像',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBackgroundImagesTab(),
          const ItemDebugScreen(), // アイテム画像は専用クラスに委託
        ],
      ),
    );
  }

  Widget _buildBackgroundImagesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 背景画像のみを表示
    final backgroundImages = _images.where((image) => image.category == 'background').toList();

    return backgroundImages.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('背景画像がありません', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          )
        : Column(
            children: [
              // 画像数表示
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Text(
                  '背景画像: ${backgroundImages.length}枚',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              // 背景画像一覧
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: backgroundImages.length,
                  itemBuilder: (context, index) {
                    final image = backgroundImages[index];
                    return _buildImageCard(context, image);
                  },
                ),
              ),
            ],
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

  Widget _buildImageCard(BuildContext context, GeneratedImageInfo image) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showImagePreview(context, image),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3, // 画像部分の比重を大きく
              child: Container(
                color: Colors.grey.shade100,
                child: Image.file(
                  File(image.fullPath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 32, color: Colors.grey.shade400),
                          const SizedBox(height: 4),
                          Text(
                            '読み込み失敗',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2, // 情報部分
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        image.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(image.category),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getCategoryLabel(image.category),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDateTime(image.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'background':
        return Colors.blue;
      case 'item':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'background':
        return '背景';
      case 'item':
        return 'アイテム';
      default:
        return 'その他';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showImagePreview(BuildContext context, GeneratedImageInfo image) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                image.displayName,
                style: const TextStyle(fontSize: 18),
              ),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            backgroundColor: Colors.black87,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // 画像表示部分
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Center(
                        child: Image.file(
                          File(image.fullPath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 50, color: Colors.white54),
                                    SizedBox(height: 8),
                                    Text(
                                      '画像の読み込みに失敗しました',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // 情報表示部分
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '画像情報',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('表示名', image.displayName),
                          _buildInfoRow('ファイル名', image.fileName),
                          _buildInfoRow('カテゴリ', _getCategoryLabel(image.category)),
                          _buildInfoRow('作成日時', _formatDateTime(image.createdAt)),
                          _buildInfoRow('ファイルパス', image.fullPath),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}