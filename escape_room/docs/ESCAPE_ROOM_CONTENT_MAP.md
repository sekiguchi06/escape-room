# 脱出ゲーム統一コンテンツマップ - 封印された貴族の館

## 世界観とストーリー

### 設定：ヴァレリアン伯爵の館
中世の貴族ヴァレリアン伯爵が所有していた古い館。伯爵は錬金術と古代魔術の研究に没頭し、地下に古代の遺跡を発見。しかし研究中に何らかの事故が起こり、館全体が魔法的な封印で閉ざされてしまった。

### 物語の流れ
プレイヤーは何らかの理由でこの館に迷い込み、出口の扉は古代の魔法で封印されている。脱出するには地下に眠る古代の秘密を解き明かし、封印を解除する必要がある。

### 建物構造
- **1階**：貴族の居住空間（自然光が差し込む窓、豪華な装飾）
- **地下**：古代遺跡と秘密の研究室（石造り、松明による照明、神秘的な雰囲気）
- **隠し部屋**：館の各所に隠された秘密の小部屋

---

## 全体構造

- **12の部屋** (1階5室、地下5室、隠し部屋2室)
- **25以上のホットスポット** (調査、アイテム取得、ギミック解除、部屋遷移)
- **5つの主要ギミック** (古代印章合成、地下封印解除、最終脱出等)
- **3つの階層** (1階→地下→隠し部屋)

---

## 1階（Floor1）- 貴族の居住空間

### 大図書室（room_center）- ゲーム開始地点
**背景画像**: `grand_library.png`
**設定**: 館の中心にある豪華な図書室。高い天井、大きな窓から差し込む光、古い書物で埋め尽くされた本棚。

**背景画像生成プロンプト**:
```
medieval nobleman's grand library interior, high vaulted ceiling with wooden beams, tall arched windows with golden sunlight, floor-to-ceiling bookshelves with ancient tomes, ornate carved wooden desk with brass details, heavy wooden door with iron reinforcements and magical seals, stone fireplace with noble coat of arms, beautiful stained glass window, rich carpets on stone floor, elegant chandeliers, warm lighting, Renaissance Gothic architecture, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `main_exit_door` | 館の正面扉 | 重厚な木製の正面扉（封印中） | **最終脱出** | `liberation_key` | なし | 🚪 ゲームクリア |
| `grand_desk` | 伯爵の机 | 豪華な彫刻が施された大きな机 | アイテム合成 | `noble_seal` + `ancient_fragment` | `chamber_key` | 🔑 地下への鍵作成 |
| `ancient_tome` | 古代魔術書 | 革装丁の古い魔術書 | 調査 | なし | なし | 📖 古代文字の解読ヒント |
| `ornate_fireplace` | 装飾暖炉 | 貴族の紋章が刻まれた大理石の暖炉 | 調査 | なし | なし | 🏰 館の歴史 |
| `stained_glass` | ステンドグラス | 物語を描いた美しいステンドグラス | 調査 | なし | なし | 🎨 伯爵の物語 |

### 肖像画の回廊（room_left）
**背景画像**: `portrait_corridor.png`
**設定**: 歴代貴族の肖像画が並ぶ長い廊下。窓から庭園が見える。

**背景画像生成プロンプト**:
```
medieval castle portrait gallery corridor, long stone hallway with vaulted ceiling, series of large oil paintings in golden frames showing noble ancestors, prominent portrait of bearded nobleman Count Valerian with regal bearing, large arched windows showing overgrown garden courtyard with sunlight, medieval knight's armor display with sword and shield, rich red carpet runner, stone walls with tapestries, warm natural lighting, Gothic Renaissance architecture, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `count_portrait` | 伯爵の肖像画 | ヴァレリアン伯爵の威厳ある肖像画 | アイテム取得 | なし | `noble_seal` | 👑 伯爵の印章 |
| `garden_window` | 庭園の窓 | 荒れ果てた庭園を望む大きな窓 | 調査 | なし | なし | 🌿 過去の栄華 |
| `armor_display` | 甲冑の展示 | 騎士の甲冑と武器の展示 | 調査 | なし | なし | ⚔️ 騎士の誇り |
| `hidden_room_entrance_a` | 隠し部屋A入口 | 肖像画の後ろの秘密の通路 | 隠し部屋遷移 | なし | なし | 🗝️ 隠し部屋Aへ |

### 錬金術研究室（room_right）
**背景画像**: `alchemy_laboratory.png`
**設定**: 伯爵が錬金術を研究していた部屋。実験器具、薬草、魔法陣が描かれた床。

**背景画像生成プロンプト**:
```
medieval alchemist's laboratory, stone room with arched ceiling, complex glass distillation apparatus with copper tubes and alembics, wooden shelves with glass bottles containing colorful liquids and dried herbs, ancient tomes with brass clasps, intricate magical circle carved into stone floor with mystical symbols, workbench with mortar and pestle, scales and bubbling cauldrons, natural light from small window, candlelight creating shadows, herb bundles hanging from ceiling, scrolls with alchemical formulas, Renaissance medieval scientific atmosphere, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `alchemical_apparatus` | 錬金術装置 | 複雑なガラス管と蒸留器 | 調査 | なし | なし | ⚗️ 錬金術の痕跡 |
| `herb_cabinet` | 薬草棚 | 様々な薬草が保管された棚 | アイテム取得 | なし | `mystic_herb` | 🌿 神秘の薬草 |
| `magic_circle` | 魔法陣 | 床に描かれた複雑な魔法陣 | 調査 | なし | なし | ✨ 古代魔術の力 |
| `research_notes` | 研究記録 | 伯爵の錬金術研究ノート | 調査 | なし | なし | 📜 地下への手がかり |
| `hidden_room_entrance_b` | 隠し部屋B入口 | 錬金術師の隠し扉 | 隠し部屋遷移 | なし | なし | 🔬 隠し部屋Bへ |

### 使用人の通路（room_leftmost）
**背景画像**: `servant_passage.png`
**設定**: 使用人が使っていた質素な通路。地下への階段がある。

**背景画像生成プロンプト**:
```
medieval castle servant's passage, narrow stone corridor with simple architecture, utilitarian design with rough stone walls, wooden support beams, small torch sconces providing dim lighting, stone staircase leading down into darkness, simple wooden door with iron hinges, wall alcove with hidden storage compartment, less ornate than noble quarters, practical working-class medieval interior, worn areas from frequent use by servants, heavy wooden door reinforced with iron bands blocking underground entrance, Gothic architecture, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `service_stairs` | 使用人階段 | 地下への古い石の階段 | 調査 | なし | なし | 🏛️ 地下への道 |
| `storage_alcove` | 収納窪み | 壁の窪みに隠された収納 | アイテム取得 | なし | `ancient_fragment` | 🗿 古代の欠片 |
| `underground_entrance` | 地下入口 | 重い石扉で封印された地下入口 | 階層遷移 | `chamber_key` | なし | 🚪 地下フロアへ |

### 貴族の宝物庫（room_rightmost）
**背景画像**: `noble_treasury.png`
**設定**: 金銀財宝と貴重品が保管された部屋。豪華な装飾と宝箱。

**背景画像生成プロンプト**:
```
medieval noble's treasure chamber, opulent stone room with vaulted ceiling, massive ornate wooden chest reinforced with brass bands and jeweled decorations at center, shelves displaying golden crown with emeralds and rubies, silver chalice with intricate engravings, piles of gold coins, precious gems, ancient maps rolled on ornate table, rich tapestries on walls, marble columns, golden candlesticks, luxurious Persian rugs, warm golden lighting highlighting treasures, renaissance palace interior, regal atmosphere, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `golden_chest` | 黄金の大宝箱 | 宝石で装飾された巨大な宝箱 | 調査 | なし | なし | 💰 封印された財宝 |
| `jeweled_crown` | 宝石の王冠 | エメラルドとルビーの美しい王冠 | 調査 | なし | なし | 👑 王家の証 |
| `silver_chalice` | 銀の聖杯 | 神聖な力を宿すとされる聖杯 | 調査 | なし | なし | ⚱️ 聖なる器 |
| `treasure_map` | 宝の地図 | 館の隠された宝を示す古い地図 | 調査 | なし | なし | 🗺️ 隠し部屋の手がかり |

---

## 地下（Underground）- 古代遺跡と秘密研究室

### 古代祭壇の間（undergroundLeftmost）
**背景画像**: `ancient_altar_chamber.png`
**設定**: 石造りの古い祭壇がある神秘的な部屋。松明で照らされ、古代文字が壁に刻まれている。

**背景画像生成プロンプト**:
```
ancient underground altar chamber, dark stone room with rough-hewn walls, massive black stone altar at center with mysterious carvings, ancient runic inscriptions covering walls, flickering torches in iron sconces providing dramatic lighting and shadows, no windows, purely underground atmosphere, moss and moisture on stone walls, aged bronze brazier with eternal flames, mystical crystal formations, archaeological ancient ruin feeling, primitive but sacred atmosphere, mysterious glowing symbols, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `stone_altar` | 古代祭壇 | 黒い石で作られた神秘的な祭壇 | アイテム取得 | なし | `ritual_crystal` | 🔮 儀式の水晶 |
| `wall_inscriptions` | 壁面碑文 | 古代文字で刻まれた神秘的な文字 | 調査 | なし | なし | 📜 古代の警告 |
| `torch_brazier` | 松明台 | 永遠の炎が灯る古い松明台 | 調査 | なし | なし | 🔥 神秘の炎 |
| `secret_passage_c` | 隠し通路C | 祭壇の後ろの隠された通路 | 隠し部屋遷移 | `ritual_crystal` | なし | 🔮 隠し部屋Cへ |

### 儀式の間（undergroundLeft）
**背景画像**: `ritual_chamber.png`
**設定**: 複雑な魔法陣が床に描かれた儀式用の部屋。古代の力が宿る。

**背景画像生成プロンプト**:
```
ancient ritual chamber underground, stone floor with enormous intricate magical circle carved deep into stone, complex geometric patterns and mystical symbols, natural crystal formations jutting from walls and floor, multiple bronze braziers with blue-white flames, no natural light, all illumination from magical sources, stone walls with ancient carvings, stalactites hanging from ceiling, mysterious atmospheric mist, underground cavern feeling, ancient and powerful magical energy, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `grand_magic_circle` | 大魔法陣 | 床一面に描かれた巨大な魔法陣 | アイテム取得 | なし | `sacred_stone` | 🗿 聖なる石 |
| `crystal_formations` | 水晶群 | 自然に形成された美しい水晶 | 調査 | なし | なし | 💎 大地の力 |
| `ancient_braziers` | 古代の火鉢 | 儀式用の特別な火鉢 | 調査 | なし | なし | 🔥 儀式の炎 |

### 地下神殿中央（undergroundCenter）
**背景画像**: `underground_temple_center.png`
**設定**: 地下神殿の中心部。高い天井、柱、神秘的な光源。

**背景画像生成プロンプト**:
```
underground temple central chamber, grand stone architecture with high vaulted ceiling, massive carved stone pillars with ancient reliefs, mystical fountain at center with crystal-clear water and soft ethereal glow, large sealed stone door with glowing magical seals indicating powerful magic, no windows or natural light, illumination from magical sources and phosphorescent crystals in walls, ancient temple architecture, sacred and mystical atmosphere, underground cathedral feeling, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `temple_fountain` | 神殿の泉 | 清らかな水が湧く神秘的な泉 | アイテム取得 | なし | `pure_essence` | 💧 純粋なる精髄 |
| `stone_pillars` | 古代の柱 | 複雑な彫刻が施された石柱 | 調査 | なし | なし | 🏛️ 古代建築 |
| `temple_seal` | 神殿の封印 | 地下の力を封じる古代の封印 | 封印解除 | `liberation_orb` | `liberation_key` | ⭐ 最終封印解除 |

### 古代文字の書庫（undergroundRight）
**背景画像**: `ancient_scriptorium.png`
**設定**: 古代の巻物と石板が保管された地下書庫。知識の宝庫。

**背景画像生成プロンプト**:
```
ancient underground scriptorium library, stone chamber with carved stone shelves holding ancient scrolls and stone tablets, stone reading lectern in center, walls covered with hieroglyphic inscriptions and ancient scripts, no windows, underground atmosphere, torch lighting creating dramatic shadows, dusty scrolls and parchments, stone tablets with cuneiform writing, ancient knowledge repository feeling, mysterious scholarly atmosphere, archaeological site ambiance, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `stone_tablets` | 古代石板 | 古代文字で記された石の板 | 調査 | なし | なし | 📜 失われた知識 |
| `scroll_collection` | 巻物コレクション | 古代の巻物が保管された棚 | アイテム取得 | なし | `wisdom_scroll` | 📜 知恵の巻物 |
| `reading_lectern` | 古代書見台 | 石で作られた古い書見台 | 調査 | なし | なし | 📖 学者の場所 |

### 最終封印の間（undergroundRightmost）
**背景画像**: `final_seal_chamber.png`
**設定**: 地下の最も奥にある封印の間。古代の力が集約されている。

**背景画像生成プロンプト**:
```
final underground seal chamber, deepest part of ancient complex, ornate stone altar for final ritual at center, massive stone guardian statue watching over chamber, mystical energy source, glowing crystal formation with swirling energy, powerful magical seals and runes covering every surface, most sacred and powerful location, intense magical atmosphere, no natural light, dramatic magical illumination, ancient power concentrated here, detailed interior, game background art, 400x600
```

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `liberation_altar` | 解放の祭壇 | 最終的な封印解除を行う祭壇 | アイテム合成 | `ritual_crystal` + `sacred_stone` + `pure_essence` | `liberation_orb` | ⭐ 解放の宝珠作成 |
| `ancient_guardian` | 古代の守護者 | 石像の古代守護者 | 調査 | なし | なし | 🗿 封印の番人 |
| `power_source` | 力の源泉 | 古代の力が集約する神秘的な源泉 | 調査 | なし | なし | ⚡ 原初の力 |
---

## 隠し部屋（Hidden）- 1階からアクセス

### 隠し部屋A（hiddenA）- 秘密の宝物庫
**背景画像**: `hidden_room_a.png`
**設定**: 肖像画の後ろに隠された小さな宝物庫。古い財宝と秘密の書類が保管されている。
**アクセス**: 1階左の部屋（room_left）の肖像画から

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `hidden_treasure_chest` | 隠された宝箱 | 古い宝箱（鍵付き） | アイテム取得 | なし | `ancient_coin` | 💰 古代の金貨 |
| `secret_documents` | 秘密文書 | 伯爵の秘密の記録 | 調査 | なし | なし | 📜 館の秘密 |

### 隠し部屋B（hiddenB）- 錬金術師の隠れ研究室
**背景画像**: `hidden_room_b.png`
**設定**: 錬金術研究室の奥に隠された秘密の実験室。危険な実験が行われていた形跡がある。
**アクセス**: 1階右の部屋（room_right）の錬金術装置から

| ホットスポットID | 名前 | 説明 | ギミック | 必要アイテム | 取得アイテム | 特別機能 |
|------------------|------|------|---------|--------------|--------------|----------|
| `secret_apparatus` | 秘密の実験装置 | 高度な錬金術装置 | アイテム取得 | なし | `alchemical_essence` | ⚗️ 錬金術の精髄 |
| `forbidden_formulas` | 禁断の実験記録 | 危険な実験の記録書 | 調査 | なし | なし | 💀 禁断の知識 |

---

## アイテム画像生成プロンプト

### 基本アイテム（1階で取得）

**`noble_seal`** - 伯爵の印章
```
medieval nobleman's seal, ornate brass seal with intricate coat of arms design, noble heraldic symbols including lions and eagles, heavy substantial feel, aged patina, decorative engravings around edge, renaissance craftsmanship, detailed metalwork, game item art, 400x400
```

**`ancient_fragment`** - 古代の欠片
```
ancient stone fragment, weathered carved stone with partial ancient symbols visible, aged worn surface, mysterious archaeological artifact, neutral gray-brown stone color, carved text partially eroded, fits in palm, ancient civilization remnant, game item art, 400x400
```

**`mystic_herb`** - 神秘の薬草
```
mystical dried herb bundle, carefully bundled unusual plants with silvery-green leaves, dried flowers with slight luminescent quality, tied with natural twine, medieval alchemical ingredient, slightly magical appearance, herbs for potions and spells, organic texture, game item art, 400x400
```

**`chamber_key`** - 地下への鍵（合成品）
```
ancient ornate key, heavy bronze key with elaborate decorative head featuring mystical symbols, long shaft with complex teeth pattern, aged patina with magical energy, substantial weight, medieval craftsmanship, opens important doors, slightly glowing magical properties, game item art, 400x400
```

### 地下専用アイテム

**`ritual_crystal`** - 儀式の水晶
```
ritual crystal, clear purple quartz crystal with natural faceted surfaces, inner light visible within, used in ancient magical ceremonies, palm-sized, mystical properties, pure sacred appearance, slight ethereal glow, magical energy contained within, game item art, 400x400
```

**`sacred_stone`** - 聖なる石
```
sacred ceremonial stone, smooth dark stone with ancient carved symbols, perfectly rounded, used in religious rituals, deep black color, mystical engravings that catch light, substantial weight, smooth polished surface, ancient spiritual artifact, game item art, 400x400
```

**`pure_essence`** - 純粋なる精髄
```
pure magical essence in crystal vial, small glass bottle containing luminescent liquid that glows with soft white light, cork stopper, liquid appears to swirl with own energy, concentrated magical power in liquid form, ethereal and precious, medieval alchemical container, game item art, 400x400
```

**`wisdom_scroll`** - 知恵の巻物
```
ancient wisdom scroll, aged parchment rolled and tied with leather cord, partially unrolled showing ancient script and mystical diagrams, yellowed with age, contains secret knowledge, medieval manuscript style, scholarly artifact, mysterious ancient writing visible, game item art, 400x400
```

**`liberation_orb`** - 解放の宝珠（地下合成品）
```
liberation orb, spherical magical artifact combining crystal stone and liquid essence, multi-layered construction showing all three component materials integrated, glows with powerful magical energy, swirling energy patterns within, most powerful magical item, combination of all underground elements, intense magical aura, game item art, 400x400
```

### 脱出システムアイテム

**`liberation_key`** - 解放の鍵（最終ゲームクリア用）
```
ultimate liberation key, magnificent key forged from magical energies, appears made of crystallized light and ancient metals, intricate design incorporating elements from all previous items, powerful magical aura, most important key in game, capable of breaking strongest seals, divine craftsmanship, intense magical glow, game item art, 400x400
```

---

## 特別ギミック・アイテムシステム

### 主要ギミック一覧

| ギミック名 | 必要アイテム | 生成アイテム | 実行場所 | 説明 | 重要度 |
|------------|--------------|--------------|----------|------|--------|
| **古代印章合成** | `noble_seal` + `ancient_fragment` | `chamber_key` | 大図書室・机 | 地下への鍵作成 | ⭐⭐⭐ |
| **解放の宝珠作成** | `ritual_crystal` + `sacred_stone` + `pure_essence` | `liberation_orb` | 最終封印の間・祭壇 | 封印解除用宝珠 | ⭐⭐⭐ |
| **最終封印解除** | `liberation_orb` → 消費 | `liberation_key` | 地下神殿中央・封印 | 脱出鍵取得 | ⭐⭐⭐ |
| **地下フロア解放** | `chamber_key` → 消費 | - | 使用人通路・地下入口 | 地下フロアアクセス | ⭐⭐ |
| **ゲームクリア** | `liberation_key` → 消費 | - | 大図書室・正面扉 | ゲーム完了 | ⭐⭐⭐ |

---

## ゲーム進行フロー

### 基本プレイフロー
1. **大図書室（開始地点）** で脱出扉を確認（封印中）
2. **1階探索** で基本アイテム収集 (`noble_seal`, `ancient_fragment`)
3. **古代印章合成** (`noble_seal` + `ancient_fragment` → `chamber_key`)
4. **地下フロア解放** (`chamber_key` 使用)
5. **地下探索** で封印解除素材収集 (3つの地下素材取得)
6. **解放の宝珠作成** (地下3素材合成)
7. **最終封印解除** (`liberation_orb` → `liberation_key`)
8. **隠し部屋探索** (オプション)
9. **大図書室で脱出** (`liberation_key` 使用)

### 推奨探索順序
1. 大図書室での状況確認
2. 1階全部屋の基本調査・アイテム収集
3. 古代印章合成・地下への鍵作成
4. 地下フロア解放・探索
5. 地下素材収集・解放の宝珠作成
6. 最終封印解除・脱出鍵取得
7. 隠し部屋発見・探索（オプション）
8. ゲームクリア

---

## 生成パラメータ設定

### 推奨設定（Counterfeit-V3.0 + isometric_dreams）
```javascript
{
  "model": "Counterfeit-V3.0_fp16.safetensors",
  "lora": "isometric_dreams.safetensors",
  "lora_strength": 0.7,
  "width": 400,
  "height": 600,
  "steps": 20,
  "cfg_scale": 7.0,
  "sampler": "euler",
  "negative_prompt": "blurry, low quality, modern elements, people, characters, text, watermark, UI elements, buttons, logos"
}
```

### 画像生成における重要な統一要素
- **サイズ**: 背景画像400x600、アイテム画像400x400で統一
- **スタイル**: Counterfeit-V3.0の自然なアニメ風品質を活用
- **1階の特徴**: 自然光、窓、豪華な装飾、Renaissance Gothic architecture
- **地下の特徴**: 松明照明、石造り、神秘的な雰囲気、古代遺跡感
- **アイテムの特徴**: 中世風、実用性と神秘性のバランス、物語との整合性

### システム制約
- ホットスポット座標は400×600統一背景サイズ基準
- アイテム管理は`InventorySystem`シングルトンで統一
- 部屋遷移は既存のシステムを維持
- デバッグ時のみホットスポット境界可視化

このコンテンツマップは既存のCounterfeit-V3.0 + isometric_dreamsモデルとの統合性を重視し、物語性と視覚的一貫性を実現する設計になっています。