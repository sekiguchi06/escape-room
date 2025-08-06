import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Flame公式Timer機能の調査用テストファイル
void main() {
  // Flame公式Timerクラスの使用方法を調査
  print('Flame Timer investigation');
  
  // 基本的なTimerComponent作成テスト
  final timer = TimerComponent(
    period: 2.0, // 2秒
    repeat: false,
    onTick: () {
      print('Timer tick!');
    },
  );
  
  print('TimerComponent created: ${timer.toString()}');
  print('Period: ${timer.period}');
  print('Repeat: ${timer.repeat}');
  print('Current: ${timer.current}');
  print('IsRunning: ${timer.isRunning}');
  
  // Timer.periodicの使用テスト  
  final periodicTimer = Timer.periodic(1.0, () {
    print('Periodic timer tick!');
  });
  
  print('Periodic Timer created: ${periodicTimer.toString()}');
  
  // Timer単発の使用テスト
  final oneShotTimer = Timer(3.0, onTick: () {
    print('One shot timer fired!');
  });
  
  print('One shot Timer created: ${oneShotTimer.toString()}');
}