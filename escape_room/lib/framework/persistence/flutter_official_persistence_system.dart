import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Flutter公式準拠の永続化システム
///
/// 参考ドキュメント:
/// - https://pub.dev/packages/shared_preferences
/// - https://flutter.dev/docs/cookbook/persistence/key-value
/// - https://api.flutter.dev/flutter/foundation/debugPrint.html
///
/// 設計原則:
/// 1. shared_preferencesパッケージを直接使用
/// 2. 複雑な暗号化・クラウド同期機能を排除
/// 3. シンプルなキー・バリューストレージに特化
/// 4. Flutter公式ドキュメントのベストプラクティスに準拠

/// データ永続化マネージャー
///
/// Flutter公式shared_preferencesパッケージを直接使用
/// 複雑な抽象化レイヤーを排除し、シンプルな実装を重視
class FlutterDataManager {
  SharedPreferences? _prefs;
  bool _initialized = false;
  final Map<String, dynamic> _cache = <String, dynamic>{};
  final bool _debugMode;

  /// Flutter公式推奨: コンストラクタでデバッグモード設定
  FlutterDataManager({bool debugMode = false}) : _debugMode = debugMode;

  /// 初期化
  ///
  /// Flutter公式パターン: SharedPreferences.getInstance()を使用
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

  /// 文字列データ保存
  ///
  /// Flutter公式パターン: SharedPreferences.setStringを直接使用
  Future<bool> saveString(String key, String value) async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _prefs!.setString(key, value);
      if (success) {
        _cache[key] = value;
        if (_debugMode) {
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
  ///
  /// Flutter公式パターン: SharedPreferences.getStringを直接使用
  String? loadString(String key, {String? defaultValue}) {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _prefs!.getString(key) ?? defaultValue;
      if (_debugMode && value != null) {
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

  /// 整数データ保存
  ///
  /// Flutter公式パターン: SharedPreferences.setIntを直接使用
  Future<bool> saveInt(String key, int value) async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _prefs!.setInt(key, value);
      if (success) {
        _cache[key] = value;
        if (_debugMode) {
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
  ///
  /// Flutter公式パターン: SharedPreferences.getIntを直接使用
  int? loadInt(String key, {int? defaultValue}) {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _prefs!.getInt(key) ?? defaultValue;
      if (_debugMode && value != null) {
        debugPrint('📖 Loaded int: $key = $value');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load int $key: $e');
      return defaultValue;
    }
  }

  /// 浮動小数点データ保存
  ///
  /// Flutter公式パターン: SharedPreferences.setDoubleを直接使用
  Future<bool> saveDouble(String key, double value) async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _prefs!.setDouble(key, value);
      if (success) {
        _cache[key] = value;
        if (_debugMode) {
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
  ///
  /// Flutter公式パターン: SharedPreferences.getDoubleを直接使用
  double? loadDouble(String key, {double? defaultValue}) {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _prefs!.getDouble(key) ?? defaultValue;
      if (_debugMode && value != null) {
        debugPrint('📖 Loaded double: $key = $value');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load double $key: $e');
      return defaultValue;
    }
  }

  /// ブール値データ保存
  ///
  /// Flutter公式パターン: SharedPreferences.setBoolを直接使用
  Future<bool> saveBool(String key, bool value) async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _prefs!.setBool(key, value);
      if (success) {
        _cache[key] = value;
        if (_debugMode) {
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
  ///
  /// Flutter公式パターン: SharedPreferences.getBoolを直接使用
  bool? loadBool(String key, {bool? defaultValue}) {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _prefs!.getBool(key) ?? defaultValue;
      if (_debugMode && value != null) {
        debugPrint('📖 Loaded bool: $key = $value');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load bool $key: $e');
      return defaultValue;
    }
  }

  /// 文字列リストデータ保存
  ///
  /// Flutter公式パターン: SharedPreferences.setStringListを直接使用
  Future<bool> saveStringList(String key, List<String> value) async {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    try {
      final success = await _prefs!.setStringList(key, value);
      if (success) {
        _cache[key] = List<String>.from(value);
        if (_debugMode) {
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
  ///
  /// Flutter公式パターン: SharedPreferences.getStringListを直接使用
  List<String>? loadStringList(String key, {List<String>? defaultValue}) {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return defaultValue;
    }

    try {
      final value = _prefs!.getStringList(key) ?? defaultValue;
      if (_debugMode && value != null) {
        debugPrint('📖 Loaded stringList: $key = ${value.length} items');
      }
      return value;
    } catch (e) {
      debugPrint('❌ Failed to load stringList $key: $e');
      return defaultValue;
    }
  }

  /// JSONオブジェクト保存
  ///
  /// Flutter公式推奨: JSONエンコードしてSharedPreferences.setStringで保存
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await saveString(key, jsonString);
    } catch (e) {
      debugPrint('❌ Failed to encode JSON for $key: $e');
      return false;
    }
  }

  /// JSONオブジェクト読み込み
  ///
  /// Flutter公式推奨: SharedPreferencesから文字列を取得してJSONデコード
  Map<String, dynamic>? loadJson(
    String key, {
    Map<String, dynamic>? defaultValue,
  }) {
    try {
      final jsonString = loadString(key);
      if (jsonString == null) return defaultValue;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Failed to decode JSON for $key: $e');
      return defaultValue;
    }
  }

  /// データ削除
  ///
  /// Flutter公式パターン: SharedPreferences.removeを直接使用
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

  /// 全データクリア
  ///
  /// Flutter公式パターン: SharedPreferences.clearを直接使用
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

  /// データ存在確認
  ///
  /// Flutter公式パターン: SharedPreferences.containsKeyを直接使用
  bool containsKey(String key) {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return false;
    }

    return _prefs!.containsKey(key);
  }

  /// 保存済みキー一覧取得
  ///
  /// Flutter公式パターン: SharedPreferences.getKeysを直接使用
  Set<String> getKeys() {
    if (!_initialized) {
      debugPrint('❌ FlutterDataManager not initialized');
      return <String>{};
    }

    return _prefs!.getKeys();
  }

  /// 再読み込み
  ///
  /// Flutter公式パターン: SharedPreferences.reloadを直接使用
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

  /// ゲーム専用メソッド: ハイスコア保存
  ///
  /// Flutter公式準拠: setIntを使用したシンプルな実装
  Future<bool> saveHighScore(int score, {String category = 'default'}) async {
    final key = 'highScore_$category';
    final currentScore = loadInt(key, defaultValue: 0) ?? 0;

    if (score > currentScore) {
      return await saveInt(key, score);
    }

    return true; // より低いスコアでも成功扱い
  }

  /// ゲーム専用メソッド: ハイスコア読み込み
  ///
  /// Flutter公式準拠: getIntを使用したシンプルな実装
  int loadHighScore({String category = 'default'}) {
    return loadInt('highScore_$category', defaultValue: 0) ?? 0;
  }

  /// ゲーム専用メソッド: ユーザー設定保存
  ///
  /// Flutter公式準拠: JSONエンコードして保存
  Future<bool> saveUserSettings(Map<String, dynamic> settings) async {
    return await saveJson('userSettings', settings);
  }

  /// ゲーム専用メソッド: ユーザー設定読み込み
  ///
  /// Flutter公式準拠: JSONデコードして読み込み
  Map<String, dynamic> loadUserSettings() {
    return loadJson('userSettings', defaultValue: <String, dynamic>{}) ??
        <String, dynamic>{};
  }

  /// ゲーム専用メソッド: ゲーム進行状況保存
  ///
  /// Flutter公式準拠: JSONエンコードして保存
  Future<bool> saveGameProgress(Map<String, dynamic> progress) async {
    return await saveJson('gameProgress', progress);
  }

  /// ゲーム専用メソッド: ゲーム進行状況読み込み
  ///
  /// Flutter公式準拠: JSONデコードして読み込み
  Map<String, dynamic> loadGameProgress() {
    return loadJson('gameProgress', defaultValue: <String, dynamic>{}) ??
        <String, dynamic>{};
  }

  /// ゲーム専用メソッド: 統計データ保存
  ///
  /// Flutter公式準拠: JSONエンコードして保存
  Future<bool> saveStatistics(Map<String, dynamic> stats) async {
    return await saveJson('statistics', stats);
  }

  /// ゲーム専用メソッド: 統計データ読み込み
  ///
  /// Flutter公式準拠: JSONデコードして読み込み
  Map<String, dynamic> loadStatistics() {
    return loadJson('statistics', defaultValue: <String, dynamic>{}) ??
        <String, dynamic>{};
  }

  /// デバッグ情報取得
  ///
  /// Flutter公式準拠: SharedPreferencesの情報を直接取得
  Map<String, dynamic> getDebugInfo() {
    return <String, dynamic>{
      'flutter_official_compliant': true, // Flutter公式準拠であることを明示
      'package': 'shared_preferences', // 使用パッケージ
      'initialized': _initialized,
      'debug_mode': _debugMode,
      'total_keys': _initialized ? _prefs!.getKeys().length : 0,
      'cached_items': _cache.length,
      'available_keys': _initialized ? _prefs!.getKeys().toList() : <String>[],
    };
  }
}

/// 後方互換性のためのエイリアス
///
/// 既存コードが引き続き動作するようにするため
typedef DataManager = FlutterDataManager;
