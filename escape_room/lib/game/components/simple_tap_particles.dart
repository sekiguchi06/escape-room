import 'package:flutter/material.dart';

/// シンプルなタップフィードバックシステム
/// InkWell ベースの標準アプローチ
class SimpleTapParticles extends StatelessWidget {
  const SimpleTapParticles({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.white.withValues(alpha: 0.3),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(0),
        onTap: () {
          // タップ時の処理
        },
        child: const SizedBox(width: double.infinity, height: double.infinity),
      ),
    );
  }
}
