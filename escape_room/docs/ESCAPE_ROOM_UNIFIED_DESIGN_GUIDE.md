# 脱出ゲームフレームワーク 設計アーキテクチャガイド

**最終更新**: 2025-08-18  
**目的**: Flutter + Flameベースの脱出ゲーム特化フレームワークの設計原則定義  
**対象**: 設計思想統一・長期保守性確保  
**関連ドキュメント**: [AI_MASTER.md](AI_MASTER.md) (実装詳細・進捗管理), [CLAUDE.md](CLAUDE.md) (開発ルール)

## 📚 参照公式ドキュメント

### Flutter公式ガイドライン
**参照URL**: `https://docs.flutter.dev/development/data-and-backend/state-mgmt/options`

**重要な指針**:
- 状態管理は複雑な問題であり、単一の汎用解決策は存在しない
- 開発者は特定の使用ケースに適したアプローチを選択すべき
- アプリケーションの複雑さに応じて状態管理手法を選択
- 関心の分離を維持し、状態管理を予測可能にする

### Flame Engine公式ガイドライン  
**参照URL**: `https://docs.flame-engine.org/latest/flame/game.html`  
**参照URL**: `https://docs.flame-engine.org/latest/flame/components.html`

**重要な指針**:
- Flame Component System (FCS)がアーキテクチャの核心
- `FlameGame`はコンポーネントツリーのルートとして機能
- コンポーネントベースの設計を推奨
- 直接継承よりも`World`へのコンポーネント追加を推奨
- 標準ライフサイクル: `onLoad()`, `onMount()`, `update()`, `render()`, `onRemove()`

### Dart言語公式ガイドライン
**参照URL**: `https://dart.dev/guides/language/effective-dart/design`

**重要な指針**:
- 単純な関数で済む場合は単一メンバー抽象クラスを避ける
- 静的メンバーのみを含むクラス定義を避ける  
- 継承を意図していないクラスの拡張を避ける
- インターフェースを意図していないクラスの実装を避ける
- クラス修飾子を使用して継承とインターフェース化を制御
- フィールドとトップレベル変数をfinalにすることを優先

### Unity vs Flame設計比較調査
**参照検索**: "Unity Component System vs Object Oriented inheritance best practices 2025"

**調査結果**:
- Unity開発コミュニティはComponent-based設計を強く推奨
- Composition over Inheritanceが一貫した指針
- コンポーネントは小さく独立していることが重要
- 継承階層よりもコンポーネント組み合わせが保守性・拡張性で優位
- データ指向設計(ECS)への進化傾向

## 🎯 設計原則

### 1. アーキテクチャ原則
- **Composition over Inheritance**: 継承階層を浅く保ち、機能をコンポーネントで組み合わせ
- **Component-based Design**: Flame FCSに準拠した設計
- **Strategy Pattern**: 異なる行動パターンを戦略として分離
- **Separation of Concerns**: 責任を明確に分離

### 2. Flame Engine準拠
- `PositionComponent`を基底として継承
- `TapCallbacks`等のMixinを適切に使用
- Flameライフサイクル(`onLoad`, `onMount`, `update`, `render`)の活用
- `FlameGame`をコンポーネントツリーのルートとして使用

### 3. Dart言語準拠
- 抽象クラスは複数メンバーを持つ場合のみ定義
- `final`キーワードの積極的使用
- 適切なクラス修飾子による継承制御
- インターフェース分離原則の遵守

## 🚫 設計禁止事項

### 1. 継承関連禁止事項
- **深い継承階層の禁止**: 3層を超える継承階層は作成しない
- **機能による不自然な分類禁止**: `ContainerObject`vs`SecurityObject`等の人工的分離
- **switch文による分岐制御禁止**: オブジェクト指向原則に反する手続き型設計
- **ファクトリーメソッド濫用禁止**: switch文を隠蔽するだけの偽装抽象化

### 2. コンポーネント設計禁止事項
- **単一責任原則違反の禁止**: 1つのクラスに複数の責任を混在させない
- **密結合設計の禁止**: コンポーネント間の強い依存関係
- **コールバック地獄の禁止**: `Function(String)?`等による手続き型制御
- **巨大クラスの禁止**: 200行を超えるクラス定義

### 3. Flutter/Flame違反の禁止
- **Flame FCS無視の禁止**: 独自のコンポーネントシステム作成
- **ライフサイクル無視の禁止**: Flame標準ライフサイクルメソッドを使用しない設計
- **状態管理パターン無視の禁止**: Flutter推奨パターンを無視した独自実装

## 🏗️ 推奨アーキテクチャ

### 1. レイヤー構造
```
┌─ GameObject Layer (具象オブジェクト)
├─ Strategy Layer (行動パターン) 
├─ Component Layer (機能コンポーネント)
└─ Core Layer (基底クラス・インターフェース)
```

### 2. 責任分離
- **Core Layer**: 最小限の基底クラスとインターフェース定義
- **Component Layer**: 再利用可能な機能単位(画像、音声、アニメーション等)
- **Strategy Layer**: 異なる相互作用パターン(アイテム提供、パズル等)
- **GameObject Layer**: 戦略とコンポーネントの組み合わせ

### 3. 依存関係
- 上位レイヤーは下位レイヤーに依存可能
- 下位レイヤーは上位レイヤーに依存不可
- 同一レイヤー内は疎結合を維持

## 📋 実装ガイドライン

### 1. クラス設計基準
- **1クラス = 1責任**: Single Responsibility Principleの厳格な遵守
- **行数制限**: 1クラス200行以内、1メソッド50行以内
- **命名規則**: 目的・責任が明確になる命名
- **final使用**: 変更不要なフィールドはfinalで宣言

### 2. コンポーネント設計基準
- **独立性**: 他コンポーネントに依存しない設計
- **再利用性**: 複数のGameObjectで使用可能
- **テスタビリティ**: 単独でテスト可能な設計
- **最小インターフェース**: 必要最小限のpublicメンバー

### 3. 戦略設計基準
- **交換可能性**: 同一インターフェースを実装する戦略は相互交換可能
- **拡張性**: 新戦略追加時に既存コード変更不要
- **パラメータ化**: 設定値による動作カスタマイズ対応

## 🗺️ 現在の実装アーキテクチャ

### 実装済みレイヤー構造
```
lib/framework/escape_room/
├── core/             # Core Layer - 基底クラス・コントローラー
├── gameobjects/      # GameObject Layer - パズルオブジェクト
├── components/       # Component Layer - 音響・スプライト等
├── strategies/       # Strategy Layer - 相互作用パターン
├── state/            # State Layer - Riverpod状態管理
└── ui/               # UI Layer - 縦向きUI構築

その他のフレームワークコンポーネント:
lib/framework/
├── components/       # 汎用コンポーネント(インベントリ等)
├── ui/               # 脱出ゲーム特化UI
├── audio/            # 音響システム
├── state/            # 状態管理
└── core/             # 基盤システム
```

### アーキテクチャ遵守状況
- ✅ **Component-based Design**: Flame FCSに準拠した設計
- ✅ **Composition over Inheritance**: 継承より組み合わせを優先
- ✅ **Strategy Pattern**: 相互作用パターンの分離
- ✅ **Separation of Concerns**: 各レイヤーの明確な役割分担

## ✅ 設計品質基準

### 1. アーキテクチャ品質
- **単一責任原則**: 1クラスは1つの明確な責任を持つ
- **継承深度制限**: 3層を超える深い継承禁止
- **コンポーネント間疎結合**: 強い依存関係の排除
- **インターフェース分離**: 必要最小限のpublicメンバー

### 2. コード品質ルール
- **クラスサイズ**: 200行以内を原則とする
- **メソッドサイズ**: 50行以内を原則とする
- **命名統一**: 目的・責任が明確になる命名
- **final使用**: 変更不要なフィールドはFinal宣言

### 3. 設計パターン遵守
- **Strategy Pattern**: 行動パターンの交換可能性確保
- **Template Method**: ライフサイクル統一管理
- **Composition Pattern**: 機能組み合わせによる拡張

> **注意**: 実装詳細なコード品質・KPIは[AI_MASTER.md](AI_MASTER.md)を参照

## 📖 参考資料

### 設計パターン
- Strategy Pattern: 行動の抽象化と交換可能性
- Template Method Pattern: ライフサイクル統一管理
- Composition Pattern: 機能の組み合わせによる拡張

### SOLID原則適用
- **S**ingle Responsibility: 1クラス1責任
- **O**pen/Closed: 拡張に開いて修正に閉じる
- **L**iskov Substitution: 派生クラス置換可能性
- **I**nterface Segregation: インターフェース分離
- **D**ependency Inversion: 抽象への依存

## ⚠️ 設計原則遵守指針

### 1. アーキテクチャ優先順位
1. **Flutter/Flame/Dart公式ガイドライン**: 最優先遵守
2. **このドキュメントの設計原則**: 第2優先
3. **実装者の裁量**: 上記2つに矛盾しない範囲で許可

### 2. 設計思想の継承
- **基本設計は変更禁止**: レイヤー構造・責任分担の大幅変更禁止
- **拡張性確保**: 新機能追加時に既存コード変更最小化
- **下位互換性維持**: 既存APIの互換性破壊禁止

### 3. 品質確保手法
- **設計レビュー**: 実装前の設計パターン確認
- **コードレビュー**: 設計原則遵守状況の確認
- **アーキテクチャテスト**: レイヤー間依存関係の検証

### 4. ドキュメント連携
- **設計変更時**: このドキュメントを更新
- **実装変更時**: [AI_MASTER.md](AI_MASTER.md)を更新
- **ルール変更時**: [CLAUDE.md](CLAUDE.md)を更新

## 📄 ドキュメント体系と役割分担

### このドキュメントの役割
- **設計原則・アーキテクチャ指針の定義** (不変・長期保持)
- **品質基準・禁止事項の明文化** (変更稀)
- **公式ガイドライン準拠の確保** (Flutter/Flame/Dart準拠)

### 実装詳細は別ドキュメント参照
- **実装状況・進捗**: [AI_MASTER.md](AI_MASTER.md)
- **ファイル構成・API仕様**: [AI_MASTER.md](AI_MASTER.md)
- **コマンド・実装パターン**: [AI_MASTER.md](AI_MASTER.md)
- **開発ルール・禁止事項**: [CLAUDE.md](CLAUDE.md)

### 読み込み順序
1. **このドキュメント**: 設計思想理解
2. **[AI_MASTER.md](AI_MASTER.md)**: 実装ガイド
3. **[CLAUDE.md](CLAUDE.md)**: 開発ルール

---

## 📚 参考文献・推奨学習リソース

### 公式ドキュメント
- [Flutter Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)
- [Flame Engine Components](https://docs.flame-engine.org/latest/flame/components.html)
- [Dart Effective Design](https://dart.dev/guides/language/effective-dart/design)

### 設計パターン
- Strategy Pattern, Template Method Pattern, Composition Pattern
- SOLID原則の実践的適用
- Component-based Architecture vs Object-oriented Architecture

---

**このドキュメントは脱出ゲームフレームワークの設計思想と品質基準を定義し、長期的な保守性と拡張性を確保するためのアーキテクチャガイドです。実装詳細については[AI_MASTER.md](AI_MASTER.md)を参照してください。**