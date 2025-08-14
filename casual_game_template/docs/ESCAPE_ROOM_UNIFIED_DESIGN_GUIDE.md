# Escape Room Framework 統一設計ガイド

**作成日**: 2025-08-14  
**目的**: Flutter・Flame・Dart公式ガイドライン準拠のEscape Roomフレームワーク設計  
**対象**: 後続AI開発者向け統一ガイド

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

## 🔧 実装順序

### Phase 1: 基盤レイヤー
1. インターフェース・抽象クラス定義
2. 基底コンポーネントクラス実装
3. 基本戦略インターフェース定義

### Phase 2: コンポーネントレイヤー
1. 画像管理コンポーネント実装
2. 音声管理コンポーネント実装
3. アニメーション管理コンポーネント実装

### Phase 3: 戦略レイヤー
1. アイテム提供戦略実装
2. パズル要求戦略実装
3. 条件付き相互作用戦略実装

### Phase 4: GameObjectレイヤー
1. 基底GameObjectクラス実装
2. 具象GameObject実装(本棚、金庫、箱等)
3. システム統合テスト

## ✅ 品質基準

### 1. コード品質
- `flutter analyze`: 0 errors, 0 warnings
- `dart format`: 自動フォーマット適用済み
- 循環複雑度: 1メソッドあたり10未満

### 2. テスト基準
- 単体テスト: 各クラス・メソッドの個別テスト
- 統合テスト: コンポーネント間連携テスト
- テストカバレッジ: 80%以上

### 3. パフォーマンス基準
- 起動時間: 3秒未満
- フレームレート: 60fps維持
- メモリ使用量: 100MB未満

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

## ⚠️ 後続AI開発者への注意事項

### 1. このドキュメント必読
実装開始前にこのドキュメントを完全に理解してください。不明点がある場合は作業を停止し、質問してください。

### 2. 公式ガイドライン優先
Flutter・Flame・Dart公式ガイドラインと矛盾する場合は、必ず公式を優先してください。

### 3. 段階的実装
一度に全体を実装せず、Phase単位での段階的実装を行ってください。

### 4. テスト駆動開発
各実装完了時に対応するテストを作成・実行し、品質を確保してください。

## 🎯 実装時の具体的指示

### 最初にやること
1. **このドキュメント熟読** - 理解できるまで実装開始禁止
2. **既存escape_room_template.dartを完全無視** - 参考にしない
3. **新規ディレクトリ確認**: `lib/framework/escape_room/`
4. **基底クラスから実装開始** - 具象クラスは後

### AI生成画像資産
```
assets/images/hotspots/
├── bookshelf_full.png    ✅ 存在
├── bookshelf_empty.png   ✅ 存在  
├── safe_closed.png       ✅ 存在
├── safe_opened.png       ✅ 存在
├── box_closed.png        ✅ 存在
└── box_opened.png        ✅ 存在
```

### 各実装での必須確認
- **コンパイルエラー0**: 次の実装に進む前に解決
- **AI画像パス正確性**: assets/images/hotspots/の画像使用
- **ログ出力確認**: debugPrint()で動作ログ
- **行数制限遵守**: 各クラス200行以内

### 実装時の必須ルール
1. **AI生成画像の必須使用** - assets/images/hotspots/内の画像
2. **エラーハンドリング必須** - 画像読み込み失敗時の対応
3. **デバッグログ必須** - 全てのインタラクションをログ出力

---

**このドキュメントは後続AI開発者が一貫した品質でEscape Roomフレームワークを実装するための統一ガイドです。疑問点がある場合は実装を停止し、明確化を求めてください。**