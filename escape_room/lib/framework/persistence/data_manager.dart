import 'package:flutter/foundation.dart';
import 'persistence_configuration.dart';
import 'storage_providers.dart';

/// データマネージャー
class DataManager {
  StorageProvider _provider;
  PersistenceConfiguration _configuration;
  DateTime _lastAutoSave = DateTime.now();
  final Map<String, dynamic> _pendingChanges = {};
  
  static DataManager? _defaultInstance;
  
  DataManager({
    required StorageProvider provider,
    required PersistenceConfiguration configuration,
  }) : _provider = provider, _configuration = configuration;

  /// デフォルトインスタンスを取得（シングルトン）
  static DataManager defaultInstance() {
    _defaultInstance ??= DataManager(
      provider: LocalStorageProvider(),
      configuration: DefaultPersistenceConfiguration(),
    );
    return _defaultInstance!;
  }
  
  /// 現在のプロバイダー
  StorageProvider get provider => _provider;
  
  /// 現在の設定
  PersistenceConfiguration get configuration => _configuration;
  
  /// 初期化
  Future<PersistenceResult> initialize() async {
    return await _provider.initialize(_configuration);
  }
  
  /// プロバイダー変更
  Future<void> setProvider(StorageProvider newProvider) async {
    await _provider.dispose();
    _provider = newProvider;
    await _provider.initialize(_configuration);
  }
  
  /// 設定更新
  Future<void> updateConfiguration(PersistenceConfiguration newConfiguration) async {
    _configuration = newConfiguration;
    await _provider.initialize(_configuration);
  }
  
  /// データ保存
  Future<PersistenceResult> saveData(String key, dynamic value) async {
    final result = await _provider.save(key, value);
    
    if (result == PersistenceResult.success) {
      _pendingChanges[key] = value;
    }
    
    return result;
  }
  
  /// データ読み込み
  Future<T?> loadData<T>(String key, {T? defaultValue}) async {
    return await _provider.load<T>(key, defaultValue: defaultValue);
  }
  
  /// データ削除
  Future<PersistenceResult> deleteData(String key) async {
    final result = await _provider.delete(key);
    
    if (result == PersistenceResult.success) {
      _pendingChanges.remove(key);
    }
    
    return result;
  }
  
  /// 全データクリア
  Future<PersistenceResult> clearAllData() async {
    final result = await _provider.clear();
    
    if (result == PersistenceResult.success) {
      _pendingChanges.clear();
    }
    
    return result;
  }
  
  /// ハイスコア保存
  Future<PersistenceResult> saveHighScore(int score, {String category = 'default'}) async {
    final key = 'highScore_$category';
    final currentScore = await loadData<int>(key, defaultValue: 0) ?? 0;
    
    if (score > currentScore) {
      return await saveData(key, score);
    }
    
    return PersistenceResult.success;
  }
  
  /// ハイスコア読み込み
  Future<int> loadHighScore({String category = 'default'}) async {
    return await loadData<int>('highScore_$category', defaultValue: 0) ?? 0;
  }
  
  /// ユーザー設定保存
  Future<PersistenceResult> saveUserSettings(Map<String, dynamic> settings) async {
    return await saveData('userSettings', settings);
  }
  
  /// ユーザー設定読み込み
  Future<Map<String, dynamic>> loadUserSettings() async {
    return await loadData<Map<String, dynamic>>('userSettings', defaultValue: {}) ?? {};
  }
  
  /// ゲーム進行状況保存
  Future<PersistenceResult> saveGameProgress(Map<String, dynamic> progress) async {
    return await saveData('gameProgress', progress);
  }
  
  /// ゲーム進行状況読み込み
  Future<Map<String, dynamic>> loadGameProgress() async {
    return await loadData<Map<String, dynamic>>('gameProgress', defaultValue: {}) ?? {};
  }
  
  /// 統計データ保存
  Future<PersistenceResult> saveStatistics(Map<String, dynamic> stats) async {
    return await saveData('statistics', stats);
  }
  
  /// 統計データ読み込み
  Future<Map<String, dynamic>> loadStatistics() async {
    return await loadData<Map<String, dynamic>>('statistics', defaultValue: {}) ?? {};
  }
  
  /// 自動保存チェック
  void checkAutoSave() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastAutoSave).inSeconds;
    
    if (elapsed >= _configuration.autoSaveInterval && _pendingChanges.isNotEmpty) {
      performAutoSave();
    }
  }
  
  /// 自動保存実行
  Future<void> performAutoSave() async {
    if (_pendingChanges.isEmpty) return;
    
    try {
      await _provider.saveBatch(Map.from(_pendingChanges));
      _pendingChanges.clear();
      _lastAutoSave = DateTime.now();
      
      if (_configuration.debugMode) {
        debugPrint('Auto save completed');
      }
    } catch (e) {
      debugPrint('Auto save failed: $e');
    }
  }
  
  /// クラウド同期
  Future<PersistenceResult> syncToCloud() async {
    await performAutoSave();  // 同期前に保留中の変更を保存
    return await _provider.syncToCloud();
  }
  
  /// クラウドから復元
  Future<PersistenceResult> restoreFromCloud() async {
    return await _provider.restoreFromCloud();
  }
  
  /// データ存在チェック
  Future<bool> dataExists(String key) async {
    return await _provider.exists(key);
  }
  
  /// ストレージ情報取得
  Future<Map<String, dynamic>> getStorageInfo() async {
    final keys = await _provider.getAllKeys();
    final totalSize = await _provider.getTotalStorageSize();
    
    return {
      'total_keys': keys.length,
      'total_size_bytes': totalSize,
      'total_size_kb': (totalSize / 1024).toStringAsFixed(2),
      'tracked_keys': _configuration.trackedKeys.toList(),
      'pending_changes': _pendingChanges.length,
    };
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'manager': runtimeType.toString(),
      'provider': _provider.runtimeType.toString(),
      'auto_save_interval': _configuration.autoSaveInterval,
      'encryption_enabled': _configuration.encryptionEnabled,
      'cloud_sync_enabled': _configuration.cloudSyncEnabled,
      'data_version': _configuration.dataVersion,
      'pending_changes_count': _pendingChanges.length,
      'last_auto_save': _lastAutoSave.toIso8601String(),
    };
  }
  
  /// リソース解放
  Future<void> dispose() async {
    await performAutoSave();  // 解放前に保留中の変更を保存
    await _provider.dispose();
  }
}