import 'package:flutter/material.dart';
import '../models/item_image_info.dart';

class ItemPreviewDialog extends StatelessWidget {
  final ItemImageInfo item;

  const ItemPreviewDialog({
    super.key,
    required this.item,
  });

  static void show(BuildContext context, ItemImageInfo item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ItemPreviewDialog(item: item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            item.displayName,
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
                  maxScale: 5.0, // アイテムはより拡大可能
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        item.fullPath,
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
                        'アイテム情報',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: '表示名', value: item.displayName),
                      _InfoRow(label: 'ファイル名', value: item.fileName),
                      const _InfoRow(label: 'カテゴリ', value: 'アイテム'),
                      _InfoRow(label: '作成日時', value: _formatDateTime(item.createdAt)),
                      _InfoRow(label: 'ファイルパス', value: item.fullPath),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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