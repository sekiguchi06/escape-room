import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Flutter公式準拠の永続化システム - コア機能
class FlutterDataManagerCore {
  SharedPreferences? _prefs;
  bool _initialized = false;
  final Map<String, dynamic> _cache = <String, dynamic>{};
  final bool _debugMode;

  FlutterDataManagerCore({bool debugMode = false}) : _debugMode = debugMode;

  /// 初期化
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;

      if (_debugMode) {
        debugPrint(
          '🗃️ FlutterDataManager initialized with shared_preferences',
        );
      }
    } catch (e) {
      debugPrint('❌ FlutterDataManager initialization failed: $e');
      rethrow;
    }
  }

  /// 初期化状態確認
  bool get isInitialized => _initialized;

  /// SharedPreferences インスタンス取得
  SharedPreferences? get prefs => _prefs;

  /// キャッシュ取得
  Map<String, dynamic> get cache => _cache;

  /// デバッグモード確認
  bool get debugMode => _debugMode;

  /// データ存在確認
  bool containsKey(String key) {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    return _prefs!.containsKey(key);
  }

  /// 保存済みキー一覧取得
  Set<String> getKeys() {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return <String>{};
    }

    return _prefs!.getKeys();
  }

  /// 再読み込み
  Future<void> reload() async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return;
    }

    try {
      await _prefs!.reload();
      if (_debugMode) {
        debugPrint('🔄 SharedPreferences reloaded');
      }
    } catch (e) {
      debugPrint('❌ Failed to reload SharedPreferences: $e');
    }
  }

  /// 全データクリア
  Future<bool> clear() async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _prefs!.clear();
      if (success) {
        _cache.clear();
        if (_debugMode) {
          debugPrint('🧹 All data cleared');
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to clear all data: $e');
      return false;
    }
  }

  /// データ削除
  Future<bool> remove(String key) async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _prefs!.remove(key);
      if (success) {
        _cache.remove(key);
        if (_debugMode) {
          debugPrint('🗑️ Removed: $key');
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to remove $key: $e');
      return false;
    }
  }

  /// デバッグ情報取得
  Map<String, dynamic> getDebugInfo() {
    return <String, dynamic>{
      'flutter_official_compliant': true,
      'package': 'shared_preferences',
      'initialized': _initialized,
      'debug_mode': _debugMode,
      'total_keys': _initialized ? _prefs!.getKeys().length : 0,
      'cached_items': _cache.length,
      'available_keys': _initialized ? _prefs!.getKeys().toList() : <String>[],
    };
  }
}
