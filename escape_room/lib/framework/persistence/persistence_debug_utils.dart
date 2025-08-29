import 'core_persistence_system.dart';

/// 永続化システム用デバッグ・管理ユーティリティ
///
/// Flutter公式推奨: 開発時のみ使用するユーティリティクラス
class PersistenceDebugUtils {
  final CorePersistenceSystem _coreSystem;

  PersistenceDebugUtils(this._coreSystem);

  /// デバッグ情報取得
  ///
  /// Flutter公式準拠: SharedPreferencesの情報を直接取得
  Map<String, dynamic> getDebugInfo() {
    return <String, dynamic>{
      'flutter_official_compliant': true, // Flutter公式準拠であることを明示
      'package': 'shared_preferences', // 使用パッケージ
      'initialized': _coreSystem.isInitialized,
      'total_keys': _coreSystem.isInitialized ? _coreSystem.getKeys().length : 0,
      'available_keys': _coreSystem.isInitialized ? _coreSystem.getKeys().toList() : <String>[],
    };
  }

  /// 全データのダンプ（デバッグ用）
  ///
  /// 注意: 本番環境では使用しないこと
  Map<String, dynamic> dumpAllData() {
    if (!_coreSystem.isInitialized) {
      return <String, dynamic>{'error': 'System not initialized'};
    }

    final result = <String, dynamic>{};
    final keys = _coreSystem.getKeys();

    for (final key in keys) {
      try {
        // 各タイプを試行して値を取得
        final stringValue = _coreSystem.loadString(key);
        if (stringValue != null) {
          result[key] = stringValue;
          continue;
        }

        final intValue = _coreSystem.loadInt(key);
        if (intValue != null) {
          result[key] = intValue;
          continue;
        }

        final boolValue = _coreSystem.loadBool(key);
        if (boolValue != null) {
          result[key] = boolValue;
          continue;
        }

        final doubleValue = _coreSystem.loadDouble(key);
        if (doubleValue != null) {
          result[key] = doubleValue;
          continue;
        }

        final stringListValue = _coreSystem.loadStringList(key);
        if (stringListValue != null) {
          result[key] = stringListValue;
          continue;
        }

        // どのタイプでも取得できない場合は不明として記録
        result[key] = '<unknown_type>';
      } catch (e) {
        result[key] = '<error: $e>';
      }
    }

    return result;
  }

  /// データ検証（デバッグ用）
  ///
  /// SharedPreferencesの整合性をチェック
  Map<String, dynamic> validateData() {
    if (!_coreSystem.isInitialized) {
      return <String, dynamic>{'error': 'System not initialized'};
    }

    final issues = <String>[];
    final keys = _coreSystem.getKeys();

    // 各キーの妥当性をチェック
    for (final key in keys) {
      if (key.isEmpty) {
        issues.add('Empty key found');
      }
      if (key.length > 100) {
        issues.add('Very long key: $key');
      }
      if (!_coreSystem.containsKey(key)) {
        issues.add('Inconsistent key state: $key');
      }
    }

    return <String, dynamic>{
      'total_keys': keys.length,
      'issues_found': issues.length,
      'issues': issues,
      'validation_passed': issues.isEmpty,
    };
  }
}