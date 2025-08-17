import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../score_system.dart';

/// ローカルストレージベースのスコアプロバイダー
/// SharedPreferences を使用してスコアをローカル保存
class LocalScoreProvider implements ScoreProvider {
  SharedPreferences? _prefs;
  ScoreConfiguration? _config;
  // _initialized removed - initialization state tracked through _prefs nullability
  bool _mockMode = false;
  
  int _currentScore = 0;
  List<ScoreEntry> _highScores = [];
  
  static const String _keyCurrentScore = 'score_current';
  static const String _keyHighScores = 'score_high_scores';
  // _keyPrefix removed - not currently used in implementation
  
  @override
  Future<bool> initialize(ScoreConfiguration config) async {
    try {
      _config = config;
      
      if (kIsWeb) {
        // Web環境では制限されたSharedPreferences機能を使用
        _prefs = await SharedPreferences.getInstance();
      } else {
        _prefs = await SharedPreferences.getInstance();
      }
      
      // 既存のハイスコアを読み込み
      await _loadHighScores();
      
      // Initialization complete (tracked through _prefs)
      
      if (_config?.debugMode == true) {
        debugPrint('🎯 LocalScoreProvider initialized (${_highScores.length} high scores loaded)');
      }
      
      return true;
    } catch (e) {
      debugPrint('⚠️ LocalScoreProvider initialization failed, using mock mode: $e');
      _mockMode = true;
      // Initialization complete (tracked through _prefs)
      return true; // Mock モードで継続
    }
  }
  
  @override
  int getCurrentScore() {
    return _currentScore;
  }
  
  @override
  void addScore(int points, {String? category}) {
    _currentScore += points;
    
    if (_config?.debugMode == true) {
      debugPrint('🎯 Score added: +$points (total: $_currentScore)');
    }
    
    // 必要に応じて永続化
    _saveCurrentScore();
  }
  
  @override
  void setScore(int score) {
    _currentScore = score;
    _saveCurrentScore();
    
    if (_config?.debugMode == true) {
      debugPrint('🎯 Score set: $_currentScore');
    }
  }
  
  @override
  void resetScore() {
    _currentScore = 0;
    _saveCurrentScore();
    
    if (_config?.debugMode == true) {
      debugPrint('🎯 Score reset');
    }
  }
  
  @override
  Future<List<ScoreEntry>> getHighScores({String? category}) async {
    if (category != null) {
      return _highScores.where((entry) => entry.category == category).toList();
    }
    return List.unmodifiable(_highScores);
  }
  
  @override
  Future<void> saveHighScore(int score, {String? playerName, String? category}) async {
    final entry = ScoreEntry(
      score: score,
      timestamp: DateTime.now(),
      playerName: playerName,
      category: category,
    );
    
    _highScores.add(entry);
    _highScores.sort((a, b) => b.score.compareTo(a.score));
    
    final maxScores = _config?.maxHighScores ?? 10;
    if (_highScores.length > maxScores) {
      _highScores = _highScores.take(maxScores).toList();
    }
    
    await _persistHighScores();
    
    if (_config?.debugMode == true) {
      debugPrint('🎯 High score saved: $score (${_highScores.length} total)');
    }
  }
  
  @override
  Future<bool> submitToLeaderboard(int score, {String? category}) async {
    if (_mockMode) {
      if (_config?.debugMode == true) {
        debugPrint('🔧 [MOCK] Leaderboard submission: $score');
      }
      return true;
    }
    
    // 実装予定：外部リーダーボードサービス連携
    // Game Center, Google Play Games等
    
    if (_config?.debugMode == true) {
      debugPrint('🎯 Leaderboard submission not implemented, using local storage');
    }
    
    return true;
  }
  
  @override
  int applyComboMultiplier(int baseScore, int comboCount) {
    if (comboCount <= 1) return baseScore;
    
    final multiplier = _config?.scoreMultipliers['combo'] as double? ?? 2.0;
    final bonus = (baseScore * multiplier * (comboCount - 1)).round();
    return baseScore + bonus;
  }
  
  @override
  int calculateBonus(Map<String, dynamic> bonusData) {
    int totalBonus = 0;
    
    // 時間ボーナス
    if (bonusData.containsKey('timeRemaining')) {
      final timeBonus = bonusData['timeRemaining'] as double? ?? 0.0;
      final timeMultiplier = _config?.scoreMultipliers['timeBonus'] as double? ?? 1.5;
      totalBonus += (timeBonus * timeMultiplier).round();
    }
    
    // 完了ボーナス
    if (bonusData['completed'] == true) {
      final completionBonus = bonusData['completionBonus'] as int? ?? 100;
      totalBonus += completionBonus;
    }
    
    // 精度ボーナス
    if (bonusData.containsKey('accuracy')) {
      final accuracy = bonusData['accuracy'] as double? ?? 0.0;
      if (accuracy >= 0.9) {
        totalBonus += (100 * accuracy).round();
      }
    }
    
    return totalBonus;
  }
  
  @override
  void dispose() {
    _prefs = null;
    // Disposal complete (tracked through _prefs)
  }
  
  /// 現在のスコアを保存
  Future<void> _saveCurrentScore() async {
    if (_mockMode || _prefs == null) return;
    
    try {
      await _prefs!.setInt(_keyCurrentScore, _currentScore);
    } catch (e) {
      debugPrint('⚠️ Failed to save current score: $e');
    }
  }
  
  /// ハイスコアを永続化
  Future<void> _persistHighScores() async {
    if (_mockMode || _prefs == null) return;
    
    try {
      final jsonList = _highScores.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs!.setString(_keyHighScores, jsonString);
    } catch (e) {
      debugPrint('⚠️ Failed to persist high scores: $e');
    }
  }
  
  /// ハイスコアを読み込み
  Future<void> _loadHighScores() async {
    if (_mockMode || _prefs == null) return;
    
    try {
      // 現在のスコアを復元
      _currentScore = _prefs!.getInt(_keyCurrentScore) ?? 0;
      
      // ハイスコア一覧を復元
      final jsonString = _prefs!.getString(_keyHighScores);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        _highScores = jsonList
            .cast<Map<String, dynamic>>()
            .map((json) => ScoreEntry.fromJson(json))
            .toList();
        
        // 念のためソート
        _highScores.sort((a, b) => b.score.compareTo(a.score));
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load high scores, starting fresh: $e');
      _highScores = [];
      _currentScore = 0;
    }
  }
}

/// MockScoreProvider
/// テスト・開発時用のモックプロバイダー
class MockScoreProvider implements ScoreProvider {
  ScoreConfiguration? _config;
  int _currentScore = 0;
  final List<ScoreEntry> _highScores = [];
  
  @override
  Future<bool> initialize(ScoreConfiguration config) async {
    _config = config;
    
    if (_config?.debugMode == true) {
      debugPrint('🔧 MockScoreProvider initialized');
    }
    
    return true;
  }
  
  @override
  int getCurrentScore() => _currentScore;
  
  @override
  void addScore(int points, {String? category}) {
    _currentScore += points;
    
    if (_config?.debugMode == true) {
      debugPrint('🔧 [MOCK] Score added: +$points (total: $_currentScore)');
    }
  }
  
  @override
  void setScore(int score) {
    _currentScore = score;
    
    if (_config?.debugMode == true) {
      debugPrint('🔧 [MOCK] Score set: $_currentScore');
    }
  }
  
  @override
  void resetScore() {
    _currentScore = 0;
    
    if (_config?.debugMode == true) {
      debugPrint('🔧 [MOCK] Score reset');
    }
  }
  
  @override
  Future<List<ScoreEntry>> getHighScores({String? category}) async {
    return List.unmodifiable(_highScores);
  }
  
  @override
  Future<void> saveHighScore(int score, {String? playerName, String? category}) async {
    final entry = ScoreEntry(
      score: score,
      timestamp: DateTime.now(),
      playerName: playerName,
      category: category,
    );
    
    _highScores.add(entry);
    _highScores.sort((a, b) => b.score.compareTo(a.score));
    
    if (_config?.debugMode == true) {
      debugPrint('🔧 [MOCK] High score saved: $score');
    }
  }
  
  @override
  Future<bool> submitToLeaderboard(int score, {String? category}) async {
    if (_config?.debugMode == true) {
      debugPrint('🔧 [MOCK] Leaderboard submission: $score');
    }
    return true;
  }
  
  @override
  int applyComboMultiplier(int baseScore, int comboCount) {
    return baseScore * comboCount;
  }
  
  @override
  int calculateBonus(Map<String, dynamic> bonusData) {
    return bonusData['bonus'] as int? ?? 0;
  }
  
  @override
  void dispose() {
    // Mock なのでクリーンアップなし
  }
}