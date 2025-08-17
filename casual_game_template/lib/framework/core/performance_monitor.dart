import 'package:flame/components.dart';
import '../timer/flame_timer_system.dart';

/// パフォーマンス監視ミックスイン
/// FPS、メモリ使用量、コンポーネント数等の監視機能を提供
mixin PerformanceMonitor on Component {
  /// タイマーマネージャー
  FlameTimerManager get timerManager;
  
  /// パフォーマンスメトリクスの取得
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'fps': 60.0, // 仮の値 - 実際のFPSは別途取得が必要
      'component_count': children.length,
      'timer_count': timerManager.getTimerIds().length,
      'running_timers': timerManager.getRunningTimerIds().length,
      'memory_usage': _getMemoryUsage(),
    };
  }
  
  double _getMemoryUsage() {
    // メモリ使用量の取得（概算）
    return children.length * 0.001; // 簡易計算
  }
  
  /// パフォーマンス警告のチェック
  List<String> checkPerformanceWarnings() {
    final warnings = <String>[];
    final metrics = getPerformanceMetrics();
    
    // コンポーネント数チェック
    final componentCount = metrics['component_count'] as int;
    if (componentCount > 1000) {
      warnings.add('High component count: $componentCount');
    }
    
    // 実行中タイマー数チェック
    final runningTimers = metrics['running_timers'] as int;
    if (runningTimers > 50) {
      warnings.add('High running timer count: $runningTimers');
    }
    
    // メモリ使用量チェック
    final memoryUsage = metrics['memory_usage'] as double;
    if (memoryUsage > 100.0) {
      warnings.add('High memory usage: ${memoryUsage.toStringAsFixed(2)}MB');
    }
    
    return warnings;
  }
  
  /// パフォーマンス最適化の提案
  List<String> getOptimizationSuggestions() {
    final suggestions = <String>[];
    final warnings = checkPerformanceWarnings();
    
    if (warnings.any((w) => w.contains('component count'))) {
      suggestions.add('Consider component pooling or removal of unused components');
    }
    
    if (warnings.any((w) => w.contains('timer count'))) {
      suggestions.add('Review timer usage and remove unnecessary timers');
    }
    
    if (warnings.any((w) => w.contains('memory usage'))) {
      suggestions.add('Implement memory management and resource cleanup');
    }
    
    return suggestions;
  }
}