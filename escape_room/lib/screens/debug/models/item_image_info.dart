/// アイテム画像情報クラス
class ItemImageInfo {
  final String fileName;
  final String displayName;
  final String fullPath;
  final String category;
  final DateTime createdAt;

  const ItemImageInfo({
    required this.fileName,
    required this.displayName,
    required this.fullPath,
    required this.category,
    required this.createdAt,
  });
}