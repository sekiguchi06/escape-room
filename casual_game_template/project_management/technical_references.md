# 技術リファレンス集

## 🎯 このドキュメントの目的
技術的な詳細仕様、設計文書、テスト仕様をまとめた参照用ドキュメントです。

## 📁 技術仕様書

### 1. **../docs/framework_specification.md** - フレームワーク技術仕様
- ConfigurableGameアーキテクチャ詳細
- 8システムマネージャーの設計
- プロバイダーパターン実装仕様
- 状態管理システム設計

### 2. **../docs/api_reference.md** - API仕様書  
- 各クラス・インターフェースの詳細
- メソッドシグネチャと使用例
- 設定パラメータ一覧

### 3. **../docs/test_design_specification.md** - テスト設計仕様
- 4層テスト戦略の詳細
- テストケース設計方針
- パフォーマンス基準値

### 4. **../docs/bestpractice_compliance_check.md** - ベストプラクティス適合性
- Flame/Flutterベストプラクティスとの照合結果
- 現在の実装の問題点分析
- 改善優先度の提案

### 5. **../docs/current_status_analysis.md** - 現状分析
- 技術選択の経緯と検証結果
- 成功した選択と失敗した試行
- 重要な教訓

### 6. **../docs/casual_game_framework_design.md** - フレームワーク設計
- 汎用カジュアルゲームフレームワークの設計思想
- アーキテクチャ詳細
- 実装ガイドライン

## 🔗 外部技術リファレンス

### Flutter/Dart
- [Flutter公式ドキュメント](https://flutter.dev/docs)
- [Dart言語ツアー](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)

### Flame Engine
- [Flame公式ドキュメント](https://docs.flame-engine.org/latest/)
- [Flame Examples](https://github.com/flame-engine/flame/tree/main/examples)
- [Component System](https://docs.flame-engine.org/latest/flame/components.html)
- [Effects System](https://docs.flame-engine.org/latest/flame/effects.html)

### プロバイダー実装
- [Google Mobile Ads](https://developers.google.com/admob/flutter/quick-start)
- [Firebase Analytics](https://firebase.google.com/docs/analytics/get-started?platform=flutter)
- [audioplayers](https://pub.dev/packages/audioplayers)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

### 状態管理
- [Provider](https://pub.dev/packages/provider)
- [Riverpod](https://riverpod.dev/)
- [BLoC](https://bloclibrary.dev/)

### パフォーマンス最適化
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Flame Performance Tips](https://docs.flame-engine.org/latest/flame/other/debug.html)
- [Dart Performance](https://dart.dev/guides/language/effective-dart/usage#performance)

## 💡 実装時の参照順序

### 新機能実装時
1. framework_specification.md で全体アーキテクチャ確認
2. api_reference.md で関連APIチェック
3. bestpractice_compliance_check.md でベストプラクティス確認
4. 公式ドキュメントで最新仕様確認

### バグ修正時
1. current_status_analysis.md で既知の問題確認
2. test_design_specification.md でテスト方針確認
3. 関連する技術ドキュメント参照

### パフォーマンス改善時
1. test_design_specification.md で基準値確認
2. Flutter/Flameパフォーマンスガイド参照
3. bestpractice_compliance_check.md で最適化提案確認

## 🚨 重要な技術的制約

### Flame 1.30.1での確認事項
- TapDetectorはFlameGameで使用可能（非推奨ではない）
- Component用にはTapCallbacksを使用
- RouterComponentは状態管理に適さない場合がある

### プロバイダーパターン
- 既存インターフェースの変更は禁止
- Mock→実装の段階的移行を推奨
- エラーハンドリングは各プロバイダーで実装

### テスト要件
- 単体テスト成功率: 100%必須
- ブラウザ動作確認: 必須
- パフォーマンステスト: 60FPS維持

---
最終更新: 2025年7月31日