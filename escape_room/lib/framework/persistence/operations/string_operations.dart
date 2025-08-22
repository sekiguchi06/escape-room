import 'package:flutter/foundation.dart';
import '../core/flutter_data_manager_core.dart';

/// 文字列データ操作の専用クラス
class FlutterStringOperations {
  final FlutterDataManagerCore _core;

  FlutterStringOperations(this._core);

  /// 文字列データ保存
  Future<bool> saveString(String key, String value) async {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _core.prefs!.setString(key, value);
      if (success) {
        _core.cache[key] = value;
        if (_core.debugMode) {
          debugPrint(
            '💾 Saved string: $key = ${value.length > 50 ? '${value.substring(0, 50)}...' : value}',
          );
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to save string $key: $e');
      return false;
    }
  }

  /// 文字列データ読み込み
  String? loadString(String key, {String? defaultValue}) {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _core.prefs!.getString(key) ?? defaultValue;
      if (_core.debugMode && value != null) {
        debugPrint(
          '📖 Loaded string: $key = ${value.length > 50 ? '${value.substring(0, 50)}...' : value}',
        );
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load string $key: $e');
      return defaultValue;
    }
  }

  /// 文字列リストデータ保存
  Future<bool> saveStringList(String key, List<String> value) async {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _core.prefs!.setStringList(key, value);
      if (success) {
        _core.cache[key] = List<String>.from(value);
        if (_core.debugMode) {
          debugPrint('💾 Saved stringList: $key = ${value.length} items');
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to save stringList $key: $e');
      return false;
    }
  }

  /// 文字列リストデータ読み込み
  List<String>? loadStringList(String key, {List<String>? defaultValue}) {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _core.prefs!.getStringList(key) ?? defaultValue;
      if (_core.debugMode && value != null) {
        debugPrint('📖 Loaded stringList: $key = ${value.length} items');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load stringList $key: $e');
      return defaultValue;
    }
  }
}
