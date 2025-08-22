import 'package:flutter/material.dart';
import 'clear_screen_particle_system.dart';

/// クリア画面のUIコンポーネント群
class ClearScreenUIComponents {
  /// 背景グラデーション構築
  static Widget buildBackgroundGradient(Animation<double> fadeAnimation) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.amber[900]!.withValues(alpha: fadeAnimation.value * 0.8),
                Colors.brown[900]!.withValues(alpha: fadeAnimation.value * 0.9),
                Colors.black.withValues(alpha: fadeAnimation.value * 0.95),
              ],
            ),
          ),
        );
      },
    );
  }

  /// パーティクルレイヤー構築
  static Widget buildParticleLayer(
    List<ParticleData> particles,
    Animation<double> particleAnimation,
  ) {
    return AnimatedBuilder(
      animation: particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animationValue: particleAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// 明るいフェードオーバーレイ構築
  static Widget buildBrightFadeOverlay(Animation<double> brightFadeAnimation) {
    return AnimatedBuilder(
      animation: brightFadeAnimation,
      builder: (context, child) {
        double opacity;
        if (brightFadeAnimation.value <= 0.5) {
          opacity = brightFadeAnimation.value * 2;
        } else {
          opacity = (1.0 - brightFadeAnimation.value) * 2;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                Colors.white.withValues(alpha: opacity * 0.6),
                Colors.amber[200]!.withValues(alpha: opacity * 0.4),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  /// 成功アイコン構築
  static Widget buildSuccessIcon(Animation<double> scaleAnimation) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber[700],
              boxShadow: [
                BoxShadow(
                  color: Colors.amber[300]!.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const Icon(
              Icons.emoji_events,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  /// メインメッセージ構築
  static Widget buildMainMessage(Animation<double> textRevealAnimation) {
    return AnimatedBuilder(
      animation: textRevealAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: textRevealAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - textRevealAnimation.value) * 30),
            child: Column(
              children: [
                Text(
                  '🎉 ゲームクリア！ 🎉',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[200],
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.brown[900]!,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'おめでとうございます！\n見事に謎を解いて脱出に成功しました！',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown[100],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// クリア時間カード構築
  static Widget buildClearTimeCard(
    Animation<double> textRevealAnimation,
    String clearTimeText,
  ) {
    return AnimatedBuilder(
      animation: textRevealAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: textRevealAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - textRevealAnimation.value) * 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.brown[800]!.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber[600]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(Icons.timer, color: Colors.amber[300], size: 32),
                  const SizedBox(height: 12),
                  Text(
                    'クリア時間',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown[200],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    clearTimeText,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.amber[200],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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

  /// アクションボタン群構築
  static Widget buildActionButtons(
    Animation<double> textRevealAnimation,
    VoidCallback onHomePressed,
    VoidCallback onRatingPressed,
  ) {
    return AnimatedBuilder(
      animation: textRevealAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: textRevealAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1.0 - textRevealAnimation.value) * 10),
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: onRatingPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.brown[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'アプリを評価',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: onHomePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      foregroundColor: Colors.brown[100],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 8,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ホームに戻る',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }
}
