import 'package:flutter/foundation.dart';
import '../core/flutter_data_manager_core.dart';

/// 数値データ操作の専用クラス
class FlutterNumericOperations {
  final FlutterDataManagerCore _core;

  FlutterNumericOperations(this._core);

  /// 整数データ保存
  Future<bool> saveInt(String key, int value) async {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _core.prefs!.setInt(key, value);
      if (success) {
        _core.cache[key] = value;
        if (_core.debugMode) {
          debugPrint('💾 Saved int: $key = $value');
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to save int $key: $e');
      return false;
    }
  }

  /// 整数データ読み込み
  int? loadInt(String key, {int? defaultValue}) {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _core.prefs!.getInt(key) ?? defaultValue;
      if (_core.debugMode && value != null) {
        debugPrint('📖 Loaded int: $key = $value');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load int $key: $e');
      return defaultValue;
    }
  }

  /// 浮動小数点データ保存
  Future<bool> saveDouble(String key, double value) async {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _core.prefs!.setDouble(key, value);
      if (success) {
        _core.cache[key] = value;
        if (_core.debugMode) {
          debugPrint('💾 Saved double: $key = $value');
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to save double $key: $e');
      return false;
    }
  }

  /// 浮動小数点データ読み込み
  double? loadDouble(String key, {double? defaultValue}) {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _core.prefs!.getDouble(key) ?? defaultValue;
      if (_core.debugMode && value != null) {
        debugPrint('📖 Loaded double: $key = $value');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load double $key: $e');
      return defaultValue;
    }
  }

  /// ブール値データ保存
  Future<bool> saveBool(String key, bool value) async {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _core.prefs!.setBool(key, value);
      if (success) {
        _core.cache[key] = value;
        if (_core.debugMode) {
          debugPrint('💾 Saved bool: $key = $value');
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Failed to save bool $key: $e');
      return false;
    }
  }

  /// ブール値データ読み込み
  bool? loadBool(String key, {bool? defaultValue}) {
    if (!_core.isInitialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _core.prefs!.getBool(key) ?? defaultValue;
      if (_core.debugMode && value != null) {
        debugPrint('📖 Loaded bool: $key = $value');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load bool $key: $e');
      return defaultValue;
    }
  }
}
