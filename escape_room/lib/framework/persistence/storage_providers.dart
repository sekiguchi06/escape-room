import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'persistence_configuration.dart';

/// 永続化プロバイダーの抽象インターフェース
abstract class StorageProvider {
  /// 初期化
  Future<PersistenceResult> initialize(PersistenceConfiguration config);

  /// データ保存
  Future<PersistenceResult> save(String key, dynamic value);

  /// データ読み込み
  Future<T?> load<T>(String key, {T? defaultValue});

  /// データ削除
  Future<PersistenceResult> delete(String key);

  /// 全データクリア
  Future<PersistenceResult> clear();

  /// データ存在チェック
  Future<bool> exists(String key);

  /// 全保存済みキー取得
  Future<Set<String>> getAllKeys();

  /// データサイズ取得（バイト）
  Future<int> getDataSize(String key);

  /// ストレージ使用量取得（バイト）
  Future<int> getTotalStorageSize();

  /// バッチ保存
  Future<PersistenceResult> saveBatch(Map<String, dynamic> data);

  /// バッチ読み込み
  Future<Map<String, dynamic>> loadBatch(Set<String> keys);

  /// クラウド同期
  Future<PersistenceResult> syncToCloud();

  /// クラウドから復元
  Future<PersistenceResult> restoreFromCloud();

  /// リソース解放
  Future<void> dispose();
}

/// ローカルストレージプロバイダー（SharedPreferences基盤）
class LocalStorageProvider implements StorageProvider {
  PersistenceConfiguration? _config;
  final Map<String, dynamic> _cache = {};
  bool _initialized = false;

  @override
  Future<PersistenceResult> initialize(PersistenceConfiguration config) async {
    _config = config;

    try {
      // SharedPreferencesの初期化をシミュレート
      await Future.delayed(const Duration(milliseconds: 10));
      _initialized = true;

      if (config.debugMode) {
        debugPrint('LocalStorageProvider initialized');
      }

      return PersistenceResult.success;
    } catch (e) {
      debugPrint('LocalStorageProvider initialization failed: $e');
      return PersistenceResult.failure;
    }
  }

  @override
  Future<PersistenceResult> save(String key, dynamic value) async {
    if (!_initialized) return PersistenceResult.failure;

    try {
      String serialized;

      if (value is String) {
        serialized = value;
      } else {
        serialized = jsonEncode(value);
      }

      // 暗号化処理（シミュレート）
      if (_config?.encryptionEnabled == true) {
        serialized = _encrypt(serialized);
      }

      // ローカル保存をシミュレート
      _cache[key] = serialized;
      await Future.delayed(const Duration(milliseconds: 1));

      if (_config?.debugMode == true) {
        debugPrint(
          'Saved: $key = ${value.toString().length > 100 ? '${value.toString().substring(0, 100)}...' : value}',
        );
      }

      return PersistenceResult.success;
    } catch (e) {
      debugPrint('Save failed for key $key: $e');
      return PersistenceResult.failure;
    }
  }

  @override
  Future<T?> load<T>(String key, {T? defaultValue}) async {
    if (!_initialized) return defaultValue;

    try {
      String? serialized = _cache[key] as String?;

      if (serialized == null) {
        return defaultValue;
      }

      // 復号化処理（シミュレート）
      if (_config?.encryptionEnabled == true) {
        serialized = _decrypt(serialized);
      }

      // デシリアライズ
      dynamic value;
      if (T == String) {
        value = serialized;
      } else {
        value = jsonDecode(serialized);
      }

      if (_config?.debugMode == true) {
        debugPrint(
          'Loaded: $key = ${value.toString().length > 100 ? '${value.toString().substring(0, 100)}...' : value}',
        );
      }

      return value as T;
    } catch (e) {
      debugPrint('Load failed for key $key: $e');
      return defaultValue;
    }
  }

  @override
  Future<PersistenceResult> delete(String key) async {
    if (!_initialized) return PersistenceResult.failure;

    try {
      _cache.remove(key);

      if (_config?.debugMode == true) {
        debugPrint('Deleted: $key');
      }

      return PersistenceResult.success;
    } catch (e) {
      debugPrint('Delete failed for key $key: $e');
      return PersistenceResult.failure;
    }
  }

  @override
  Future<PersistenceResult> clear() async {
    if (!_initialized) return PersistenceResult.failure;

    try {
      _cache.clear();

      if (_config?.debugMode == true) {
        debugPrint('All data cleared');
      }

      return PersistenceResult.success;
    } catch (e) {
      debugPrint('Clear failed: $e');
      return PersistenceResult.failure;
    }
  }

  @override
  Future<bool> exists(String key) async {
    return _cache.containsKey(key);
  }

  @override
  Future<Set<String>> getAllKeys() async {
    return _cache.keys.toSet();
  }

  @override
  Future<int> getDataSize(String key) async {
    final value = _cache[key];
    if (value == null) return 0;

    return value.toString().length * 2; // UTF-16 approximation
  }

  @override
  Future<int> getTotalStorageSize() async {
    int totalSize = 0;
    for (final value in _cache.values) {
      totalSize += value.toString().length * 2;
    }
    return totalSize;
  }

  @override
  Future<PersistenceResult> saveBatch(Map<String, dynamic> data) async {
    try {
      for (final entry in data.entries) {
        final result = await save(entry.key, entry.value);
        if (result != PersistenceResult.success) {
          return result;
        }
      }
      return PersistenceResult.success;
    } catch (e) {
      debugPrint('Batch save failed: $e');
      return PersistenceResult.failure;
    }
  }

  @override
  Future<Map<String, dynamic>> loadBatch(Set<String> keys) async {
    final Map<String, dynamic> result = {};

    for (final key in keys) {
      final value = await load(key);
      if (value != null) {
        result[key] = value;
      }
    }

    return result;
  }

  @override
  Future<PersistenceResult> syncToCloud() async {
    if (_config?.cloudSyncEnabled != true) {
      return PersistenceResult.success; // クラウド同期無効時は成功扱い
    }

    try {
      // クラウド同期をシミュレート
      await Future.delayed(const Duration(milliseconds: 500));

      if (_config?.debugMode == true) {
        debugPrint('Cloud sync completed');
      }

      return PersistenceResult.success;
    } catch (e) {
      debugPrint('Cloud sync failed: $e');
      return PersistenceResult.networkError;
    }
  }

  @override
  Future<PersistenceResult> restoreFromCloud() async {
    if (_config?.cloudSyncEnabled != true) {
      return PersistenceResult.success;
    }

    try {
      // クラウドから復元をシミュレート
      await Future.delayed(const Duration(milliseconds: 300));

      if (_config?.debugMode == true) {
        debugPrint('Cloud restore completed');
      }

      return PersistenceResult.success;
    } catch (e) {
      debugPrint('Cloud restore failed: $e');
      return PersistenceResult.networkError;
    }
  }

  String _encrypt(String data) {
    // 簡易暗号化シミュレート（実際の実装ではAES等を使用）
    return base64Encode(utf8.encode(data));
  }

  String _decrypt(String encryptedData) {
    // 簡易復号化シミュレート
    return utf8.decode(base64Decode(encryptedData));
  }

  @override
  Future<void> dispose() async {
    _cache.clear();
    _initialized = false;
    debugPrint('LocalStorageProvider disposed');
  }
}

/// メモリストレージプロバイダー（テスト用）
class MemoryStorageProvider implements StorageProvider {
  PersistenceConfiguration? _config;
  final Map<String, dynamic> _memory = {};
  bool _initialized = false;

  @override
  Future<PersistenceResult> initialize(PersistenceConfiguration config) async {
    _config = config;
    _initialized = true;

    if (config.debugMode) {
      debugPrint('MemoryStorageProvider initialized');
    }

    return PersistenceResult.success;
  }

  @override
  Future<PersistenceResult> save(String key, dynamic value) async {
    if (!_initialized) return PersistenceResult.failure;

    _memory[key] = value;

    if (_config?.debugMode == true) {
      debugPrint('Memory saved: $key = $value');
    }

    return PersistenceResult.success;
  }

  @override
  Future<T?> load<T>(String key, {T? defaultValue}) async {
    if (!_initialized) return defaultValue;

    final value = _memory[key] as T?;

    if (_config?.debugMode == true) {
      debugPrint('Memory loaded: $key = $value');
    }

    return value ?? defaultValue;
  }

  @override
  Future<PersistenceResult> delete(String key) async {
    if (!_initialized) return PersistenceResult.failure;

    _memory.remove(key);
    return PersistenceResult.success;
  }

  @override
  Future<PersistenceResult> clear() async {
    if (!_initialized) return PersistenceResult.failure;

    _memory.clear();
    return PersistenceResult.success;
  }

  @override
  Future<bool> exists(String key) async {
    return _memory.containsKey(key);
  }

  @override
  Future<Set<String>> getAllKeys() async {
    return _memory.keys.toSet();
  }

  @override
  Future<int> getDataSize(String key) async {
    return _memory[key]?.toString().length ?? 0;
  }

  @override
  Future<int> getTotalStorageSize() async {
    return _memory.values.fold<int>(
      0,
      (sum, value) => sum + (value?.toString().length ?? 0),
    );
  }

  @override
  Future<PersistenceResult> saveBatch(Map<String, dynamic> data) async {
    _memory.addAll(data);
    return PersistenceResult.success;
  }

  @override
  Future<Map<String, dynamic>> loadBatch(Set<String> keys) async {
    final result = <String, dynamic>{};
    for (final key in keys) {
      if (_memory.containsKey(key)) {
        result[key] = _memory[key];
      }
    }
    return result;
  }

  @override
  Future<PersistenceResult> syncToCloud() async {
    return PersistenceResult.success;
  }

  @override
  Future<PersistenceResult> restoreFromCloud() async {
    return PersistenceResult.success;
  }

  @override
  Future<void> dispose() async {
    _memory.clear();
    _initialized = false;
    debugPrint('MemoryStorageProvider disposed');
  }
}
