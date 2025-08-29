import 'package:flutter/material.dart';
import '../models/item_image_info.dart';

class ItemCard extends StatelessWidget {
  final ItemImageInfo item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4, // 画像部分の比重を大きく
              child: Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  item.fullPath,
                  fit: BoxFit.contain, // アイテムは原寸比保持
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 24, color: Colors.grey.shade400),
                          const SizedBox(height: 4),
                          Text(
                            '読み込み失敗',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 8,
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
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'アイテム',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
}