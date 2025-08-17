import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/framework/performance/performance_monitor.dart';

void main() {
  group('PerformanceMonitor Tests', () {
    late PerformanceMonitor monitor;

    setUp(() {
      monitor = PerformanceMonitor();
      monitor.clearData();
    });

    tearDown(() {
      monitor.stopMonitoring();
      monitor.clearData();
    });

    test('初期状態では監視が停止している', () {
      expect(monitor.isMonitoring, isFalse);
    });

    test('監視開始・停止が正常に動作する', () {
      monitor.startMonitoring();
      expect(monitor.isMonitoring, isTrue);

      monitor.stopMonitoring();
      expect(monitor.isMonitoring, isFalse);
    });

    test('パフォーマンスレポートが取得できる', () {
      final report = monitor.getReport();
      
      expect(report, isA<PerformanceReport>());
      expect(report.averageFrameTimeMs, isA<double>());
      expect(report.currentFps, isA<double>());
      expect(report.averageMemoryMb, isA<double>());
      expect(report.frameDropCount, isA<int>());
      expect(report.totalFrames, isA<int>());
      expect(report.isTargetFpsMet, isA<bool>());
      expect(report.isMemoryOptimal, isA<bool>());
    });

    test('データクリアが正常に動作する', () {
      monitor.clearData();
      final report = monitor.getReport();
      
      expect(report.totalFrames, equals(0));
      expect(report.frameDropCount, equals(0));
    });

    test('レポートのJSON変換が正常に動作する', () {
      final report = monitor.getReport();
      final json = report.toJson();
      
      expect(json, isA<Map<String, dynamic>>());
      expect(json['averageFrameTimeMs'], isA<double>());
      expect(json['currentFps'], isA<double>());
      expect(json['averageMemoryMb'], isA<double>());
      expect(json['frameDropCount'], isA<int>());
      expect(json['totalFrames'], isA<int>());
      expect(json['isTargetFpsMet'], isA<bool>());
      expect(json['isMemoryOptimal'], isA<bool>());
      expect(json['timestamp'], isA<String>());
    });

    test('レポートの文字列表現が適切にフォーマットされる', () {
      final report = monitor.getReport();
      final reportString = report.toString();
      
      expect(reportString, contains('パフォーマンスレポート'));
      expect(reportString, contains('平均フレーム時間'));
      expect(reportString, contains('現在のFPS'));
      expect(reportString, contains('平均メモリ使用量'));
      expect(reportString, contains('フレームドロップ数'));
    });

    test('シングルトンパターンが正しく実装されている', () {
      final monitor1 = PerformanceMonitor();
      final monitor2 = PerformanceMonitor();
      
      expect(identical(monitor1, monitor2), isTrue);
    });
  });

  group('PerformanceReport Tests', () {
    test('理想的な性能値でのレポート作成', () {
      const report = PerformanceReport(
        averageFrameTimeMs: 16.0,
        currentFps: 60.0,
        averageMemoryMb: 50.0,
        frameDropCount: 0,
        totalFrames: 100,
        isTargetFpsMet: true,
        isMemoryOptimal: true,
      );

      expect(report.currentFps, equals(60.0));
      expect(report.isTargetFpsMet, isTrue);
      expect(report.isMemoryOptimal, isTrue);
      expect(report.frameDropCount, equals(0));
    });

    test('性能問題がある場合のレポート作成', () {
      const report = PerformanceReport(
        averageFrameTimeMs: 25.0,
        currentFps: 40.0,
        averageMemoryMb: 150.0,
        frameDropCount: 15,
        totalFrames: 100,
        isTargetFpsMet: false,
        isMemoryOptimal: false,
      );

      expect(report.currentFps, equals(40.0));
      expect(report.isTargetFpsMet, isFalse);
      expect(report.isMemoryOptimal, isFalse);
      expect(report.frameDropCount, equals(15));
    });
  });
}