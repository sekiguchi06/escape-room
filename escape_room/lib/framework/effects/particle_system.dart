import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// パーティクルエフェクトの設定
class ParticleConfiguration {
  final int particleCount;
  final double lifespan;
  final Vector2 position;
  final Vector2 velocity;
  final Vector2 acceleration;
  final double minRadius;
  final double maxRadius;
  final Color startColor;
  final Color endColor;
  final bool fadeOut;

  ParticleConfiguration({
    this.particleCount = 20,
    this.lifespan = 1.0,
    Vector2? position,
    Vector2? velocity,
    Vector2? acceleration,
    this.minRadius = 1.0,
    this.maxRadius = 3.0,
    this.startColor = Colors.white,
    this.endColor = Colors.transparent,
    this.fadeOut = true,
  }) : position = position ?? Vector2.zero(),
       velocity = velocity ?? Vector2.zero(),
       acceleration = acceleration ?? Vector2.zero();
}

/// パーティクルエフェクトマネージャー
class ParticleEffectManager extends Component {
  final Map<String, ParticleConfiguration> _effectConfigs = {};
  final Map<String, ParticleSystemComponent> _activeEffects = {};
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    _registerDefaultEffects();
  }

  /// デフォルトエフェクトの登録
  void _registerDefaultEffects() {
    // 爆発エフェクト
    registerEffect(
      'explosion',
      ParticleConfiguration(
        particleCount: 30,
        lifespan: 1.5,
        minRadius: 2.0,
        maxRadius: 5.0,
        startColor: Colors.orange,
        endColor: Colors.red,
      ),
    );

    // キラキラエフェクト
    registerEffect(
      'sparkle',
      ParticleConfiguration(
        particleCount: 15,
        lifespan: 2.0,
        minRadius: 1.0,
        maxRadius: 2.0,
        startColor: Colors.yellow,
        endColor: Colors.white,
      ),
    );

    // 軌跡エフェクト
    registerEffect(
      'trail',
      ParticleConfiguration(
        particleCount: 10,
        lifespan: 0.8,
        minRadius: 1.5,
        maxRadius: 3.0,
        startColor: Colors.blue,
        endColor: Colors.cyan,
      ),
    );

    // アイテム発見エフェクト（黄金のキラキラ）
    registerEffect(
      'itemDiscovery',
      ParticleConfiguration(
        particleCount: 25,
        lifespan: 2.5,
        minRadius: 2.0,
        maxRadius: 4.0,
        startColor: Color(0xFFFFD700), // ゴールド
        endColor: Color(0xFFFFA500), // オレンジ
      ),
    );

    // アイテム発見強化エフェクト（より多くの粒子）
    registerEffect(
      'itemDiscoveryEnhanced',
      ParticleConfiguration(
        particleCount: 40,
        lifespan: 3.0,
        minRadius: 1.5,
        maxRadius: 5.0,
        startColor: Color(0xFFFFD700), // ゴールド
        endColor: Color(0xFFFFFFFF), // ホワイト
      ),
    );
  }

  /// エフェクト設定の登録
  void registerEffect(String name, ParticleConfiguration config) {
    _effectConfigs[name] = config;
  }

  /// エフェクト再生
  void playEffect(String name, Vector2 position) {
    final config = _effectConfigs[name];
    if (config == null) {
      return;
    }

    // コンポーネントとその親のマウント状態を厳密に確認
    if (!isMounted || parent == null || !parent!.isMounted) {
      return;
    }

    try {
      final particle = _createParticle(name, config, position);
      final system = ParticleSystemComponent(particle: particle);

      // 非同期でエフェクトを追加
      Future.microtask(() {
        if (isMounted && parent != null && parent!.isMounted) {
          add(system);
          _activeEffects[name] = system;

          // 自動削除
          Future.delayed(
            Duration(milliseconds: (config.lifespan * 1000).round()),
            () {
              if (system.isMounted) {
                system.removeFromParent();
              }
              _activeEffects.remove(name);
            },
          );
        } else {}
      });
    } catch (e) {
      // エフェクト生成エラーをログ出力
      debugPrint('パーティクルエフェクト生成エラー: $e');
    }
  }

  /// パーティクル生成
  Particle _createParticle(
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
  Particle _createExplosionParticle(
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
  Particle _createSparkleParticle(
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
  Particle _createTrailParticle(
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
  Particle _createDefaultParticle(
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
  Particle _createItemDiscoveryParticle(
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
  Particle _createItemDiscoveryEnhancedParticle(
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
  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
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

  /// アクティブエフェクト数
  int get activeEffectCount => _activeEffects.length;

  /// 全エフェクト停止
  void stopAllEffects() {
    for (final effect in _activeEffects.values) {
      if (effect.isMounted) {
        effect.removeFromParent();
      }
    }
    _activeEffects.clear();
  }

  @override
  void onRemove() {
    stopAllEffects();
    super.onRemove();
  }
}
