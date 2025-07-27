import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class TapGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late TextComponent scoreText;
  late TextComponent timeText;
  int score = 0;
  double remainingTime = 60.0;
  bool isGameOver = false;
  final math.Random random = math.Random();
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // スコア表示
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);
    
    // タイマー表示
    timeText = TextComponent(
      text: 'Time: 60',
      position: Vector2(size.x - 120, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(timeText);
    
    // 最初のターゲット生成
    _spawnTarget();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isGameOver) {
      remainingTime -= dt;
      timeText.text = 'Time: ${remainingTime.toStringAsFixed(0)}';
      
      if (remainingTime <= 0) {
        _gameOver();
      }
    }
  }
  
  void _spawnTarget() {
    if (isGameOver) return;
    
    final target = TapTarget(
      position: Vector2(
        random.nextDouble() * (size.x - 80) + 40,
        random.nextDouble() * (size.y - 200) + 100,
      ),
      onTap: () {
        score += 10;
        scoreText.text = 'Score: $score';
        _spawnTarget();
      },
    );
    add(target);
  }
  
  void _gameOver() {
    isGameOver = true;
    add(
      TextComponent(
        text: 'Game Over!\nFinal Score: $score\nTap to restart',
        position: size / 2,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    if (isGameOver) {
      // ゲームリスタート
      score = 0;
      remainingTime = 60.0;
      isGameOver = false;
      removeAll(children);
      onLoad();
    }
  }
}

class TapTarget extends CircleComponent with TapCallbacks {
  final VoidCallback onTap;
  double lifeTime = 0;
  
  TapTarget({
    required Vector2 position,
    required this.onTap,
  }) : super(
    position: position,
    radius: 40,
    paint: Paint()..color = Colors.blue,
    anchor: Anchor.center,
  );
  
  @override
  void update(double dt) {
    super.update(dt);
    lifeTime += dt;
    
    // 1.5秒で消える（挫折感）
    if (lifeTime > 1.5) {
      removeFromParent();
      (parent as TapGame)._spawnTarget();
    }
    
    // サイズアニメーション
    scale = Vector2.all(1.0 + math.sin(lifeTime * 3) * 0.1);
  }
  
  @override
  bool onTapUp(TapUpEvent event) {
    onTap();
    removeFromParent();
    return true;
  }
}