# エスケープルーム ギミック・アイテム管理ドキュメント

## 概要

このドキュメントは、エスケープルームゲームのギミック（仕掛け）とアイテムの組み合わせシステムを視覚的に管理するためのドキュメントです。

## アイテム依存関係図

```mermaid
graph TD
    %% 基本アイテム
    Key[🔑 Key<br/>鍵]
    Code[📄 Code<br/>コード]
    Document[📋 Document<br/>書類]
    MagnifyingGlass[🔍 Magnifying Glass<br/>拡大鏡]
    
    %% 組み合わせアイテム
    MasterKey[🗝️ Master Key<br/>マスターキー]
    SecretInfo[📝 Secret Info<br/>秘密の情報]
    
    %% ギミック
    Safe[🏦 Safe<br/>金庫]
    Bookshelf[📚 Bookshelf<br/>本棚]
    Box[📦 Box<br/>箱]
    
    %% 組み合わせルール
    Key --> MasterKey
    Code --> MasterKey
    Document --> SecretInfo
    MagnifyingGlass --> SecretInfo
    
    %% ギミック解除ルール
    MasterKey --> Safe
    SecretInfo --> Bookshelf
    
    %% ギミックからの報酬アイテム
    Safe --> |解除後| FinalCode[🎫 Final Code<br/>最終コード]
    Bookshelf --> |解除後| HiddenKey[🔐 Hidden Key<br/>隠されたキー]
    Box --> |解除後| Document
    
    %% スタイル設定
    classDef basicItem fill:#e1f5fe
    classDef combinedItem fill:#fff3e0
    classDef gimmick fill:#f3e5f5
    classDef rewardItem fill:#e8f5e8
    
    class Key,Code,Document,MagnifyingGlass basicItem
    class MasterKey,SecretInfo combinedItem
    class Safe,Bookshelf,Box gimmick
    class FinalCode,HiddenKey rewardItem
```

## ゲーム進行フロー

```mermaid
flowchart TD
    Start([ゲーム開始]) --> Explore[部屋を探索]
    
    Explore --> FindItems{アイテム発見}
    FindItems --> |Basic Items| Inventory[インベントリに追加]
    
    Inventory --> CheckCombination{組み合わせ可能?}
    CheckCombination --> |Yes| CombineItems[アイテム組み合わせ]
    CheckCombination --> |No| TryGimmick{ギミック試行可能?}
    
    CombineItems --> NewItem[新アイテム生成]
    NewItem --> TryGimmick
    
    TryGimmick --> |Yes| SolveGimmick[ギミック解除]
    TryGimmick --> |No| Explore
    
    SolveGimmick --> RewardItem[報酬アイテム獲得]
    RewardItem --> CheckWin{クリア条件達成?}
    
    CheckWin --> |Yes| GameClear[🎉 ゲームクリア]
    CheckWin --> |No| Explore
    
    %% スタイル設定
    classDef startEnd fill:#4caf50,color:#fff
    classDef process fill:#2196f3,color:#fff
    classDef decision fill:#ff9800,color:#fff
    classDef success fill:#8bc34a,color:#fff
    
    class Start,GameClear startEnd
    class Explore,Inventory,CombineItems,SolveGimmick,NewItem,RewardItem process
    class FindItems,CheckCombination,TryGimmick,CheckWin decision
```

## アイテム管理テーブル

### 基本アイテム

| アイテムID | 名前 | 説明 | 取得場所 | 消費型 |
|------------|------|------|----------|--------|
| `key` | 鍵 | 古い鍵 | Box | ❌ |
| `code` | コード | 数字の書かれた紙 | Safe | ✅ |
| `document` | 書類 | 重要な書類 | Bookshelf | ❌ |
| `magnifying_glass` | 拡大鏡 | 詳細確認用 | 初期アイテム | ❌ |

### 組み合わせアイテム

| アイテムID | 名前 | 説明 | 必要アイテム | 消費アイテム |
|------------|------|------|-------------|-------------|
| `master_key` | マスターキー | すべての鍵を開く | `key` + `code` | 両方 |
| `secret_info` | 秘密の情報 | 隠された情報 | `document` + `magnifying_glass` | `document` のみ |

## ギミック管理テーブル

### ギミック仕様

| ギミックID | 名前 | 説明 | 必要アイテム | 報酬アイテム | 解除後状態 |
|------------|------|------|-------------|-------------|-----------|
| `safe` | 金庫 | 鍵のかかった金庫 | `key` (基本) または `master_key` (上級) | `code` | 開いた状態 |
| `bookshelf` | 本棚 | 隠し扉付きの本棚 | `secret_info` | `final_code` | 扉開放 |
| `box` | 箱 | シンプルな箱 | なし | `document` | 開いた状態 |

## 組み合わせルール管理

### アイテム組み合わせルール

```yaml
combination_rules:
  key_code_combination:
    id: "key_code_combination"
    required_items: ["key", "code"]
    result_item: "master_key"
    description: "鍵とコードを組み合わせてマスターキーを作成"
    consume_items: true
    
  document_analysis:
    id: "document_analysis"
    required_items: ["document", "magnifying_glass"]
    result_item: "secret_info"
    description: "書類を拡大鏡で詳しく調べる"
    consume_items: false  # 拡大鏡は再利用可能
```

### ギミック解除ルール

```yaml
gimmick_rules:
  safe_master_unlock:
    id: "safe_master_unlock"
    target_object: "safe"
    required_items: ["master_key"]
    success_message: "金庫がマスターキーで開いた！隠されたアイテムを発見！"
    failure_message: "この金庫にはマスターキーが必要だ"
    consume_items: false  # マスターキーは再利用可能
    
  bookshelf_secret_reveal:
    id: "bookshelf_secret_reveal"
    target_object: "bookshelf"
    required_items: ["secret_info"]
    success_message: "本棚の隠し扉が開いた！"
    failure_message: "本棚に何か秘密がありそうだが、手がかりが必要だ"
    consume_items: true
```

## クリア条件

### 必要条件

```mermaid
graph LR
    subgraph "アイテム収集条件"
        A[key 取得] --> B[code 取得]
        B --> C[document 取得]
        C --> D[必要アイテム完了]
    end
    
    subgraph "ギミック解除条件"
        E[safe 解除] --> F[bookshelf 解除]
        F --> G[box 解除]
        G --> H[全ギミック完了]
    end
    
    D --> I{条件統合}
    H --> I
    I --> J[🎉 ゲームクリア]
```

### 条件詳細

1. **アイテム収集**: `key`, `code`, `document` をすべて収集
2. **ギミック解除**: `safe`, `bookshelf`, `box` をすべて解除
3. **追加条件**: 特定の組み合わせアイテム生成（オプション）

## セーブデータ構造

### ゲーム状態

```json
{
  "game_state": {
    "current_state": "exploring",
    "session_start_time": "2024-01-01T00:00:00Z",
    "elapsed_time_seconds": 300
  },
  "inventory": {
    "items": ["key", "magnifying_glass"],
    "max_capacity": 5
  },
  "clear_conditions": {
    "collect_all_items": {
      "completed": false,
      "progress": ["key"],
      "required": ["key", "code", "document"]
    },
    "interact_all_objects": {
      "completed": false,
      "progress": ["box"],
      "required": ["safe", "bookshelf", "box"]
    }
  },
  "combination_system": {
    "used_combinations": [],
    "activated_gimmicks": ["box"]
  },
  "object_states": {
    "safe": "locked",
    "bookshelf": "closed",
    "box": "opened"
  }
}
```

## 開発者向け情報

### システム実装

- **ClearConditionManager**: クリア条件の管理・追跡
- **ItemCombinationManager**: アイテム組み合わせ・ギミック解除ルールの管理
- **EscapeRoomGameController**: オブジェクト操作履歴の追跡
- **InventoryManager**: アイテム所持・選択の管理

### 追加・変更手順

1. **新アイテム追加**:
   ```dart
   // GameItem として定義
   final newItem = GameItem(
     id: 'new_item',
     name: '新アイテム',
     description: '説明',
     imagePath: 'assets/items/new_item.png',
   );
   ```

2. **新組み合わせルール追加**:
   ```dart
   _itemCombinationManager.addCombinationRule(CombinationRule(
     id: 'new_combination',
     requiredItems: ['item1', 'item2'],
     resultItem: 'result_item',
     description: '新しい組み合わせ',
   ));
   ```

3. **新ギミック追加**:
   ```dart
   _itemCombinationManager.addGimmickRule(GimmickRule(
     id: 'new_gimmick',
     targetObjectId: 'new_object',
     requiredItems: ['required_item'],
     successMessage: '解除成功！',
     failureMessage: '解除失敗...',
   ));
   ```

---

**更新日**: 2024年1月1日  
**バージョン**: 1.0.0  
**担当**: AI Assistant