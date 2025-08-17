# カジュアルゲーム開発プロジェクト概要

## プロジェクトの目的
AI支援によるカジュアルゲーム開発ビジネスの効率化を目的とする。目標は月4本のゲームリリースと月収30-65万円の達成。

## 技術スタック
- **メイン**: Flutter + Flame 1.30.1
- **開発支援**: Claude Code + MCP (Model Context Protocol)
- **設定管理**: JSON駆動設定システム
- **状態管理**: GameStateProvider (プロバイダーパターン)
- **UI**: ScreenFactory + FlameUIBuilder
- **分析**: Firebase Analytics
- **広告**: Google Mobile Ads
- **音響**: Flame Audio + AudioPlayers

## アーキテクチャパターン
- **ConfigurableGame基盤**: 設定駆動ゲーム開発
- **プロバイダーパターン**: Audio, Ad, Analytics等の実装抽象化
- **テンプレートパターン**: CasualGameTemplate継承による量産対応
- **コンポーネント指向**: Flame Component System活用

## 完成度・品質基準
- テスト成功率: 96.2% (351/365)
- シミュレーション動作確認: 必須
- ブラウザ動作確認: 必須
- 実機動作確認: 必須

## 主要成果物
- TapFireGame: 完全実装済み使用例
- CasualGameTemplate: 量産用基盤フレームワーク
- ScreenFactory: UI画面生成システム
- 設定駆動システム: JSON設定による難易度調整