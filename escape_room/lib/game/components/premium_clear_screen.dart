import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'clear_screen_animation_manager.dart';
import 'clear_screen_particle_system.dart';
import 'clear_screen_rating_dialog.dart';
import 'clear_screen_utils.dart';
import '../../framework/game_timer.dart';
import '../components/inventory_system.dart';

/// プレミアムゲームクリア画面
/// Issue #5: 明るいフェードアニメーション、パーティクル、アプリ評価促進対応
class PremiumClearScreen extends StatefulWidget {
  final VoidCallback? onHomePressed;
  final Duration? clearTime;

  const PremiumClearScreen({super.key, this.onHomePressed, this.clearTime});

  @override
  State<PremiumClearScreen> createState() => _PremiumClearScreenState();
}

class _PremiumClearScreenState extends State<PremiumClearScreen>
    with TickerProviderStateMixin {
  late ClearScreenAnimationManager _animationManager;
  List<ParticleData> _particles = [];

  @override
  void initState() {
    super.initState();
    _animationManager = ClearScreenAnimationManager();
    _animationManager.initialize(this);
    _startCelebrationSequence();
  }

  void _startCelebrationSequence() async {
    // アニメーション開始
    await _animationManager.startCelebrationSequence();

    // パーティクル生成
    _generateParticles();

    // 7.5秒後にネイティブ評価機能呼び出し
    await Future.delayed(const Duration(milliseconds: 6500));
    if (mounted) {
      ClearScreenRatingDialog.showAppRatingDialog(context);
    }
  }

  void _generateParticles() {
    final screenSize = MediaQuery.of(context).size;
    _particles = ParticleGenerator.generateParticles(screenSize);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 背景グラデーション
          _buildBackgroundGradient(),

          // パーティクルレイヤー
          _buildParticleLayer(),

          // 明るいフェード光効果
          _buildBrightFadeOverlay(),

          // メインコンテンツ
          _buildMainContent(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [
            Colors.deepPurple.shade800,
            Colors.indigo.shade900,
            Colors.black,
          ],
        ),
      ),
    );
  }

  Widget _buildParticleLayer() {
    return AnimatedBuilder(
      animation: _animationManager.particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: _particles,
            animationValue: _animationManager.particleAnimation.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildBrightFadeOverlay() {
    return AnimatedBuilder(
      animation: _animationManager.brightFadeAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white.withValues(
            alpha: _animationManager.brightFadeAnimation.value * 0.9,
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _animationManager.fadeAnimation,
          _animationManager.scaleAnimation,
        ]),
        builder: (context, child) {
          return Opacity(
            opacity: _animationManager.fadeAnimation.value,
            child: Transform.scale(
              scale: _animationManager.scaleAnimation.value,
              child: Column(
                children: [
                  Expanded(child: Center(child: _buildCelebrationCard())),
                  _buildActionButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCelebrationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: AnimatedBuilder(
        animation: _animationManager.textRevealAnimation,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 成功アイコン
              _buildSuccessIcon(),
              const SizedBox(height: 24),

              // メイン祝福メッセージ
              _buildMainMessage(),
              const SizedBox(height: 16),

              // クリア時間表示
              if (widget.clearTime != null) _buildClearTimeCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Colors.amber.shade300, Colors.amber.shade600],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.6),
            blurRadius: 25,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: const Icon(Icons.emoji_events, size: 50, color: Colors.white),
    );
  }

  Widget _buildMainMessage() {
    return Column(
      children: [
        Text(
          '🎉 脱出成功！ 🎉',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [Colors.orange.shade600, Colors.red.shade600],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'おめでとうございます！',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildClearTimeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 12),
          Text(
            'クリア時間',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Text(
            ClearScreenUtils.formatClearTime(widget.clearTime),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _resetGameDataAndGoHome();
        },
        icon: const Icon(Icons.home),
        label: const Text('スタート画面に戻る'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }

  /// セーブデータリセットしてホームに戻る
  void _resetGameDataAndGoHome() {
    try {
      // インベントリシステムリセット
      InventorySystem().resetToInitialState();

      // ゲームタイマーリセット
      GameTimer().reset();

      debugPrint('🔄 ゲームデータリセット完了');

      // ホーム画面に戻る
      widget.onHomePressed?.call();
    } catch (e) {
      debugPrint('⚠️ ゲームデータリセットエラー: $e');
      // エラーが発生してもホーム画面に戻る
      widget.onHomePressed?.call();
    }
  }
}
