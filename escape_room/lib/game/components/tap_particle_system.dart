import 'package:flutter/material.dart';

/// タップ時のパーティクルエフェクト種類
enum TapParticleType {
  normal,     // 通常のタップ（統一デザイン）
  success,    // アイテム取得成功時（特別エフェクト）
  failure,    // 取得失敗時（特別エフェクト）
}

/// パーティクルエフェクトデータ
class TapParticleData {
  final Offset position;
  final TapParticleType type;
  final DateTime timestamp;
  
  const TapParticleData({
    required this.position,
    required this.type,
    required this.timestamp,
  });
}

/// タップパーティクルシステム
class TapParticleSystem extends ChangeNotifier {
  static final TapParticleSystem _instance = TapParticleSystem._internal();
  factory TapParticleSystem() => _instance;
  TapParticleSystem._internal();

  // アクティブなパーティクル管理
  final List<TapParticleData> _activeParticles = [];
  
  /// アクティブなパーティクル一覧
  List<TapParticleData> get activeParticles => List.from(_activeParticles);

  /// パーティクルエフェクトを発生させる
  void emitParticle(Offset position, TapParticleType type) {
    final particle = TapParticleData(
      position: position,
      type: type,
      timestamp: DateTime.now(),
    );
    
    _activeParticles.add(particle);
    notifyListeners();
    
    
    // 一定時間後にパーティクルを削除
    Future.delayed(_getParticleDuration(type), () {
      _activeParticles.remove(particle);
      notifyListeners();
    });
  }

  /// パーティクルタイプ別の持続時間
  Duration _getParticleDuration(TapParticleType type) {
    switch (type) {
      case TapParticleType.normal:
        return const Duration(milliseconds: 600);
      case TapParticleType.success:
        return const Duration(milliseconds: 1000);
      case TapParticleType.failure:
        return const Duration(milliseconds: 800);
    }
  }

  /// すべてのパーティクルをクリア
  void clearAllParticles() {
    _activeParticles.clear();
    notifyListeners();
  }
}

/// パーティクルエフェクト表示ウィジェット
class TapParticleWidget extends StatefulWidget {
  final TapParticleData particle;
  
  const TapParticleWidget({
    super.key,
    required this.particle,
  });

  @override
  State<TapParticleWidget> createState() => _TapParticleWidgetState();
}

class _TapParticleWidgetState extends State<TapParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    final duration = TapParticleSystem()._getParticleDuration(widget.particle.type);
    
    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    // デフォルトの回転アニメーション（回転なし）
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);

    // アニメーション設定（パーティクルタイプ別）
    switch (widget.particle.type) {
      case TapParticleType.normal:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
        );
        _opacityAnimation = Tween<double>(begin: 0.8, end: 0.0).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)),
        );
        break;
      
      case TapParticleType.success:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.8).animate(
          CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        );
        _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0)),
        );
        // 成功時は回転アニメーション
        _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
        break;
      
      case TapParticleType.failure:
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0)),
        );
        break;
    }

    // アニメーション開始
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Positioned(
      left: widget.particle.position.dx - 25, // パーティクルサイズの半分
      top: widget.particle.position.dy - 25,
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159, // 1回転
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildParticleContent(),
                ),
              ),
            );
          },
        ),
    );
  }

  /// パーティクルタイプ別の表示内容
  Widget _buildParticleContent() {
    switch (widget.particle.type) {
      case TapParticleType.normal:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.8), // より目立つ色に変更
            border: Border.all(color: Colors.yellow.withOpacity(0.9), width: 3), // より太い境界線
          ),
          child: const Center(
            child: Text(
              '●',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      
      case TapParticleType.success:
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withOpacity(0.8),
            border: Border.all(color: Colors.lightGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 24,
          ),
        );
      
      case TapParticleType.failure:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.7),
            border: Border.all(color: Colors.redAccent, width: 2),
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 20,
          ),
        );
    }
  }
}

/// パーティクルオーバーレイ（画面全体に表示）
class TapParticleOverlay extends StatelessWidget {
  const TapParticleOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: TapParticleSystem(),
        builder: (context, _) {
          final particles = TapParticleSystem().activeParticles;
          
          if (particles.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return Stack(
            children: particles.map((particle) {
              return TapParticleWidget(particle: particle);
            }).toList(),
          );
        },
      ),
    );
  }
}