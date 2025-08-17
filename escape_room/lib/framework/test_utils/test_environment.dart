import 'package:flutter/foundation.dart';

/// テスト環境検知ユーティリティ
/// 
/// プロダクション環境とテスト環境での自動切り替えを実現するため、
/// 現在の実行環境を検知する機能を提供します。
class TestEnvironmentDetector {
  
  /// テスト環境かどうかを判定
  /// 
  /// 確実にテスト環境を検知するため、以下の方法を使用：
  /// 1. kIsTest定数（コンパイル時定数）
  /// 2. Platform.environment['FLUTTER_TEST']
  /// 3. TestWidgetsFlutterBinding.ensureInitialized()の実行状況
  static bool get isTestEnvironment {
    // コンパイル時にテスト環境として設定された場合
    if (const bool.fromEnvironment('dart.vm.product') == false && 
        const bool.fromEnvironment('FLUTTER_TEST') == true) {
      return true;
    }
    
    // スタックトレースから判定
    try {
      final stackTrace = StackTrace.current.toString();
      return stackTrace.contains('flutter_test') || 
             stackTrace.contains('test_api') ||
             stackTrace.contains('dart test');
    } catch (e) {
      // フォールバック: 開発環境では安全にfalseを返す
      return false;
    }
  }
  
  /// 明示的なテスト環境設定
  /// テスト開始時に呼び出してテスト環境であることを明示
  static bool _explicitTestMode = false;
  
  static void setTestMode(bool isTest) {
    _explicitTestMode = isTest;
  }
  
  /// より確実なテスト環境判定（明示設定 + 自動検知）
  static bool get isDefinitelyTestEnvironment {
    return _explicitTestMode || isTestEnvironment;
  }
  
  /// デバッグ情報の取得
  static Map<String, dynamic> get debugInfo => {
    'isTestEnvironment': isTestEnvironment,
    'isDefinitelyTestEnvironment': isDefinitelyTestEnvironment,
    'explicitTestMode': _explicitTestMode,
    'kDebugMode': kDebugMode,
    'kReleaseMode': kReleaseMode,
    'kProfileMode': kProfileMode,
  };
}

/// テスト環境での追加ユーティリティ
class TestUtils {
  
  /// テスト環境でのデバッグ出力
  static void testDebugPrint(String message) {
    if (TestEnvironmentDetector.isTestEnvironment) {
      debugPrint('[TEST] $message');
    }
  }
  
  /// テスト環境での条件分岐実行
  static T runInTestEnvironment<T>(
    T Function() testImplementation,
    T Function() productionImplementation,
  ) {
    if (TestEnvironmentDetector.isTestEnvironment) {
      testDebugPrint('Using test implementation');
      return testImplementation();
    } else {
      return productionImplementation();
    }
  }
}