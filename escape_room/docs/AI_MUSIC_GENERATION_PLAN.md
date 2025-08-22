# AI音楽生成実装プラン

## プロジェクト概要
脱出ゲーム「escape-room」向けのAI生成音楽・効果音素材作成計画

## 必要な音楽素材

### BGM (3種類)
1. **exploration_ambient.mp3** - 探索BGM
   - 長さ: 2-3分ループ
   - ムード: ミステリアス、緊張感、探究心を誘う
   - 楽器: アンビエント、ストリングス、微細なパーカッション
   - BPM: 70-80 (リラックスしながら集中できるテンポ)

2. **victory_fanfare.mp3** - 勝利BGM  
   - 長さ: 30-60秒 (ショート)
   - ムード: 達成感、喜び、解放感
   - 楽器: オーケストラ、ブラス、シンセパッド
   - BPM: 120-140 (エネルギッシュ)

3. **menu.mp3** - メニューBGM (既存をアップグレード)
   - 長さ: 1-2分ループ
   - ムード: 導入、期待感、親しみやすさ
   - 楽器: ピアノメイン、軽やかなストリングス
   - BPM: 90-100 (ちょうど良いテンポ)

### 新規効果音 (5種類)
1. **discovery_chime.wav** - 発見音
2. **item_combine.wav** - アイテム組み合わせ音
3. **puzzle_fail.wav** - パズル失敗音
4. **room_transition.wav** - ルーム遷移音
5. **mystery_ambience.wav** - ミステリー環境音

## AI音楽生成サービス評価

### 1位: SOUNDRAW (推奨)
- **著作権**: 100%クリア、商用利用フル対応
- **品質**: ゲーム音楽特化、ループ対応
- **価格**: Pro版 $25/月
- **特徴**: 
  - ジャンル「Game/Ambient」専用カテゴリ
  - BPM・ムード・楽器構成の細かい調整
  - 無制限ダウンロード
  - WAV/MP3両対応

### 2位: Mubert
- **著作権**: ロイヤリティフリー
- **品質**: リアルタイム生成、アンビエント強い
- **価格**: Creator版 $14/月
- **特徴**: 
  - 「Gaming」「Ambient」「Cinematic」カテゴリ
  - 長時間ループ生成得意
  - API連携可能

### 3位: Beatoven.ai
- **著作権**: 商用利用OK
- **品質**: 映画音楽的、感情ベース生成
- **価格**: Pro版 $20/月
- **特徴**:
  - 「Adventure」「Mystery」「Victory」感情設定
  - 30秒〜8分まで対応
  - 楽器編成カスタマイズ

## 実装スケジュール

### Phase 1: サービス契約・素材生成 (1日)
- [ ] SOUNDRAWプロ版契約
- [ ] exploration_ambient.mp3 生成 (3バリエーション作成・選定)
- [ ] victory_fanfare.mp3 生成 (2バリエーション作成・選定)
- [ ] menu.mp3 アップグレード版生成

### Phase 2: 効果音作成 (半日)
- [ ] 5種類の新規効果音を生成
- [ ] 音量・長さ調整
- [ ] フォーマット統一 (WAV, 44.1kHz, 16bit)

### Phase 3: 統合テスト (半日)
- [ ] assets/sounds/に配置
- [ ] ゲーム内動作確認
- [ ] 音量バランス調整
- [ ] ループ動作テスト

## 技術仕様

### 音声ファイル要件
- **BGM**: MP3形式、44.1kHz、128-320kbps、ステレオ
- **効果音**: WAV形式、44.1kHz、16bit、モノラル
- **ファイルサイズ制限**: BGM < 5MB、SFX < 1MB

### 命名規則
```
assets/sounds/
├── exploration_ambient.mp3    # 探索BGM
├── victory_fanfare.mp3        # 勝利BGM  
├── menu.mp3                   # メニューBGM (更新)
├── discovery_chime.wav        # 発見効果音
├── item_combine.wav           # 組み合わせ効果音
├── puzzle_fail.wav            # 失敗効果音
├── room_transition.wav        # 遷移効果音
└── mystery_ambience.wav       # 環境音
```

## 著作権対応

### SOUNDRAW利用規約確認事項
- [x] 商用ゲームでの利用許可
- [x] 無制限配布権
- [x] 編集・加工権
- [x] 永続ライセンス (サブスク解約後も利用可能)

### ライセンス文書
```
Music generated using SOUNDRAW (https://soundraw.io)
Licensed for commercial use in escape-room game
All rights reserved to the game developer
```

## 予算見積もり

| 項目 | コスト | 備考 |
|------|--------|------|
| SOUNDRAW Pro (1ヶ月) | $25 | 8素材生成で十分 |
| 追加効果音パック | $0 | SOUNDRAWで効果音も生成 |
| **総計** | **$25** | **約3,500円** |

## 成功指標

### 品質評価基準
1. **BGM適合性**: ゲームムードとの調和 (5段階評価で4以上)
2. **ループ品質**: 継ぎ目の自然性 (無音・ノイズなし)
3. **効果音明瞭性**: 操作フィードバックとしての効果
4. **音量バランス**: BGMと効果音の適切な音量差
5. **ファイルサイズ**: 仕様内でのクオリティ最適化

### 技術評価基準
1. **統合動作**: IntegratedAudioManagerでの正常動作
2. **パフォーマンス**: 音響再生時のフレーム落ちなし
3. **互換性**: iOS/Android/Web対応確認
4. **エラーハンドリング**: 音響ファイル欠如時の適切な処理

## 次期アップデート計画

### 追加検討素材
1. **パズル特化BGM**: 各パズル種別専用音楽
2. **ルーム専用BGM**: 部屋別環境音楽  
3. **キャラクターボイス**: AI音声合成でのナレーション
4. **インタラクティブ音楽**: プレイヤー行動に応じた動的音楽変化

---

## 実行コマンド

```bash
# 1. 音声素材配置確認
ls -la assets/sounds/

# 2. Flutter assets更新
flutter clean && flutter pub get

# 3. 統合音響システムテスト
flutter test test/audio_integration_test.dart

# 4. ゲーム動作確認  
flutter run -d chrome --web-port 8080
```