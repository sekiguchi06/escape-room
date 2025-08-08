import '../test_utils/test_environment.dart';
import '../analytics/analytics_system.dart';
import '../analytics/providers/firebase_analytics_provider.dart';
import 'package:flutter/foundation.dart';

/// AnalyticsProvider自動選択ファクトリー
/// 
/// 実行環境に基づいて適切なAnalyticsProvider実装を自動選択：
/// - テスト環境: ConsoleAnalyticsProvider（プラットフォーム依存なし）
/// - プロダクション環境: FirebaseAnalyticsProvider（実際のFirebase連携）
class AnalyticsProviderFactory {
  
  /// 環境に応じた最適なAnalyticsProvider実装を作成
  /// 
  /// [forceImplementation] - 強制的に特定の実装を使用する場合
  /// [testEnvironment] - テスト環境かどうかを明示的に指定
  static AnalyticsProvider create({
    String? forceImplementation,
    bool? testEnvironment,
  }) {
    // 強制指定がある場合
    if (forceImplementation != null) {
      return _createByName(forceImplementation);
    }
    
    // テスト環境判定（明示指定 > 自動検知）
    final isTest = testEnvironment ?? TestEnvironmentDetector.isDefinitelyTestEnvironment;
    
    if (isTest) {
      debugPrint('📊 AnalyticsProvider: ConsoleAnalyticsProvider (Test Environment)');
      return ConsoleAnalyticsProvider();
    } else {
      debugPrint('📊 AnalyticsProvider: FirebaseAnalyticsProvider (Production Environment)');
      return FirebaseAnalyticsProvider();
    }
  }
  
  /// 名前による実装作成（主にテスト・デバッグ用）
  static AnalyticsProvider _createByName(String name) {
    switch (name.toLowerCase()) {
      case 'console':
      case 'mock':
      case 'test':
        return ConsoleAnalyticsProvider();
      case 'firebase':
      case 'production':
      case 'real':
        return FirebaseAnalyticsProvider();
      default:
        throw ArgumentError('Unknown AnalyticsProvider implementation: $name');
    }
  }
  
  /// 利用可能な実装一覧
  static List<String> get availableImplementations => [
    'console',
    'firebase',
  ];
  
  /// デバッグ情報
  static Map<String, dynamic> get debugInfo => {
    'testEnvironment': TestEnvironmentDetector.isDefinitelyTestEnvironment,
    'selectedProvider': TestEnvironmentDetector.isDefinitelyTestEnvironment 
        ? 'ConsoleAnalyticsProvider' 
        : 'FirebaseAnalyticsProvider',
    'availableImplementations': availableImplementations,
    ...TestEnvironmentDetector.debugInfo,
  };
}

/// ファクトリーを使用した便利な拡張
extension AnalyticsProviderFactoryExtension on AnalyticsProvider {
  
  /// 現在のproviderがテスト環境用かどうか
  bool get isTestProvider => this is ConsoleAnalyticsProvider;
  
  /// 現在のproviderがプロダクション環境用かどうか
  bool get isProductionProvider => this is FirebaseAnalyticsProvider;
  
  /// プロバイダー名を取得
  String get providerName {
    if (this is ConsoleAnalyticsProvider) return 'ConsoleAnalyticsProvider';
    if (this is FirebaseAnalyticsProvider) return 'FirebaseAnalyticsProvider';
    return runtimeType.toString();
  }
}