/// カジュアルゲーム開発フレームワーク
/// 
/// Flutter + Flame をベースとした汎用フレームワークで、
/// 設定駆動でゲームを構築し、迅速なプロトタイピングを実現します。
library;

import 'package:flutter/foundation.dart';
/// 
/// ## 主な機能
/// - 汎用状態管理システム
/// - 設定駆動ゲーム構築
/// - タイマー管理システム  
/// - UIテーマ管理システム
/// - A/Bテスト・リモート設定対応
/// - アナリティクス統合
/// 
/// ## 使用例
/// ```dart
/// import 'package:casual_game_template/framework/framework.dart';
/// 
/// // 基本的な使用法
/// final game = ConfigurableGameBuilder<MyGameState, MyGameConfig>()
///     .withConfiguration(myConfiguration)
///     .withDebugMode(true)
///     .build(() => MyGame());
/// ```

// Core System
export 'core/configurable_game.dart';

// Configuration System
export 'config/game_configuration.dart';

// State Management System
export 'state/game_state_system.dart';

// Timer System
export 'timer/flame_timer_system.dart';

// UI System
export 'ui/ui_system.dart';

/// フレームワークのバージョン情報
class FrameworkInfo {
  static const String version = '1.0.0';
  static const String name = 'Casual Game Framework';
  static const String description = 'Flutter + Flame ベースの汎用カジュアルゲーム開発フレームワーク';
  
  /// フレームワーク情報を表示
  static void printInfo() {
    debugPrint('🎮 $name v$version');
    debugPrint('📝 $description');
    debugPrint('🔧 利用可能なシステム:');
    debugPrint('   - ConfigurableGame (汎用ゲーム基底クラス)');
    debugPrint('   - GameConfiguration (設定管理)');
    debugPrint('   - GameStateMachine (状態管理)');
    debugPrint('   - TimerManager (タイマー管理)');
    debugPrint('   - ThemeManager (UIテーマ管理)');
    debugPrint('');
    debugPrint('📚 詳細なドキュメントは docs/casual_game_framework_design.md を参照してください');
  }
}

/// フレームワークの初期化
class FrameworkInitializer {
  static bool _initialized = false;
  
  /// フレームワークを初期化
  static void initialize({bool showInfo = false}) {
    if (_initialized) {
      debugPrint('⚠️ Framework already initialized');
      return;
    }
    
    // テーマの初期化
    // ThemeManager initialization moved to configurable_game.dart
    
    // タイマープリセットの初期化
    // TimerPresets は既に静的なので初期化不要
    
    _initialized = true;
    
    if (showInfo) {
      FrameworkInfo.printInfo();
    }
    
    debugPrint('✅ Casual Game Framework initialized');
  }
  
  /// 初期化状態を取得
  static bool get isInitialized => _initialized;
}