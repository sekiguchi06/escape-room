import 'core_persistence_system.dart';

/// ゲーム専用永続化拡張システム
///
/// Flutter公式推奨パターン: Composition over Inheritanceを採用
/// コアシステムをラップしてゲーム固有機能を提供
class GamePersistenceExtensions {
  final CorePersistenceSystem _coreSystem;

  GamePersistenceExtensions(this._coreSystem);

  /// ゲーム専用メソッド: ハイスコア保存
  ///
  /// Flutter公式準拠: setIntを使用したシンプルな実装
  Future<bool> saveHighScore(int score, {String category = 'default'}) async {
    final key = 'highScore_$category';
    final currentScore = _coreSystem.loadInt(key, defaultValue: 0) ?? 0;

    if (score > currentScore) {
      return await _coreSystem.saveInt(key, score);
    }

    return true; // より低いスコアでも成功扱い
  }

  /// ゲーム専用メソッド: ハイスコア読み込み
  ///
  /// Flutter公式準拠: getIntを使用したシンプルな実装
  int loadHighScore({String category = 'default'}) {
    return _coreSystem.loadInt('highScore_$category', defaultValue: 0) ?? 0;
  }

  /// ゲーム専用メソッド: ユーザー設定保存
  ///
  /// Flutter公式準拠: JSONエンコードして保存
  Future<bool> saveUserSettings(Map<String, dynamic> settings) async {
    return await _coreSystem.saveJson('userSettings', settings);
  }

  /// ゲーム専用メソッド: ユーザー設定読み込み
  ///
  /// Flutter公式準拠: JSONデコードして読み込み
  Map<String, dynamic> loadUserSettings() {
    return _coreSystem.loadJson('userSettings', defaultValue: <String, dynamic>{}) ??
        <String, dynamic>{};
  }

  /// ゲーム専用メソッド: ゲーム進行状況保存
  ///
  /// Flutter公式準拠: JSONエンコードして保存
  Future<bool> saveGameProgress(Map<String, dynamic> progress) async {
    return await _coreSystem.saveJson('gameProgress', progress);
  }

  /// ゲーム専用メソッド: ゲーム進行状況読み込み
  ///
  /// Flutter公式準拠: JSONデコードして読み込み
  Map<String, dynamic> loadGameProgress() {
    return _coreSystem.loadJson('gameProgress', defaultValue: <String, dynamic>{}) ??
        <String, dynamic>{};
  }

  /// ゲーム専用メソッド: 統計データ保存
  ///
  /// Flutter公式準拠: JSONエンコードして保存
  Future<bool> saveStatistics(Map<String, dynamic> stats) async {
    return await _coreSystem.saveJson('statistics', stats);
  }

  /// ゲーム専用メソッド: 統計データ読み込み
  ///
  /// Flutter公式準拠: JSONデコードして読み込み
  Map<String, dynamic> loadStatistics() {
    return _coreSystem.loadJson('statistics', defaultValue: <String, dynamic>{}) ??
        <String, dynamic>{};
  }
}