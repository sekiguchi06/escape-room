import 'numeric_operations.dart';
import 'complex_data_operations.dart';

/// ゲーム専用データ操作の専用クラス
class FlutterGameSpecificOperations {
  final FlutterNumericOperations _numericOps;
  final FlutterComplexDataOperations _complexOps;

  FlutterGameSpecificOperations(this._numericOps, this._complexOps);

  /// ハイスコア保存
  Future<bool> saveHighScore(int score, {String category = 'default'}) async {
    final key = 'highScore_$category';
    final currentScore = _numericOps.loadInt(key, defaultValue: 0) ?? 0;

    if (score > currentScore) {
      return await _numericOps.saveInt(key, score);
    }

    return true;
  }

  /// ハイスコア読み込み
  int loadHighScore({String category = 'default'}) {
    return _numericOps.loadInt('highScore_$category', defaultValue: 0) ?? 0;
  }

  /// ユーザー設定保存
  Future<bool> saveUserSettings(Map<String, dynamic> settings) async {
    return await _complexOps.saveJson('userSettings', settings);
  }

  /// ユーザー設定読み込み
  Map<String, dynamic> loadUserSettings() {
    return _complexOps.loadJson(
          'userSettings',
          defaultValue: <String, dynamic>{},
        ) ??
        <String, dynamic>{};
  }

  /// ゲーム進行状況保存
  Future<bool> saveGameProgress(Map<String, dynamic> progress) async {
    return await _complexOps.saveJson('gameProgress', progress);
  }

  /// ゲーム進行状況読み込み
  Map<String, dynamic> loadGameProgress() {
    return _complexOps.loadJson(
          'gameProgress',
          defaultValue: <String, dynamic>{},
        ) ??
        <String, dynamic>{};
  }

  /// 統計データ保存
  Future<bool> saveStatistics(Map<String, dynamic> stats) async {
    return await _complexOps.saveJson('statistics', stats);
  }

  /// 統計データ読み込み
  Map<String, dynamic> loadStatistics() {
    return _complexOps.loadJson(
          'statistics',
          defaultValue: <String, dynamic>{},
        ) ??
        <String, dynamic>{};
  }
}
