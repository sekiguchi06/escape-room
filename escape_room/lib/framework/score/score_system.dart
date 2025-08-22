import 'package:flutter/foundation.dart';
import 'package:flame/components.dart';

/// スコア設定の基底クラス
abstract class ScoreConfiguration {
  /// ハイスコア最大保存数
  int get maxHighScores;

  /// スコア計算式の設定
  Map<String, dynamic> get scoreMultipliers;

  /// リーダーボード設定
  Map<String, dynamic> get leaderboardConfig;

  /// スコア表示形式
  String get scoreFormat;

  /// デバッグモード
  bool get debugMode;
}

/// デフォルトスコア設定
class DefaultScoreConfiguration implements ScoreConfiguration {
  @override
  final int maxHighScores;

  @override
  final Map<String, dynamic> scoreMultipliers;

  @override
  final Map<String, dynamic> leaderboardConfig;

  @override
  final String scoreFormat;

  @override
  final bool debugMode;

  const DefaultScoreConfiguration({
    this.maxHighScores = 10,
    this.scoreMultipliers = const {'tap': 10, 'combo': 2.0, 'timeBonus': 1.5},
    this.leaderboardConfig = const {
      'enabled': true,
      'categories': ['total', 'daily', 'weekly'],
    },
    this.scoreFormat = '#,##0',
    this.debugMode = false,
  });
}

/// スコアプロバイダーのインターフェース
/// Flame公式パターン準拠のプロバイダーパターン実装
abstract class ScoreProvider {
  Future<bool> initialize(ScoreConfiguration config);

  /// 現在のスコアを取得
  int getCurrentScore();

  /// スコアを追加
  void addScore(int points, {String? category});

  /// スコアを設定
  void setScore(int score);

  /// スコアをリセット
  void resetScore();

  /// ハイスコア一覧を取得
  Future<List<ScoreEntry>> getHighScores({String? category});

  /// ハイスコアを保存
  Future<void> saveHighScore(int score, {String? playerName, String? category});

  /// リーダーボードへ送信
  Future<bool> submitToLeaderboard(int score, {String? category});

  /// コンボ倍率を適用
  int applyComboMultiplier(int baseScore, int comboCount);

  /// ボーナススコアを計算
  int calculateBonus(Map<String, dynamic> bonusData);

  /// リソースを解放
  void dispose();
}

/// スコアエントリークラス
class ScoreEntry {
  final int score;
  final DateTime timestamp;
  final String? playerName;
  final String? category;
  final Map<String, dynamic>? metadata;

  const ScoreEntry({
    required this.score,
    required this.timestamp,
    this.playerName,
    this.category,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'timestamp': timestamp.toIso8601String(),
    'playerName': playerName,
    'category': category,
    'metadata': metadata,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    score: json['score'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
    playerName: json['playerName'] as String?,
    category: json['category'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
}

/// スコア管理マネージャー
/// Flame公式Component準拠の実装
class ScoreManager extends Component {
  ScoreProvider? _provider;
  ScoreConfiguration? _config;
  bool _initialized = false;

  int _currentScore = 0;
  int _comboCount = 0;
  List<ScoreEntry> _highScores = [];

  /// 初期化
  Future<bool> initialize({
    ScoreProvider? provider,
    ScoreConfiguration? config,
  }) async {
    try {
      _config = config ?? const DefaultScoreConfiguration();

      // プロバイダーの設定（後で実装予定）
      _provider = provider;

      if (_provider != null) {
        final success = await _provider!.initialize(_config!);
        if (!success) {
          debugPrint(
            '⚠️ ScoreProvider initialization failed, using local mode',
          );
        }
      }

      _initialized = true;
      if (_config!.debugMode) {
        debugPrint('🎯 ScoreManager initialized');
      }
      return true;
    } catch (e) {
      debugPrint('❌ ScoreManager initialization failed: $e');
      _initialized = true; // フェイルセーフで継続
      return true;
    }
  }

  /// 現在のスコア
  int get currentScore => _currentScore;

  /// コンボ数
  int get comboCount => _comboCount;

  /// ハイスコア一覧
  List<ScoreEntry> get highScores => List.unmodifiable(_highScores);

  /// スコアを追加
  void addScore(int points, {String? category}) {
    if (!_initialized) return;

    final multiplier = _config?.scoreMultipliers['tap'] as int? ?? 10;
    final actualPoints = points * multiplier;

    _currentScore += actualPoints;
    _comboCount++;

    if (_config?.debugMode == true) {
      debugPrint(
        '🎯 Score added: +$actualPoints (total: $_currentScore, combo: $_comboCount)',
      );
    }

    _provider?.addScore(actualPoints, category: category);
  }

  /// コンボボーナスを適用
  int applyComboBonus(int baseScore) {
    if (_comboCount <= 1) return baseScore;

    final comboMultiplier =
        _config?.scoreMultipliers['combo'] as double? ?? 2.0;
    final bonus = (baseScore * (comboMultiplier * (_comboCount - 1))).round();

    if (_config?.debugMode == true) {
      debugPrint(
        '🎯 Combo bonus applied: x${comboMultiplier.toStringAsFixed(1)} (combo: $_comboCount)',
      );
    }

    return baseScore + bonus;
  }

  /// スコアをリセット
  void resetScore() {
    _currentScore = 0;
    _comboCount = 0;
    _provider?.resetScore();

    if (_config?.debugMode == true) {
      debugPrint('🎯 Score reset');
    }
  }

  /// ハイスコアを保存
  Future<bool> saveHighScore({String? playerName, String? category}) async {
    if (!_initialized || _currentScore == 0) return false;

    try {
      final entry = ScoreEntry(
        score: _currentScore,
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

      await _provider?.saveHighScore(
        _currentScore,
        playerName: playerName,
        category: category,
      );

      if (_config?.debugMode == true) {
        debugPrint('🎯 High score saved: $_currentScore');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Failed to save high score: $e');
      return false;
    }
  }

  /// リーダーボードに送信
  Future<bool> submitToLeaderboard({String? category}) async {
    if (!_initialized || _currentScore == 0) return false;

    try {
      final success =
          await _provider?.submitToLeaderboard(
            _currentScore,
            category: category,
          ) ??
          false;

      if (_config?.debugMode == true) {
        debugPrint(
          '🎯 Leaderboard submission: ${success ? 'success' : 'failed'}',
        );
      }

      return success;
    } catch (e) {
      debugPrint('❌ Failed to submit to leaderboard: $e');
      return false;
    }
  }

  /// フォーマット済みスコア文字列を取得
  String getFormattedScore([int? score]) {
    final targetScore = score ?? _currentScore;
    // Using simple comma formatting (format config available but not used in simple implementation)

    // 簡易フォーマット実装
    return targetScore.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  void onRemove() {
    _provider?.dispose();
    super.onRemove();
  }
}
