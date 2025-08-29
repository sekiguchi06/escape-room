import 'dart:io';
import 'package:flutter/foundation.dart';

/// 生成された画像の情報を保持するクラス
class GeneratedImageInfo {
  final String fileName;
  final String fullPath;
  final String category; // 'background' or 'item'
  final String? description;
  final DateTime createdAt;

  GeneratedImageInfo({
    required this.fileName,
    required this.fullPath,
    required this.category,
    this.description,
    required this.createdAt,
  });

  String get displayName {
    // ファイル名から読みやすい名前を生成
    String name = fileName
        .replaceAll(RegExp(r'_\d{5}_\.png$'), '') // _00001_.png を除去
        .replaceAll('bg_', '') // bg_ プレフィックスを除去
        .replaceAll('item_', '') // item_ プレフィックスを除去
        .replaceAll('_', ' '); // アンダースコアをスペースに

    // カテゴリ別の表示名調整
    if (category == 'background') {
      if (name.startsWith('1f ')) {
        name = '1階 ${name.substring(3)}';
      } else if (name.startsWith('b1 ')) {
        name = '地下 ${name.substring(3)}';
      }
    }

    return name;
  }
}

/// 生成された画像を管理するクラス
class GeneratedImageManager {
  static const String _comfyUIOutputPath = '/Users/sekiguchi/ai-services/ComfyUI/output';
  
  static GeneratedImageManager? _instance;
  static GeneratedImageManager get instance => _instance ??= GeneratedImageManager._();
  
  GeneratedImageManager._();

  /// 生成された画像のリストを取得
  Future<List<GeneratedImageInfo>> getGeneratedImages() async {
    final List<GeneratedImageInfo> images = [];
    
    try {
      final directory = Directory(_comfyUIOutputPath);
      if (!await directory.exists()) {
        if (kDebugMode) {
          print('Output directory does not exist: $_comfyUIOutputPath');
        }
        return images;
      }

      final files = await directory.list().toList();
      
      for (final file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.png')) {
          final fileName = file.path.split('/').last;
          final stat = await file.stat();
          
          // 背景画像のみを取得
          String category = 'other';
          if (fileName.startsWith('bg_')) {
            category = 'background';
            
            images.add(GeneratedImageInfo(
              fileName: fileName,
              fullPath: file.path,
              category: category,
              createdAt: stat.modified,
            ));
          }
        }
      }
      
      // 作成日時の新しい順にソート
      images.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
    } catch (e) {
      if (kDebugMode) {
        print('Error loading generated images: $e');
      }
    }
    
    return images;
  }

  /// カテゴリ別に画像を取得
  Future<List<GeneratedImageInfo>> getImagesByCategory(String category) async {
    final allImages = await getGeneratedImages();
    return allImages.where((image) => image.category == category).toList();
  }

  /// 背景画像のリストを取得
  Future<List<GeneratedImageInfo>> getBackgroundImages() async {
    return getImagesByCategory('background');
  }

  /// アイテム画像のリストを取得
  Future<List<GeneratedImageInfo>> getItemImages() async {
    return getImagesByCategory('item');
  }

  /// 統計情報を取得
  Future<Map<String, dynamic>> getStatistics() async {
    final images = await getGeneratedImages();
    
    final backgroundCount = images.where((img) => img.category == 'background').length;
    final itemCount = images.where((img) => img.category == 'item').length;
    final otherCount = images.where((img) => img.category == 'other').length;
    
    return {
      'total': images.length,
      'background': backgroundCount,
      'item': itemCount,
      'other': otherCount,
      'last_generated': images.isNotEmpty ? images.first.createdAt : null,
    };
  }
}