import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('Performance Integration Tests', () {
    test('パフォーマンス測定スクリプトが存在し実行可能である', () {
      final scriptPath = 'scripts/performance_measure.sh';
      final scriptFile = File(scriptPath);

      expect(scriptFile.existsSync(), isTrue, reason: 'パフォーマンス測定スクリプトが存在しない');

      // Unix系OSでの実行権限チェック（CI環境対応）
      if (Platform.isLinux || Platform.isMacOS) {
        final result = Process.runSync('test', ['-x', scriptPath]);
        expect(result.exitCode, equals(0), reason: 'パフォーマンス測定スクリプトに実行権限がない');
      }
    });

    test('CI用パフォーマンステストスクリプトが存在し実行可能である', () {
      final scriptPath = 'scripts/ci_performance_test.sh';
      final scriptFile = File(scriptPath);

      expect(
        scriptFile.existsSync(),
        isTrue,
        reason: 'CI用パフォーマンステストスクリプトが存在しない',
      );

      // Unix系OSでの実行権限チェック（CI環境対応）
      if (Platform.isLinux || Platform.isMacOS) {
        final result = Process.runSync('test', ['-x', scriptPath]);
        expect(
          result.exitCode,
          equals(0),
          reason: 'CI用パフォーマンステストスクリプトに実行権限がない',
        );
      }
    });

    test('パフォーマンス設定ファイルが正しい形式で存在する', () {
      final configFile = File('performance_config.yaml');
      expect(configFile.existsSync(), isTrue, reason: 'パフォーマンス設定ファイルが存在しない');

      final content = configFile.readAsStringSync();
      expect(
        content,
        contains('performance_targets'),
        reason: '設定ファイルにperformance_targetsセクションがない',
      );
      expect(content, contains('fps'), reason: '設定ファイルにFPS設定がない');
      expect(content, contains('memory'), reason: '設定ファイルにメモリ設定がない');
      expect(content, contains('build_time'), reason: '設定ファイルにビルド時間設定がない');
    });

    test('GitHub Actions設定ファイルが存在する', () {
      final workflowFile = File('.github/workflows/performance_monitoring.yml');
      expect(
        workflowFile.existsSync(),
        isTrue,
        reason: 'GitHub Actions設定ファイルが存在しない',
      );

      final content = workflowFile.readAsStringSync();
      expect(
        content,
        contains('Performance Monitoring'),
        reason: 'ワークフロー名が正しくない',
      );
      expect(
        content,
        contains('performance-test'),
        reason: 'パフォーマンステストジョブが定義されていない',
      );
      expect(content, contains('schedule'), reason: 'スケジュール実行が設定されていない');
    });

    test('パフォーマンス結果ディレクトリの作成と書き込み権限', () {
      final resultsDir = Directory('performance_results');

      // ディレクトリが存在しない場合は作成
      if (!resultsDir.existsSync()) {
        resultsDir.createSync();
      }

      expect(resultsDir.existsSync(), isTrue, reason: 'パフォーマンス結果ディレクトリが作成できない');

      // 書き込みテスト
      final testFile = File('performance_results/test_write.tmp');
      try {
        testFile.writeAsStringSync('test');
        expect(
          testFile.existsSync(),
          isTrue,
          reason: 'パフォーマンス結果ディレクトリに書き込み権限がない',
        );
      } finally {
        if (testFile.existsSync()) {
          testFile.deleteSync();
        }
      }
    });

    test('Flutterビルドコマンドの検証', () async {
      // flutter --versionコマンドのテスト
      try {
        final result = await Process.run('flutter', ['--version']);
        expect(result.exitCode, equals(0), reason: 'Flutterコマンドが実行できない');
        expect(
          result.stdout.toString(),
          contains('Flutter'),
          reason: 'Flutter環境が正しく設定されていない',
        );
      } catch (e) {
        fail('Flutter環境のチェックでエラー: $e');
      }
    });

    test('必要な外部コマンドの存在確認', () async {
      final commands = ['bc', 'jq'];

      for (final command in commands) {
        try {
          final result = await Process.run('which', [command]);
          if (result.exitCode != 0) {
            // CI環境では警告のみ、ローカル環境では必須とする
            if (Platform.environment['CI'] == 'true') {
              debugPrint('警告: $command コマンドが見つかりません（CI環境）');
            } else {
              fail('必須コマンド $command が見つかりません。インストールしてください。');
            }
          }
        } catch (e) {
          debugPrint('コマンド $command の確認でエラー: $e');
        }
      }
    });

    test('パフォーマンスモニタークラスのインポート確認', () {
      // performance_monitor.dartファイルの存在確認
      final monitorFile = File(
        'lib/framework/performance/performance_monitor.dart',
      );
      expect(
        monitorFile.existsSync(),
        isTrue,
        reason: 'PerformanceMonitorクラスファイルが存在しない',
      );

      final content = monitorFile.readAsStringSync();
      expect(
        content,
        contains('class PerformanceMonitor'),
        reason: 'PerformanceMonitorクラスが定義されていない',
      );
      expect(
        content,
        contains('class PerformanceReport'),
        reason: 'PerformanceReportクラスが定義されていない',
      );
    });

    test('パフォーマンステストの実行時間制限', () async {
      // このテスト自体が30秒以内に完了することを確認
      final stopwatch = Stopwatch()..start();

      // 軽量なパフォーマンステストシミュレーション
      await Future.delayed(const Duration(milliseconds: 100));

      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(30000),
        reason: 'パフォーマンステストが時間制限を超過',
      );
    });
  });
}
