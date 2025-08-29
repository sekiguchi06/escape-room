import 'package:flutter/material.dart';

import 'particle_configuration.dart';

/// パーティクルエフェクト設定レジストリー
class ParticleEffectsRegistry {
  static final Map<String, ParticleConfiguration> _effectConfigs = {};

  /// デフォルトエフェクトの初期化
  static void initialize() {
    if (_effectConfigs.isNotEmpty) return; // 既に初期化済み

    // 爆発エフェクト
    register(
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
    register(
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
    register(
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
    register(
      'itemDiscovery',
      ParticleConfiguration(
        particleCount: 25,
        lifespan: 2.5,
        minRadius: 2.0,
        maxRadius: 4.0,
        startColor: const Color(0xFFFFD700), // ゴールド
        endColor: const Color(0xFFFFA500), // オレンジ
      ),
    );

    // アイテム発見強化エフェクト（より多くの粒子）
    register(
      'itemDiscoveryEnhanced',
      ParticleConfiguration(
        particleCount: 40,
        lifespan: 3.0,
        minRadius: 1.5,
        maxRadius: 5.0,
        startColor: const Color(0xFFFFD700), // ゴールド
        endColor: const Color(0xFFFFFFFF), // ホワイト
      ),
    );
  }

  /// エフェクト設定の登録
  static void register(String name, ParticleConfiguration config) {
    _effectConfigs[name] = config;
  }

  /// エフェクト設定の取得
  static ParticleConfiguration? getConfig(String name) {
    return _effectConfigs[name];
  }

  /// 登録済みエフェクト名の一覧
  static List<String> get registeredEffects => _effectConfigs.keys.toList();

  /// エフェクト設定のクリア（テスト用）
  static void clear() {
    _effectConfigs.clear();
  }
}