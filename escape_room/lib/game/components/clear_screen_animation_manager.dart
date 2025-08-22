import 'package:flutter/material.dart';

/// クリア画面のアニメーション管理クラス
class ClearScreenAnimationManager {
  late AnimationController _fadeController;
  late AnimationController _brightFadeController;
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late AnimationController _textRevealController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _brightFadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _textRevealAnimation;

  /// アニメーションの初期化
  void initialize(TickerProvider tickerProvider) {
    // フェードインアニメーション（背景）
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: tickerProvider,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // 明るいフェードアニメーション（輝き演出）
    _brightFadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: tickerProvider,
    );
    _brightFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _brightFadeController, curve: Curves.easeInOut),
    );

    // スケールアニメーション（成功アイコン）
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: tickerProvider,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // パーティクルアニメーション
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: tickerProvider,
    );
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    // テキスト表示アニメーション
    _textRevealController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: tickerProvider,
    );
    _textRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textRevealController, curve: Curves.easeInOut),
    );
  }

  /// お祝いシーケンスを開始
  Future<void> startCelebrationSequence() async {
    // 順次アニメーション実行
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _brightFadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _textRevealController.forward();
  }

  /// リソースの解放
  void dispose() {
    _fadeController.dispose();
    _brightFadeController.dispose();
    _scaleController.dispose();
    _particleController.dispose();
    _textRevealController.dispose();
  }

  // Getters
  Animation<double> get fadeAnimation => _fadeAnimation;
  Animation<double> get brightFadeAnimation => _brightFadeAnimation;
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get particleAnimation => _particleAnimation;
  Animation<double> get textRevealAnimation => _textRevealAnimation;

  AnimationController get fadeController => _fadeController;
  AnimationController get brightFadeController => _brightFadeController;
  AnimationController get scaleController => _scaleController;
  AnimationController get particleController => _particleController;
  AnimationController get textRevealController => _textRevealController;
}
