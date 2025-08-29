import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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