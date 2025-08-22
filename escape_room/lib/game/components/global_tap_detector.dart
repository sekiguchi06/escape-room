import 'package:flutter/material.dart';
import 'flutter_particle_system.dart';

/// グローバルタップ検出器（Listenerベース）
/// Qiita記事を参考に、より確実なタップ検出を実装
/// アプリ全体のどこをタップしてもパーティクルエフェクトを発生させる
class GlobalTapDetector extends StatefulWidget {
  final Widget child;

  const GlobalTapDetector({super.key, required this.child});

  @override
  State<GlobalTapDetector> createState() => _GlobalTapDetectorState();
}

class _GlobalTapDetectorState extends State<GlobalTapDetector> {
  void _handlePointerDown(PointerDownEvent event) {
    final tapPosition = event.position;

    // メインパーティクルエフェクト
    _triggerMainParticleEffect(tapPosition);
  }

  void _handlePointerUp(PointerUpEvent event) {
    final tapPosition = event.position;

    // 追加のパーティクルエフェクト
    _triggerSecondaryParticleEffect(tapPosition);
  }

  void _triggerMainParticleEffect(Offset position) {
    // シンプルなオレンジ円形パーティクルのみ
    FlutterParticleSystem.triggerParticleEffect(position);
  }

  void _triggerSecondaryParticleEffect(Offset position) {
    // セカンダリエフェクトは削除（シンプル化のため）
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // PointerDownEventを検出
      onPointerDown: _handlePointerDown,
      // PointerUpEventを検出
      onPointerUp: _handlePointerUp,
      // すべてのタップを検出するためにHitTestBehaviorを設定
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
