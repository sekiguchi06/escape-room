import 'package:flutter/material.dart';
import 'dart:math' as math;

/// パーティクルデータクラス
class ParticleData {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;

  ParticleData({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

/// パーティクル描画用のカスタムペインター
class ParticlePainter extends CustomPainter {
  final List<ParticleData> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      paint.color = particle.color.withValues(alpha: 1.0 - animationValue);

      final currentX = particle.x + (particle.vx * animationValue * size.width);
      final currentY =
          particle.y + (particle.vy * animationValue * size.height);
      final currentRotation =
          particle.rotation + (particle.rotationSpeed * animationValue);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      _drawStar(canvas, paint, particle.size);

      canvas.restore();
    }
  }

  /// 星型パーティクルを描画
  void _drawStar(Canvas canvas, Paint paint, double size) {
    const int points = 5;
    const double innerRadius = 0.4;

    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final radius = (i % 2 == 0) ? size : size * innerRadius;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// パーティクル生成ユーティリティ
class ParticleGenerator {
  static const List<Color> _particleColors = [
    Colors.amber,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.lime,
    Colors.yellow,
  ];

  /// ランダムなパーティクル色を取得
  static Color getRandomParticleColor() {
    return _particleColors[math.Random().nextInt(_particleColors.length)];
  }

  /// パーティクル群を生成
  static List<ParticleData> generateParticles(
    Size screenSize, {
    int count = 50,
  }) {
    final random = math.Random();
    final particles = <ParticleData>[];

    for (int i = 0; i < count; i++) {
      particles.add(
        ParticleData(
          x: random.nextDouble() * screenSize.width,
          y: screenSize.height + random.nextDouble() * 100,
          vx: (random.nextDouble() - 0.5) * 0.5,
          vy: -(random.nextDouble() * 0.8 + 0.2),
          color: getRandomParticleColor(),
          size: random.nextDouble() * 8 + 4,
          rotation: random.nextDouble() * 2 * math.pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 4,
        ),
      );
    }

    return particles;
  }
}
