import 'package:flutter/material.dart';

/// モーダル種別定義
/// 移植ガイド準拠実装
enum ModalType {
  item,         // アイテム詳細表示
  puzzle,       // パズル解答
  inspection    // オブジェクト詳細調査
}

/// モーダル設定（画像表示優先・文字表示なし）
class ModalConfig {
  final ModalType type;
  final String title;
  final String content;
  final String imagePath;              // 画像パス（95%表示）
  final Map<String, dynamic> data;     // パズル答え・ID等
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;           // 画像タップ処理
  
  const ModalConfig({
    required this.type,
    required this.title,
    required this.content,
    this.imagePath = '',
    this.data = const {},
    this.onConfirm,
    this.onCancel,
    this.onTap,
  });
  
  /// パズル用設定のファクトリーメソッド
  factory ModalConfig.puzzle({
    required String title,
    required String content,
    required String correctAnswer,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ModalConfig(
      type: ModalType.puzzle,
      title: title,
      content: content,
      data: {'correctAnswer': correctAnswer},
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
  
  /// アイテム用設定のファクトリーメソッド（画像表示対応）
  factory ModalConfig.item({
    required String title,
    required String content,
    String imagePath = '',
    VoidCallback? onTap,
    String? itemId,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ModalConfig(
      type: ModalType.item,
      title: title,
      content: content,
      imagePath: imagePath,
      data: {'itemId': itemId},
      onConfirm: onConfirm,
      onCancel: onCancel,
      onTap: onTap,
    );
  }
  
  /// 調査用設定のファクトリーメソッド
  factory ModalConfig.inspection({
    required String title,
    required String content,
    String? objectId,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ModalConfig(
      type: ModalType.inspection,
      title: title,
      content: content,
      data: {'objectId': objectId},
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }
}