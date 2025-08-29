import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'particle_configuration.dart';

/// パーティクル生成ファクトリー
class ParticleFactory {
  static final Random _random = Random();

  /// パーティクル生成
  static Particle createParticle(
    String name,
    ParticleConfiguration config,
    Vector2 position,
  ) {
    switch (name) {
      case 'explosion':
        return _createExplosionParticle(config, position);
      case 'sparkle':
        return _createSparkleParticle(config, position);
      case 'trail':
        return _createTrailParticle(config, position);
      case 'itemDiscovery':
        return _createItemDiscoveryParticle(config, position);
      case 'itemDiscoveryEnhanced':
        return _createItemDiscoveryEnhancedParticle(config, position);
      default:
        return _createDefaultParticle(config, position);
    }
  }

  /// 爆発パーティクル
  static Particle _createExplosionParticle(
    ParticleConfiguration config,
    Vector2 position,
  ) {
    return Particle.generate(
      count: config.particleCount,
      lifespan: config.lifespan,
      generator: (i) {
        final angle = (i / config.particleCount) * 2 * pi;
        final speed = 50.0 + _random.nextDouble() * 100.0;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;

        return AcceleratedParticle(
          acceleration: Vector2(0, 100), // 重力
          child: MovingParticle(
            from: position,
            to: position + velocity,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final radius = (config.maxRadius * (1 - progress)).clamp(
                  config.minRadius,
                  config.maxRadius,
                );
                final color = Color.lerp(
                  config.startColor,
                  config.endColor,
                  progress,
                )!;

                canvas.drawCircle(Offset.zero, radius, Paint()..color = color);
              },
            ),
          ),
        );
      },
    );
  }

  /// キラキラパーティクル
  static Particle _createSparkleParticle(
    ParticleConfiguration config,
    Vector2 position,
  ) {
    return Particle.generate(
      count: config.particleCount,
      lifespan: config.lifespan,
      generator: (i) {
        final randomOffset = Vector2(
          (_random.nextDouble() - 0.5) * 100,
          (_random.nextDouble() - 0.5) * 100,
        );

        return MovingParticle(
          from: position,
          to: position + randomOffset,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final progress = particle.progress;
              final opacity = (sin(progress * pi) * 255).toInt();
              final radius =
                  config.minRadius +
                  (config.maxRadius - config.minRadius) * sin(progress * pi);

              canvas.drawCircle(
                Offset.zero,
                radius,
                Paint()
                  ..color = config.startColor.withValues(
                    alpha: opacity / 255.0,
                  ),
              );
            },
          ),
        );
      },
    );
  }

  /// 軌跡パーティクル
  static Particle _createTrailParticle(
    ParticleConfiguration config,
    Vector2 position,
  ) {
    return Particle.generate(
      count: config.particleCount,
      lifespan: config.lifespan,
      generator: (i) {
        final delay = i * 0.1;

        return MovingParticle(
          from: position,
          to: position + Vector2(0, -50),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              if (particle.progress < delay) return;

              final adjustedProgress =
                  ((particle.progress - delay) / (1 - delay)).clamp(0.0, 1.0);
              final radius = config.maxRadius * (1 - adjustedProgress);
              final color = Color.lerp(
                config.startColor,
                config.endColor,
                adjustedProgress,
              )!;

              canvas.drawCircle(Offset.zero, radius, Paint()..color = color);
            },
          ),
        );
      },
    );
  }

  /// デフォルトパーティクル
  static Particle _createDefaultParticle(
    ParticleConfiguration config,
    Vector2 position,
  ) {
    return Particle.generate(
      count: config.particleCount,
      lifespan: config.lifespan,
      generator: (i) => CircleParticle(
        radius:
            config.minRadius +
            _random.nextDouble() * (config.maxRadius - config.minRadius),
        paint: Paint()..color = config.startColor,
      ),
    );
  }

  /// アイテム発見パーティクル（黄金のキラキラ）
  static Particle _createItemDiscoveryParticle(
    ParticleConfiguration config,
    Vector2 position,
  ) {
    return Particle.generate(
      count: config.particleCount,
      lifespan: config.lifespan,
      generator: (i) {
        final angle = _random.nextDouble() * 2 * pi;
        final distance = 20.0 + _random.nextDouble() * 80.0;
        final targetPosition =
            position + Vector2(cos(angle), sin(angle)) * distance;

        return MovingParticle(
          from: position,
          to: targetPosition,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final progress = particle.progress;
              // 輝く星形エフェクト
              final brightness = sin(progress * pi);
              final radius = config.maxRadius * brightness;
              final color = Color.lerp(
                config.startColor,
                config.endColor,
                progress,
              )!;

              // 星型の描画
              _drawStar(canvas, Offset.zero, radius, color);
            },
          ),
        );
      },
    );
  }

  /// アイテム発見強化パーティクル（より多くの粒子）
  static Particle _createItemDiscoveryEnhancedParticle(
    ParticleConfiguration config,
    Vector2 position,
  ) {
    return Particle.generate(
      count: config.particleCount,
      lifespan: config.lifespan,
      generator: (i) {
        final angle =
            (i / config.particleCount) * 2 * pi + _random.nextDouble() * 0.5;
        final speed = 30.0 + _random.nextDouble() * 70.0;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;

        return AcceleratedParticle(
          acceleration: Vector2(0, -20), // 軽い上昇効果
          child: MovingParticle(
            from: position,
            to: position + velocity,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final progress = particle.progress;
                final pulsation = sin(progress * pi * 3) * 0.3 + 0.7;
                final radius = config.maxRadius * pulsation;
                final opacity = (sin(progress * pi) * 255).toInt();
                final color = Color.lerp(
                  config.startColor,
                  config.endColor,
                  progress,
                )!.withValues(alpha: opacity / 255.0);

                // 輝く円の描画
                canvas.drawCircle(
                  Offset.zero,
                  radius,
                  Paint()
                    ..color = color
                    ..style = PaintingStyle.fill
                    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 星型の描画ヘルパーメソッド
  static void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    const int points = 5;
    final double outerRadius = radius;
    final double innerRadius = radius * 0.4;

    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final double angle = (i * pi) / points;
      final double currentRadius = i.isEven ? outerRadius : innerRadius;
      final double x = center.dx + cos(angle - pi / 2) * currentRadius;
      final double y = center.dy + sin(angle - pi / 2) * currentRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );
  }
}