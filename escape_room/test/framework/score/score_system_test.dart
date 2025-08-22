import 'package:flutter_test/flutter_test.dart';

import 'package:escape_room/framework/score/score_system.dart';

void main() {
  group('ScoreSystem Tests', () {
    group('ScoreEntry', () {
      test('should create ScoreEntry correctly', () {
        final entry = ScoreEntry(
          score: 1000,
          timestamp: DateTime(2025, 8, 8),
          playerName: 'TestPlayer',
          category: 'test',
        );

        expect(entry.score, 1000);
        expect(entry.playerName, 'TestPlayer');
        expect(entry.category, 'test');
      });

      test('should convert to/from JSON correctly', () {
        final entry = ScoreEntry(
          score: 500,
          timestamp: DateTime(2025, 8, 8),
          playerName: 'Player1',
        );

        final json = entry.toJson();
        final restored = ScoreEntry.fromJson(json);

        expect(restored.score, entry.score);
        expect(restored.playerName, entry.playerName);
        expect(restored.timestamp, entry.timestamp);
      });
    });

    group('DefaultScoreConfiguration', () {
      test('should have correct default values', () {
        const config = DefaultScoreConfiguration();

        expect(config.maxHighScores, 10);
        expect(config.scoreMultipliers['tap'], 10);
        expect(config.scoreFormat, '#,##0');
        expect(config.debugMode, false);
      });
    });

    group('ScoreManager', () {
      late ScoreManager scoreManager;

      setUp(() {
        scoreManager = ScoreManager();
      });

      test('should initialize correctly', () async {
        final success = await scoreManager.initialize();
        expect(success, true);
        expect(scoreManager.currentScore, 0);
        expect(scoreManager.comboCount, 0);
      });

      test('should add score correctly', () async {
        await scoreManager.initialize();

        scoreManager.addScore(100);
        expect(
          scoreManager.currentScore,
          1000,
        ); // 100 * 10 (default multiplier)
        expect(scoreManager.comboCount, 1);
      });

      test('should apply combo bonus', () async {
        await scoreManager.initialize();

        // Add multiple scores to build combo
        scoreManager.addScore(100); // 1000 points, combo = 1
        final bonus1 = scoreManager.applyComboBonus(100);
        expect(bonus1, 100); // No bonus for combo 1

        scoreManager.addScore(100); // 1000 more points, combo = 2
        final bonus2 = scoreManager.applyComboBonus(100);
        expect(bonus2, 300); // 100 + (100 * 2.0 * (2-1)) = 300
      });

      test('should reset score correctly', () async {
        await scoreManager.initialize();

        scoreManager.addScore(100);
        expect(scoreManager.currentScore, 1000);
        expect(scoreManager.comboCount, 1);

        scoreManager.resetScore();
        expect(scoreManager.currentScore, 0);
        expect(scoreManager.comboCount, 0);
      });

      test('should format score correctly', () async {
        await scoreManager.initialize();

        scoreManager.addScore(1234);
        final formatted = scoreManager.getFormattedScore();
        expect(formatted.contains(','), true);
      });
    });
  });
}
