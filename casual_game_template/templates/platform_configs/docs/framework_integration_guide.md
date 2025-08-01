# フレームワーク統合ガイド

このドキュメントでは、カジュアルゲームテンプレートのフレームワークに新しいプロバイダーやサービスを統合する方法を説明します。

## アーキテクチャ概要

カジュアルゲームテンプレートは以下の階層構造で設計されています：

```
game/                    # ゲーム固有のロジック
├── simple_game.dart     # メインゲームクラス
└── ...

framework/               # 再利用可能なフレームワーク
├── analytics/           # 分析システム
├── monetization/        # 収益化システム
├── ui/                  # UI システム
├── audio/               # 音声システム
└── effects/             # エフェクトシステム

templates/               # 設定テンプレート
└── platform_configs/    # プラットフォーム設定
```

## プロバイダーパターンの実装

### 1. インターフェース定義

新しいサービスを追加する場合、まず抽象インターフェースを定義します：

```dart
// framework/[service_name]/[service_name]_system.dart
abstract class ServiceProvider {
  Future<bool> initialize(ServiceConfiguration config);
  Future<void> dispose();
  // その他の必要なメソッド
}
```

### 2. 設定クラス定義

サービスの設定を管理するクラスを作成：

```dart
class ServiceConfiguration {
  final bool debugMode;
  final bool testMode;
  final Map<String, dynamic> customSettings;
  
  const ServiceConfiguration({
    this.debugMode = false,
    this.testMode = true,
    this.customSettings = const {},
  });
}
```

### 3. 具象実装クラス

プラットフォーム固有の実装を作成：

```dart
// framework/[service_name]/providers/[platform]_[service]_provider.dart
class PlatformServiceProvider implements ServiceProvider {
  @override
  Future<bool> initialize(ServiceConfiguration config) async {
    try {
      // プラットフォーム固有の初期化処理
      return true;
    } catch (e) {
      debugPrint('⚠️ ServiceProvider initialization failed, using mock mode: $e');
      // Mock モードで継続
      return true;
    }
  }
  
  @override
  Future<void> dispose() async {
    // リソースのクリーンアップ
  }
}
```

## エラーハンドリングパターン

### Graceful Degradation

フレームワークでは設定ファイルの欠損やサービスの初期化失敗時に、Mock モードで動作を継続します：

```dart
Future<bool> initialize(ServiceConfiguration config) async {
  try {
    // 実際のサービス初期化
    await actualService.initialize();
    return true;
  } catch (e) {
    debugPrint('⚠️ Service initialization failed, using mock mode: $e');
    _mockMode = true;
    return true; // 失敗でも継続
  }
}
```

### Mock モード実装

```dart
Future<bool> performAction() async {
  if (_mockMode) {
    if (_config?.debugMode == true) {
      debugPrint('🔧 [MOCK] Service action performed');
    }
    return true; // Mock では常に成功
  }
  
  // 実際の処理
  return await actualService.performAction();
}
```

## テスト戦略

### 1. 単体テスト

各プロバイダーの単体テストを作成：

```dart
// test/framework/[service]/providers/[platform]_[service]_provider_test.dart
void main() {
  group('PlatformServiceProvider', () {
    late PlatformServiceProvider provider;
    
    setUp(() {
      provider = PlatformServiceProvider();
    });
    
    test('should initialize successfully with valid config', () async {
      final config = ServiceConfiguration(testMode: true);
      final result = await provider.initialize(config);
      expect(result, isTrue);
    });
    
    test('should handle initialization failure gracefully', () async {
      // 初期化失敗をシミュレート
      final result = await provider.initialize(null);
      expect(result, isTrue); // Mock モードで継続
    });
  });
}
```

### 2. 統合テスト

システム全体の統合テストを作成：

```dart
// test/integration/service_integration_test.dart
void main() {
  testWidgets('Service integration test', (WidgetTesting tester) async {
    // アプリ全体の初期化
    await tester.pumpWidget(MyApp());
    
    // サービスが正常に初期化されることを確認
    // UI での動作確認
  });
}
```

## 設定管理パターン

### 1. 環境別設定

```dart
class ServiceConfiguration {
  static ServiceConfiguration development() {
    return ServiceConfiguration(
      debugMode: true,
      testMode: true,
      customSettings: {
        'api_endpoint': 'https://dev-api.example.com',
      },
    );
  }
  
  static ServiceConfiguration production() {
    return ServiceConfiguration(
      debugMode: false,
      testMode: false,
      customSettings: {
        'api_endpoint': 'https://api.example.com',
      },
    );
  }
}
```

### 2. 設定ファイルからの読み込み

```dart
Future<ServiceConfiguration> loadConfiguration() async {
  try {
    final configFile = await File('config/service_config.json').readAsString();
    final configJson = json.decode(configFile);
    return ServiceConfiguration.fromJson(configJson);
  } catch (e) {
    debugPrint('Config file not found, using defaults: $e');
    return ServiceConfiguration.development();
  }
}
```

## ログ出力パターン

### 統一ログフォーマット

```dart
void _log(String message, {String level = 'INFO'}) {
  if (_config?.debugMode == true) {
    final timestamp = DateTime.now().toIso8601String();
    final serviceName = runtimeType.toString();
    debugPrint('[$timestamp] [$level] [$serviceName] $message');
  }
}

// 使用例
_log('🚀 Service initialized successfully');
_log('⚠️ Service initialization failed', level: 'WARN');
_log('❌ Critical error occurred', level: 'ERROR');
```

## プラットフォーム固有実装

### Web プラットフォーム対応

```dart
import 'package:flutter/foundation.dart';

class ServiceProvider {
  Future<bool> initialize(ServiceConfiguration config) async {
    if (kIsWeb) {
      return await _initializeForWeb(config);
    } else {
      return await _initializeForMobile(config);
    }
  }
  
  Future<bool> _initializeForWeb(ServiceConfiguration config) async {
    // Web 固有の初期化
  }
  
  Future<bool> _initializeForMobile(ServiceConfiguration config) async {
    // モバイル固有の初期化
  }
}
```

## パフォーマンス考慮事項

### 1. 遅延初期化

```dart
class ServiceProvider {
  bool _initialized = false;
  
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _performInitialization();
      _initialized = true;
    }
  }
  
  Future<bool> performAction() async {
    await _ensureInitialized();
    // アクション実行
  }
}
```

### 2. リソース管理

```dart
class ServiceProvider {
  final List<StreamSubscription> _subscriptions = [];
  
  @override
  Future<void> dispose() async {
    // 全てのサブスクリプションをキャンセル
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    
    // その他のリソースクリーンアップ
  }
}
```

## 新しいサービスの追加手順

1. **インターフェース定義**: `framework/[service]/[service]_system.dart`
2. **設定クラス作成**: 上記ファイル内に Configuration クラス
3. **プロバイダー実装**: `framework/[service]/providers/[platform]_[service]_provider.dart`
4. **単体テスト作成**: `test/framework/[service]/providers/[platform]_[service]_provider_test.dart`
5. **統合テスト作成**: `test/integration/[service]_integration_test.dart`
6. **ドキュメント更新**: 使用方法とAPI仕様を文書化
7. **テンプレート作成**: 必要に応じて設定テンプレートを作成

## ベストプラクティス

1. **Fail-Safe 設計**: 初期化失敗時も Mock モードで継続
2. **設定駆動**: ハードコードを避け、設定クラスで制御
3. **プラットフォーム抽象化**: プラットフォーム固有コードを隠蔽
4. **適切なログ出力**: デバッグとトラブルシューティングを支援
5. **リソース管理**: dispose() での適切なクリーンアップ
6. **テスト可能性**: Mock モードとテスト ID の提供

この統合ガイドに従うことで、既存のフレームワークに新しいサービスを安全かつ効率的に追加できます。