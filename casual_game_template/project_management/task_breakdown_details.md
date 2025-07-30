# タスク詳細分割・実装ガイド

## 🎯 AIエージェント向け実装指示書

この文書は、今後のAIエージェントが作業を間違えずに進められるよう、各タスクの詳細な実装方法を記載します。

## 📋 Phase 1: 実プロバイダー実装

### Task 1.1: GoogleAdProvider実装

#### ファイル構成
```
lib/framework/monetization/providers/
├── google_ad_provider.dart          # メイン実装
├── google_ad_configuration.dart     # 設定クラス
└── google_ad_test_helper.dart       # テスト支援
```

#### 実装テンプレート
```dart
// google_ad_provider.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdProvider implements AdProvider {
  // テストID（本番では実IDに変更）
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  
  @override
  Future<void> initialize(MonetizationConfiguration config) async {
    await MobileAds.instance.initialize();
    // 設定に基づくテストモード切り替え
  }
  
  @override
  Future<AdResult> loadAd(AdType adType) async {
    // 広告タイプ別の読み込み処理
    switch (adType) {
      case AdType.banner:
        return _loadBannerAd();
      case AdType.interstitial:
        return _loadInterstitialAd();
      case AdType.rewarded:
        return _loadRewardedAd();
    }
  }
}
```

#### 必須実装項目
1. **初期化処理**: MobileAds.instance.initialize()
2. **広告読み込み**: 各広告タイプの個別処理
3. **広告表示**: コールバック処理付き
4. **エラーハンドリング**: 広告読み込み失敗時の処理
5. **テストモード**: 開発/本番ID切り替え

#### テスト要件
```dart
test('GoogleAdProvider - 広告表示成功', () async {
  final provider = GoogleAdProvider();
  await provider.initialize(testConfig);
  
  final result = await provider.showAd(AdType.interstitial);
  expect(result, equals(AdResult.shown));
});
```

### Task 1.2: FirebaseAnalyticsProvider実装

#### 依存関係追加
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
```

#### 実装テンプレート
```dart
// firebase_analytics_provider.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsProvider implements AnalyticsProvider {
  late FirebaseAnalytics _analytics;
  
  @override
  Future<void> initialize(AnalyticsConfiguration config) async {
    _analytics = FirebaseAnalytics.instance;
    await _analytics.setAnalyticsCollectionEnabled(true);
  }
  
  @override
  Future<bool> trackEvent(AnalyticsEvent event) async {
    try {
      await _analytics.logEvent(
        name: event.name,
        parameters: event.parameters,
      );
      return true;
    } catch (e) {
      debugPrint('Analytics error: $e');
      return false;
    }
  }
}
```

#### 必須実装項目
1. **Firebase初期化**: Core・Analytics初期化
2. **カスタムイベント送信**: logEvent実装
3. **ユーザープロパティ**: setUserProperty実装
4. **セッション管理**: startSession/endSession
5. **バッチ送信**: イベントキューイング

### Task 1.3: AudioPlayersProvider実装

#### 実装テンプレート
```dart
// audioplayers_provider.dart
import 'package:audioplayers/audioplayers.dart';

class AudioPlayersProvider implements AudioProvider {
  final Map<String, AudioPlayer> _bgmPlayers = {};
  final Map<String, AudioPlayer> _sfxPlayers = {};
  
  @override
  Future<void> playBgm(String assetId, {bool loop = true}) async {
    final player = _bgmPlayers[assetId] ?? AudioPlayer();
    _bgmPlayers[assetId] = player;
    
    await player.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
    await player.play(AssetSource('audio/bgm/$assetId'));
  }
  
  @override
  Future<void> playSfx(String assetId, {double volume = 1.0}) async {
    final player = AudioPlayer();
    await player.setVolume(volume);
    await player.play(AssetSource('audio/sfx/$assetId'));
  }
}
```

#### 必須実装項目
1. **BGM制御**: ループ再生・停止・音量調整
2. **効果音制御**: 同時再生・音量調整
3. **プリロード**: よく使用される音声の事前読み込み
4. **メモリ管理**: AudioPlayerインスタンス適切な破棄
5. **フェード**: 音量の段階的変更

## 📋 Phase 2: エフェクトシステム実装

### Task 2.1: パーティクルエフェクトシステム

#### ファイル構成
```
lib/framework/effects/
├── particle_system.dart           # メインシステム
├── particle_effects.dart          # 基本エフェクト定義
├── particle_manager.dart          # エフェクト管理
└── particle_pool.dart            # オブジェクトプール
```

#### 実装テンプレート
```dart
// particle_system.dart
import 'package:flame/particles.dart';

class ParticleEffectManager extends Component {
  final Map<String, ParticleSystemComponent> _activeEffects = {};
  final Map<String, ParticleConfiguration> _effectConfigs = {};
  
  void registerEffect(String name, ParticleConfiguration config) {
    _effectConfigs[name] = config;
  }
  
  void playEffect(String name, Vector2 position) {
    final config = _effectConfigs[name];
    if (config == null) return;
    
    final particle = _createParticle(config);
    final system = ParticleSystemComponent(
      particle: particle,
      position: position,
    );
    
    add(system);
    _activeEffects[name] = system;
  }
}
```

#### 基本エフェクト実装
```dart
// particle_effects.dart
class BasicParticleEffects {
  static Particle explosion(Vector2 position) {
    return Particle.generate(
      count: 20,
      lifespan: 1.0,
      generator: (i) => AcceleratedParticle(
        acceleration: Vector2.random() * 50,
        child: CircleParticle(
          radius: 2.0,
          paint: Paint()..color = Colors.orange,
        ),
      ),
    );
  }
  
  static Particle sparkle(Vector2 position) {
    return Particle.generate(
      count: 10,
      lifespan: 2.0,
      generator: (i) => MovingParticle(
        from: position,
        to: position + Vector2.random() * 100,
        child: CircleParticle(
          radius: 1.0,
          paint: Paint()..color = Colors.yellow,
        ),
      ),
    );
  }
}
```

### Task 2.2: アニメーションシステム

#### 実装テンプレート
```dart
// animation_system.dart
class AnimationManager extends Component {
  final Map<String, AnimationController> _controllers = {};
  
  Future<void> animateMove(
    Component target,
    Vector2 from,
    Vector2 to,
    Duration duration,
  ) async {
    final tween = Tween<Vector2>(begin: from, end: to);
    final animation = tween.animate(CurvedAnimation(
      parent: _getController(duration),
      curve: Curves.easeInOut,
    ));
    
    animation.addListener(() {
      target.position = animation.value;
    });
    
    await _getController(duration).forward();
  }
  
  Future<void> animateScale(
    Component target,
    double fromScale,
    double toScale,
    Duration duration,
  ) async {
    // スケールアニメーション実装
  }
}
```

## 📋 Phase 3: ゲーム機能システム実装

### Task 3.1: スコア・ランキングシステム

#### 実装テンプレート
```dart
// score_system.dart
class ScoreManager {
  final Map<String, int> _currentScores = {};
  final Map<String, List<ScoreEntry>> _rankings = {};
  
  void addScore(String scoreType, int points) {
    _currentScores[scoreType] = (_currentScores[scoreType] ?? 0) + points;
    _updateRanking(scoreType, _currentScores[scoreType]!);
  }
  
  int getCurrentScore(String scoreType) {
    return _currentScores[scoreType] ?? 0;
  }
  
  List<ScoreEntry> getRanking(String scoreType, {int limit = 10}) {
    final ranking = _rankings[scoreType] ?? [];
    return ranking.take(limit).toList();
  }
  
  void _updateRanking(String scoreType, int score) {
    final ranking = _rankings[scoreType] ?? [];
    ranking.add(ScoreEntry(score: score, timestamp: DateTime.now()));
    ranking.sort((a, b) => b.score.compareTo(a.score));
    _rankings[scoreType] = ranking.take(10).toList();
  }
}
```

### Task 3.2: レベル進行システム

#### 実装テンプレート
```dart
// level_system.dart
class LevelManager {
  int _currentLevel = 1;
  int _experience = 0;
  final Map<int, LevelConfiguration> _levelConfigs = {};
  
  void addExperience(int exp) {
    _experience += exp;
    _checkLevelUp();
  }
  
  void _checkLevelUp() {
    final nextLevelConfig = _levelConfigs[_currentLevel + 1];
    if (nextLevelConfig != null && _experience >= nextLevelConfig.requiredExp) {
      _currentLevel++;
      onLevelUp?.call(_currentLevel);
    }
  }
  
  LevelConfiguration getCurrentLevelConfig() {
    return _levelConfigs[_currentLevel] ?? LevelConfiguration.default();
  }
}
```

## 🔧 実装時の必須チェックリスト

### 各タスク開始時
- [ ] 既存インターフェースとの互換性確認
- [ ] 必要な依存関係の追加
- [ ] テストケースの事前定義
- [ ] 設定クラスの定義

### 実装中
- [ ] エラーハンドリングの適切な実装
- [ ] メモリリークの防止
- [ ] パフォーマンスの考慮
- [ ] ログ出力の適切な配置

### 実装完了時
- [ ] 単体テスト100%合格
- [ ] 統合テスト実行
- [ ] ブラウザシミュレーション確認
- [ ] ドキュメント更新
- [ ] 既存機能との非干渉確認

## 🚨 よくある実装ミス・注意点

### プロバイダー実装時
1. **インターフェース非準拠**: 戻り値型・引数の不一致
2. **初期化順序**: 依存関係の初期化順序を間違える
3. **エラー処理不備**: 例外発生時の適切な処理なし
4. **設定反映漏れ**: Configurationクラスの値を参照していない

### エフェクト実装時
1. **メモリリーク**: パーティクルの適切な破棄なし
2. **パフォーマンス**: 大量パーティクル生成によるFPS低下
3. **座標系**: Flame座標系との不整合

### テスト実装時
1. **非同期処理**: awaitの記載漏れ
2. **テスト独立性**: 前のテストの影響を受ける
3. **モック使用**: 実装テストでモックを使用

この詳細ガイドに従うことで、今後のAIは一貫した品質で実装を進めることができます。