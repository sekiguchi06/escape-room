import 'package:flutter/material.dart';
import '../components/flutter_particle_system.dart';

/// ゲームクリア画面用カスタムUI
/// 脱出成功時の祝福画面
class CustomGameClearUI extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onRestartPressed;
  final Duration? clearTime;
  final bool enableSkip;

  const CustomGameClearUI({
    super.key,
    this.onMenuPressed,
    this.onRestartPressed,
    this.clearTime,
    this.enableSkip = true,
  });

  @override
  State<CustomGameClearUI> createState() => _CustomGameClearUIState();
}

class _CustomGameClearUIState extends State<CustomGameClearUI>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // フェードインアニメーション
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // スケールアニメーション
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // 回転アニメーション（装飾用）
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // アニメーション開始
    _fadeController.forward();
    _scaleController.forward();

    // パーティクルエフェクトを開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerCelebrationParticles();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _triggerCelebrationParticles() {
    // グローバルパーティクルシステムで祝福エフェクトを発動
    final particleSystem = FlutterParticleSystem.globalKey.currentState;
    if (particleSystem != null) {
      // 成功パーティクルを複数回発動（画面中央付近）
      for (int i = 0; i < 5; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          // 画面中央付近でパーティクルエフェクトを発動
          final screenCenter = Offset(200 + (i * 20).toDouble(), 300 + (i * 10).toDouble());
          particleSystem.addParticleEffect(screenCenter);
        });
      }
    }
  }

  String get _clearTimeText {
    if (widget.clearTime == null) return '';
    final minutes = widget.clearTime!.inMinutes;
    final seconds = widget.clearTime!.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade900.withValues(alpha: 0.95),
            Colors.indigo.shade900.withValues(alpha: 0.95),
            Colors.blue.shade800.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // 背景装飾（回転する円）
            ...List.generate(3, (index) => 
              Positioned(
                top: 100 + (index * 150).toDouble(),
                right: -50 + (index * 30).toDouble(),
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 100 + (index * 50).toDouble(),
                        height: 100 + (index * 50).toDouble(),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05 + (index * 0.02)),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // スキップボタン（右上）
            if (widget.enableSkip)
              Positioned(
                top: 20,
                right: 20,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: TextButton(
                        onPressed: widget.onMenuPressed,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'スキップ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.skip_next, color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // メインコンテンツ
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600.withValues(alpha: 0.9),
                              Colors.green.shade800.withValues(alpha: 0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            // 成功アイコン
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow.shade300,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                size: 40,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // クリア賞賛メッセージ
                            const Text(
                              '🎉 脱出成功！ 🎉',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            const Text(
                              'おめでとうございます！\nすべての謎を解いて部屋から脱出しました',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            // クリア時間表示
                            if (widget.clearTime != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'クリア時間: $_clearTimeText',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // ボタン群
                            Column(
                              children: [
                                // もう一度プレイボタン
                                if (widget.onRestartPressed != null)
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton.icon(
                                      onPressed: widget.onRestartPressed,
                                      icon: const Icon(Icons.refresh, color: Colors.white),
                                      label: const Text(
                                        'もう一度プレイ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                // スタート画面に戻るボタン
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: widget.onMenuPressed,
                                    icon: const Icon(Icons.home, color: Colors.white),
                                    label: const Text(
                                      'スタート画面に戻る',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade600,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}