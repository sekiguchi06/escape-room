import 'package:flutter/foundation.dart';
import '../persistence/persistence_system.dart';

/// ゲーム進行度データモデル
class GameProgress {
  final String gameId;
  final int currentLevel;
  final Map<String, dynamic> gameData;
  final DateTime lastPlayed;
  final double completionRate;
  final Map<String, bool> achievementsUnlocked;
  final int playTimeSeconds;
  final Map<String, int> statistics;

  const GameProgress({
    required this.gameId,
    this.currentLevel = 1,
    this.gameData = const {},
    required this.lastPlayed,
    this.completionRate = 0.0,
    this.achievementsUnlocked = const {},
    this.playTimeSeconds = 0,
    this.statistics = const {},
  });

  /// JSONからGameProgressを作成
  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      gameId: json['gameId'] ?? '',
      currentLevel: json['currentLevel'] ?? 1,
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      lastPlayed: DateTime.parse(json['lastPlayed'] ?? DateTime.now().toIso8601String()),
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      achievementsUnlocked: Map<String, bool>.from(json['achievementsUnlocked'] ?? {}),
      playTimeSeconds: json['playTimeSeconds'] ?? 0,
      statistics: Map<String, int>.from(json['statistics'] ?? {}),
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'currentLevel': currentLevel,
      'gameData': gameData,
      'lastPlayed': lastPlayed.toIso8601String(),
      'completionRate': completionRate,
      'achievementsUnlocked': achievementsUnlocked,
      'playTimeSeconds': playTimeSeconds,
      'statistics': statistics,
    };
  }

  /// 進行度をコピーして一部更新
  GameProgress copyWith({
    String? gameId,
    int? currentLevel,
    Map<String, dynamic>? gameData,
    DateTime? lastPlayed,
    double? completionRate,
    Map<String, bool>? achievementsUnlocked,
    int? playTimeSeconds,
    Map<String, int>? statistics,
  }) {
    return GameProgress(
      gameId: gameId ?? this.gameId,
      currentLevel: currentLevel ?? this.currentLevel,
      gameData: gameData ?? Map.from(this.gameData),
      lastPlayed: lastPlayed ?? this.lastPlayed,
      completionRate: completionRate ?? this.completionRate,
      achievementsUnlocked: achievementsUnlocked ?? Map.from(this.achievementsUnlocked),
      playTimeSeconds: playTimeSeconds ?? this.playTimeSeconds,
      statistics: statistics ?? Map.from(this.statistics),
    );
  }

  /// 進行度が有効かチェック
  bool get isValid => gameId.isNotEmpty && currentLevel > 0;

  /// 特定のデータを取得
  T? getData<T>(String key, {T? defaultValue}) {
    return gameData[key] as T? ?? defaultValue;
  }

  /// 統計データを取得
  int getStatistic(String key, {int defaultValue = 0}) {
    return statistics[key] ?? defaultValue;
  }

  /// アチーブメントの取得状況
  bool hasAchievement(String achievementId) {
    return achievementsUnlocked[achievementId] ?? false;
  }

  @override
  String toString() {
    return 'GameProgress(gameId: $gameId, level: $currentLevel, completion: ${(completionRate * 100).toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameProgress &&
        other.gameId == gameId &&
        other.currentLevel == currentLevel &&
        mapEquals(other.gameData, gameData) &&
        other.lastPlayed == lastPlayed &&
        other.completionRate == completionRate;
  }

  @override
  int get hashCode {
    return gameId.hashCode ^
        currentLevel.hashCode ^
        gameData.hashCode ^
        lastPlayed.hashCode ^
        completionRate.hashCode;
  }
}

/// 進行度管理マネージャー
class GameProgressManager extends ChangeNotifier {
  final DataManager _dataManager;
  GameProgress? _currentProgress;
  final String _storageKey = 'current_game_progress';
  
  GameProgressManager(this._dataManager);

  /// 現在の進行度
  GameProgress? get currentProgress => _currentProgress;

  /// 進行度が存在するか
  bool get hasProgress => _currentProgress?.isValid == true;

  /// 初期化
  Future<void> initialize() async {
    await _loadProgress();
  }

  /// 新しいゲームを開始
  Future<void> startNewGame(String gameId) async {
    _currentProgress = GameProgress(
      gameId: gameId,
      currentLevel: 1,
      lastPlayed: DateTime.now(),
      gameData: {},
    );
    
    await _saveProgress();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('Started new game: $gameId');
    }
  }

  /// 進行度を更新
  Future<void> updateProgress({
    int? currentLevel,
    Map<String, dynamic>? gameDataUpdate,
    double? completionRate,
    Map<String, bool>? newAchievements,
    Map<String, int>? statisticsUpdate,
  }) async {
    if (_currentProgress == null) return;

    // ゲームデータの更新
    final updatedGameData = Map<String, dynamic>.from(_currentProgress!.gameData);
    if (gameDataUpdate != null) {
      updatedGameData.addAll(gameDataUpdate);
    }

    // 統計データの更新
    final updatedStatistics = Map<String, int>.from(_currentProgress!.statistics);
    if (statisticsUpdate != null) {
      for (final entry in statisticsUpdate.entries) {
        updatedStatistics[entry.key] = (updatedStatistics[entry.key] ?? 0) + entry.value;
      }
    }

    // アチーブメントの更新
    final updatedAchievements = Map<String, bool>.from(_currentProgress!.achievementsUnlocked);
    if (newAchievements != null) {
      updatedAchievements.addAll(newAchievements);
    }

    _currentProgress = _currentProgress!.copyWith(
      currentLevel: currentLevel,
      gameData: updatedGameData,
      lastPlayed: DateTime.now(),
      completionRate: completionRate,
      achievementsUnlocked: updatedAchievements,
      statistics: updatedStatistics,
    );

    await _saveProgress();
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('Progress updated: ${_currentProgress.toString()}');
    }
  }

  /// レベルを進める
  Future<void> advanceLevel() async {
    if (_currentProgress == null) return;
    
    await updateProgress(
      currentLevel: _currentProgress!.currentLevel + 1,
      statisticsUpdate: {'levels_completed': 1},
    );
  }

  /// プレイ時間を記録
  Future<void> recordPlayTime(int seconds) async {
    if (_currentProgress == null) return;
    
    _currentProgress = _currentProgress!.copyWith(
      playTimeSeconds: _currentProgress!.playTimeSeconds + seconds,
      lastPlayed: DateTime.now(),
    );
    
    await _saveProgress();
    notifyListeners();
  }

  /// 特定のレベルに設定
  Future<void> setLevel(int level) async {
    if (_currentProgress == null || level < 1) return;
    
    await updateProgress(currentLevel: level);
  }

  /// 現在のレベルをリトライ（データは保持）
  Future<void> retryCurrentLevel() async {
    if (_currentProgress == null) return;
    
    // レベル固有のデータをクリア（必要に応じてカスタマイズ）
    final clearedData = Map<String, dynamic>.from(_currentProgress!.gameData);
    clearedData.removeWhere((key, value) => key.startsWith('level_${_currentProgress!.currentLevel}_'));
    
    await updateProgress(
      gameDataUpdate: clearedData,
      statisticsUpdate: {'level_retries': 1},
    );
  }

  /// 進行度をリセット
  Future<void> resetProgress() async {
    await _dataManager.deleteData(_storageKey);
    _currentProgress = null;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('Progress reset');
    }
  }

  /// 手動保存
  Future<void> saveProgress() async {
    await _saveProgress();
  }

  /// 進行度の読み込み
  Future<void> _loadProgress() async {
    try {
      final progressData = await _dataManager.loadGameProgress();
      if (progressData.isNotEmpty) {
        _currentProgress = GameProgress.fromJson(progressData);
        notifyListeners();
        
        if (kDebugMode) {
          debugPrint('Progress loaded: ${_currentProgress.toString()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load progress: $e');
      }
    }
  }

  /// 進行度の保存
  Future<void> _saveProgress() async {
    if (_currentProgress == null) return;
    
    try {
      await _dataManager.saveGameProgress(_currentProgress!.toJson());
      
      if (kDebugMode) {
        debugPrint('Progress saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save progress: $e');
      }
    }
  }

  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'hasProgress': hasProgress,
      'currentProgress': _currentProgress?.toJson(),
      'storageKey': _storageKey,
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// 進行度管理のユーティリティ
class GameProgressUtils {
  /// 完了率を計算
  static double calculateCompletionRate(int currentLevel, int totalLevels) {
    if (totalLevels <= 0) return 0.0;
    return (currentLevel / totalLevels).clamp(0.0, 1.0);
  }

  /// プレイ時間を時間:分:秒形式に変換
  static String formatPlayTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  /// レベル名を生成
  static String getLevelName(int level, {String prefix = 'Level'}) {
    return '$prefix $level';
  }

  /// 進行度の妥当性チェック
  static bool validateProgress(GameProgress progress) {
    return progress.isValid &&
           progress.completionRate >= 0.0 &&
           progress.completionRate <= 1.0 &&
           progress.currentLevel > 0 &&
           progress.playTimeSeconds >= 0;
  }
}