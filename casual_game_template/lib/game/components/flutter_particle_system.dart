import 'package:flutter/material.dart';
import 'dart:math';

/// Flutterネイティブパーティクルシステム
class FlutterParticleSystem extends StatefulWidget {
  const FlutterParticleSystem({super.key});

  static final GlobalKey<_FlutterParticleSystemState> _globalKey = 
      GlobalKey<_FlutterParticleSystemState>();

  /// パーティクルエフェクトを発生させる
  static void triggerParticleEffect(Offset position) {
    final state = _globalKey.currentState;
    if (state != null) {
      state.addParticleEffect(position);
    } else {
    }
  }

  @override
  State<FlutterParticleSystem> createState() => _FlutterParticleSystemState();

  /// グローバルキーを取得
  static GlobalKey<_FlutterParticleSystemState> get globalKey => _globalKey;
}

/// パーティクルの種類（固定）
enum ParticleType {
  simple, // シンプルなオレンジ円形パーティクルのみ
}

/// 個別のパーティクル
class Particle {
  Offset position;
  Offset velocity;
  double life;
  double maxLife;
  Color color;
  double size;
  ParticleType type;

  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
    required this.type,
  });

  /// パーティクルを更新
  void update(double deltaTime) {
    position += velocity * deltaTime;
    life -= deltaTime;
    
    // 軽い重力効果（全パーティクル共通）
    velocity = Offset(velocity.dx, velocity.dy + 200 * deltaTime);
  }

  /// パーティクルが生きているか
  bool get isAlive => life > 0;

  /// 現在の透明度
  double get opacity => (life / maxLife).clamp(0.0, 1.0);
}

class _FlutterParticleSystemState extends State<FlutterParticleSystem> 
    with TickerProviderStateMixin {
  
  List<Particle> _particles = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 16), // 60 FPS
      vsync: this,
    )..addListener(_updateParticles);
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// パーティクルエフェクトを追加
  void addParticleEffect(Offset position) {
    setState(() {
      _addSimpleParticles(position);
    });
  }

  /// シンプルパーティクルを追加
  void _addSimpleParticles(Offset position) {
    final random = Random();
    
    // 12個のオレンジ色の円形パーティクルを放射状に配置（豪華にするため増量）
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final speed = 40 + random.nextDouble() * 30; // 広がりを半分に（速度を約半分に）
      final velocity = Offset(
        cos(angle) * speed,
        sin(angle) * speed - 30, // 上向き初速度も半分に
      );
      
      _particles.add(Particle(
        position: position + Offset(
          (random.nextDouble() - 0.5) * 2, // 初期位置のランダム性も半分に
          (random.nextDouble() - 0.5) * 2,
        ),
        velocity: velocity,
        life: 1.2, // 少し長持ち
        maxLife: 1.2,
        color: Color.lerp(Colors.orange.shade500, Colors.red.shade400, random.nextDouble() * 0.3)!, // 少し色のバリエーション
        size: 3.2, // 元の4.0の8割
        type: ParticleType.simple,
      ));
    }
    
    // 追加で中央に小さなキラキラパーティクルを3個追加（豪華にするため）
    for (int i = 0; i < 3; i++) {
      final velocity = Offset(
        (random.nextDouble() - 0.5) * 20, // 広がりを半分に
        -15 - random.nextDouble() * 15, // 上向き速度も半分に
      );
      
      _particles.add(Particle(
        position: position,
        velocity: velocity,
        life: 0.8,
        maxLife: 0.8,
        color: Colors.yellow.shade300, // キラキラ用の黄色
        size: 2.4, // 元の3.0の8割相当
        type: ParticleType.simple,
      ));
    }
  }

  /// パーティクルを更新
  void _updateParticles() {
    setState(() {
      // パーティクルを更新
      for (final particle in _particles) {
        particle.update(0.016); // 60 FPS
      }
      
      // 死んだパーティクルを削除
      _particles.removeWhere((particle) => !particle.isAlive);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ParticlePainter(particles: _particles),
        size: Size.infinite,
      ),
    );
  }
}

/// パーティクルを描画するPainter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      // シンプルな円形で描画
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}