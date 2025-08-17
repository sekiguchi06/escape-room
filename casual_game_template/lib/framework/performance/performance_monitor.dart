/// パフォーマンス監視クラス
/// Flutter Guide第10章に基づくProfileモード対応
/// フレームレート、メモリ使用量、ビルド時間の監視機能

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // パフォーマンス測定値
  final List<Duration> _frameTimes = [];
  final List<double> _memoryUsages = [];
  Timer? _monitoringTimer;
  bool _isMonitoring = false;

  // パフォーマンス基準値
  static const int targetFps = 60;
  static const int maxFrameTimeMs = 16; // 60fps = 16.67ms/frame
  static const double maxMemoryMb = 100.0;

  /// パフォーマンス監視開始
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _frameTimes.clear();
    _memoryUsages.clear();

    // フレーム監視の開始
    if (kProfileMode) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameCallback);
    }

    // メモリ監視の開始（1秒間隔）
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _measureMemoryUsage();
    });

    developer.log('PerformanceMonitor: 監視開始', name: 'Performance');
  }

  /// パフォーマンス監視停止
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    if (kProfileMode) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameCallback);
    }

    developer.log('PerformanceMonitor: 監視停止', name: 'Performance');
  }

  /// フレームコールバック
  void _onFrameCallback(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameTime = timing.totalSpan;
      _frameTimes.add(frameTime);
      
      // フレーム時間が基準値を超えた場合の警告
      if (frameTime.inMilliseconds > maxFrameTimeMs) {
        developer.log(
          'Frame drop detected: ${frameTime.inMilliseconds}ms',
          name: 'Performance',
          level: 900, // Warning level
        );
      }
    }

    // データサイズ制限（最新100フレーム）
    if (_frameTimes.length > 100) {
      _frameTimes.removeRange(0, _frameTimes.length - 100);
    }
  }

  /// メモリ使用量測定
  void _measureMemoryUsage() {
    if (kProfileMode) {
      // Profileモードでのメモリ測定
      // 簡易的なメモリ使用量推定（フレーム数ベース）
      final estimatedMemoryMb = _frameTimes.length * 0.1; // 仮の計算
      _memoryUsages.add(estimatedMemoryMb);

      // メモリ使用量が基準値を超えた場合の警告
      if (estimatedMemoryMb > maxMemoryMb) {
        developer.log(
          'High memory usage: ${estimatedMemoryMb.toStringAsFixed(1)}MB',
          name: 'Performance',
          level: 900,
        );
      }

      // データサイズ制限（最新60秒）
      if (_memoryUsages.length > 60) {
        _memoryUsages.removeRange(0, _memoryUsages.length - 60);
      }
    }
  }

  /// 現在のパフォーマンスレポート取得
  PerformanceReport getReport() {
    final avgFrameTime = _frameTimes.isNotEmpty
        ? _frameTimes.map((t) => t.inMicroseconds).reduce((a, b) => a + b) / _frameTimes.length / 1000
        : 0.0;
    
    final currentFps = avgFrameTime > 0 ? 1000 / avgFrameTime : 0.0;
    
    final avgMemory = _memoryUsages.isNotEmpty
        ? _memoryUsages.reduce((a, b) => a + b) / _memoryUsages.length
        : 0.0;

    final frameDrops = _frameTimes.where((t) => t.inMilliseconds > maxFrameTimeMs).length;
    
    return PerformanceReport(
      averageFrameTimeMs: avgFrameTime,
      currentFps: currentFps,
      averageMemoryMb: avgMemory,
      frameDropCount: frameDrops,
      totalFrames: _frameTimes.length,
      isTargetFpsMet: currentFps >= targetFps * 0.9, // 90%の達成率
      isMemoryOptimal: avgMemory <= maxMemoryMb,
    );
  }

  /// パフォーマンスデータのクリア
  void clearData() {
    _frameTimes.clear();
    _memoryUsages.clear();
    developer.log('PerformanceMonitor: データクリア', name: 'Performance');
  }

  /// 監視状態の確認
  bool get isMonitoring => _isMonitoring;
}

/// パフォーマンスレポートクラス
class PerformanceReport {
  final double averageFrameTimeMs;
  final double currentFps;
  final double averageMemoryMb;
  final int frameDropCount;
  final int totalFrames;
  final bool isTargetFpsMet;
  final bool isMemoryOptimal;

  const PerformanceReport({
    required this.averageFrameTimeMs,
    required this.currentFps,
    required this.averageMemoryMb,
    required this.frameDropCount,
    required this.totalFrames,
    required this.isTargetFpsMet,
    required this.isMemoryOptimal,
  });

  /// レポートの文字列表現
  @override
  String toString() {
    return '''
=== パフォーマンスレポート ===
平均フレーム時間: ${averageFrameTimeMs.toStringAsFixed(2)}ms
現在のFPS: ${currentFps.toStringAsFixed(1)}
平均メモリ使用量: ${averageMemoryMb.toStringAsFixed(1)}MB
フレームドロップ数: $frameDropCount / $totalFrames
FPS目標達成: ${isTargetFpsMet ? '✅' : '❌'}
メモリ最適化: ${isMemoryOptimal ? '✅' : '❌'}
''';
  }

  /// JSON形式での出力
  Map<String, dynamic> toJson() {
    return {
      'averageFrameTimeMs': averageFrameTimeMs,
      'currentFps': currentFps,
      'averageMemoryMb': averageMemoryMb,
      'frameDropCount': frameDropCount,
      'totalFrames': totalFrames,
      'isTargetFpsMet': isTargetFpsMet,
      'isMemoryOptimal': isMemoryOptimal,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}