import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'modal_config.dart';
import 'ui_system.dart';
import 'number_puzzle_input_component.dart';
import 'japanese_message_system.dart';

/// モーダル表示戦略インターフェース
/// Strategy Pattern適用による表示方法の抽象化
abstract interface class ModalDisplayStrategy {
  /// 戦略名取得
  String get strategyName;
  
  /// 対応可能なモーダルタイプ判定
  bool canHandle(ModalType type);
  
  /// モーダルUI要素作成
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  );
  
  /// 入力検証（パズル等）
  bool validateInput(String input, ModalConfig config);
  
  /// 確認処理実行
  void executeConfirm(ModalConfig config, String? userInput);
}

/// アイテム表示戦略
/// Single Responsibility Principle適用
class ItemDisplayStrategy implements ModalDisplayStrategy {
  @override
  String get strategyName => 'item_display';
  
  @override
  bool canHandle(ModalType type) => type == ModalType.item;
  
  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🎁 Creating item modal UI: ${config.title}');
    
    final elements = ModalUIElements();
    
    // 正方形サイズ計算（横幅の80%）
    final squareSize = modalSize.x * 0.8;
    final squarePanelSize = Vector2(squareSize, squareSize);
    final squarePanelPosition = Vector2(
      (modalSize.x - squareSize) / 2,
      (modalSize.y - squareSize) / 2,
    );
    
    // 背景オーバーレイ
    elements.background = RectangleComponent(
      size: modalSize,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
    
    // 正方形モーダルパネル
    elements.modalPanel = RectangleComponent(
      position: squarePanelPosition,
      size: squarePanelSize,
      paint: Paint()..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    
    // 画像表示（本棚画像をデフォルトで使用）
    final imagePath = config.imagePath.isNotEmpty 
        ? config.imagePath 
        : 'hotspots/bookshelf_full.png';
    
    elements.imageComponent = SpriteComponent()
      ..position = Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.15,
      )
      ..size = Vector2(
        squarePanelSize.x * 0.8,
        squarePanelSize.y * 0.65,
      );
    
    // 画像を非同期で読み込み
    _loadImage(elements.imageComponent!, imagePath);
    
    // タイトル（画像の下に配置）
    elements.titleText = TextComponent(
      text: config.title,
      textRenderer: JapaneseFontSystem.getTextPaint(20, Colors.blue, FontWeight.bold),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.85,
      ),
      anchor: Anchor.center,
    );
    
    // アイテム説明（タイトルの下）
    elements.contentText = TextComponent(
      text: config.content,
      textRenderer: JapaneseFontSystem.getTextPaint(14, Colors.black87),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.92,
      ),
      anchor: Anchor.center,
    );
    
    return elements;
  }
  
  /// 画像を非同期で読み込み
  Future<void> _loadImage(SpriteComponent component, String imagePath) async {
    try {
      component.sprite = await Sprite.load(imagePath);
    } catch (e) {
      debugPrint('❌ Failed to load modal image $imagePath: $e');
      // 画像読み込み失敗時は透明にする
      component.paint = Paint()..color = Colors.transparent;
    }
  }
  
  @override
  bool validateInput(String input, ModalConfig config) {
    // アイテム表示は入力検証不要
    return true;
  }
  
  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    debugPrint('🎁 Item modal confirmed: ${config.data['itemId'] ?? 'unknown'}');
    config.onConfirm?.call();
  }
}

/// パズル入力戦略
/// Strategy Pattern + Component組み合わせ
class PuzzleInputStrategy implements ModalDisplayStrategy {
  @override
  String get strategyName => 'puzzle_input';
  
  @override
  bool canHandle(ModalType type) => type == ModalType.puzzle;
  
  /// 画像を非同期で読み込み
  Future<void> _loadImage(SpriteComponent component, String imagePath) async {
    try {
      component.sprite = await Sprite.load(imagePath);
    } catch (e) {
      debugPrint('❌ Failed to load modal image $imagePath: $e');
      // 画像読み込み失敗時は透明にする
      component.paint = Paint()..color = Colors.transparent;
    }
  }
  
  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🧩 Creating puzzle modal UI: ${config.title}');
    
    final elements = ModalUIElements();
    
    // 正方形サイズ計算（横幅の80%）
    final squareSize = modalSize.x * 0.8;
    final squarePanelSize = Vector2(squareSize, squareSize);
    final squarePanelPosition = Vector2(
      (modalSize.x - squareSize) / 2,
      (modalSize.y - squareSize) / 2,
    );
    
    // 背景オーバーレイ
    elements.background = RectangleComponent(
      size: modalSize,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
    
    // 正方形パズル専用パネル
    elements.modalPanel = RectangleComponent(
      position: squarePanelPosition,
      size: squarePanelSize,
      paint: Paint()..color = Colors.white,
    );
    
    // 画像表示（本棚画像をデフォルトで使用）
    final imagePath = config.imagePath.isNotEmpty 
        ? config.imagePath 
        : 'hotspots/bookshelf_full.png';
    
    elements.imageComponent = SpriteComponent()
      ..position = Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.1,
      )
      ..size = Vector2(
        squarePanelSize.x * 0.8,
        squarePanelSize.y * 0.5,
      );
    
    // 画像を非同期で読み込み
    _loadImage(elements.imageComponent!, imagePath);
    
    // タイトル（パズル名）
    elements.titleText = TextComponent(
      text: config.title,
      textRenderer: JapaneseFontSystem.getTextPaint(20, Colors.orange, FontWeight.bold),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.65,
      ),
      anchor: Anchor.center,
    );
    
    // パズル説明
    elements.contentText = TextComponent(
      text: config.content,
      textRenderer: JapaneseFontSystem.getTextPaint(14, Colors.black87),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.72,
      ),
      anchor: Anchor.center,
    );
    
    // パズル入力コンポーネント
    final correctAnswer = config.data['correctAnswer'] as String? ?? '';
    elements.puzzleInput = NumberPuzzleInputComponent(
      correctAnswer: correctAnswer,
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.78,
      ),
      size: Vector2(squarePanelSize.x * 0.8, squarePanelSize.y * 0.15),
    );
    
    return elements;
  }
  
  @override
  bool validateInput(String input, ModalConfig config) {
    final correctAnswer = config.data['correctAnswer'] as String? ?? '';
    final isCorrect = input.trim() == correctAnswer.trim();
    debugPrint('🧩 Puzzle validation: input="$input", correct="$correctAnswer", result=$isCorrect');
    return isCorrect;
  }
  
  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    if (userInput != null && validateInput(userInput, config)) {
      debugPrint('🧩 Puzzle solved correctly: ${config.title}');
      config.onConfirm?.call();
    } else {
      debugPrint('🧩 Puzzle answer incorrect: ${config.title}');
      // 不正解時の処理（振動、エラー音等）
    }
  }
}

/// 調査表示戦略
/// オブジェクト詳細調査用
class InspectionDisplayStrategy implements ModalDisplayStrategy {
  @override
  String get strategyName => 'inspection_display';
  
  @override
  bool canHandle(ModalType type) => type == ModalType.inspection;
  
  /// 画像を非同期で読み込み
  Future<void> _loadImage(SpriteComponent component, String imagePath) async {
    try {
      component.sprite = await Sprite.load(imagePath);
    } catch (e) {
      debugPrint('❌ Failed to load modal image $imagePath: $e');
      // 画像読み込み失敗時は透明にする
      component.paint = Paint()..color = Colors.transparent;
    }
  }
  
  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🔍 Creating inspection modal UI: ${config.title}');
    
    final elements = ModalUIElements();
    
    // 正方形サイズ計算（横幅の80%）
    final squareSize = modalSize.x * 0.8;
    final squarePanelSize = Vector2(squareSize, squareSize);
    final squarePanelPosition = Vector2(
      (modalSize.x - squareSize) / 2,
      (modalSize.y - squareSize) / 2,
    );
    
    // 背景オーバーレイ
    elements.background = RectangleComponent(
      size: modalSize,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
    
    // 正方形調査専用パネル
    elements.modalPanel = RectangleComponent(
      position: squarePanelPosition,
      size: squarePanelSize,
      paint: Paint()..color = Colors.white,
    );
    
    // 画像表示（本棚画像をデフォルトで使用）
    final imagePath = config.imagePath.isNotEmpty 
        ? config.imagePath 
        : 'hotspots/bookshelf_full.png';
    
    elements.imageComponent = SpriteComponent()
      ..position = Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.15,
      )
      ..size = Vector2(
        squarePanelSize.x * 0.8,
        squarePanelSize.y * 0.65,
      );
    
    // 画像を非同期で読み込み
    _loadImage(elements.imageComponent!, imagePath);
    
    // タイトル（調査対象）
    elements.titleText = TextComponent(
      text: '🔍 ${config.title}',
      textRenderer: JapaneseFontSystem.getTextPaint(20, Colors.green, FontWeight.bold),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.85,
      ),
      anchor: Anchor.center,
    );
    
    // 調査結果
    elements.contentText = TextComponent(
      text: config.content,
      textRenderer: JapaneseFontSystem.getTextPaint(14, Colors.black87),
      position: Vector2(
        squarePanelPosition.x + squarePanelSize.x / 2,
        squarePanelPosition.y + squarePanelSize.y * 0.92,
      ),
      anchor: Anchor.center,
    );
    
    return elements;
  }
  
  @override
  bool validateInput(String input, ModalConfig config) {
    // 調査表示は入力検証不要
    return true;
  }
  
  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    debugPrint('🔍 Inspection completed: ${config.data['objectId'] ?? 'unknown'}');
    config.onConfirm?.call();
  }
}

/// モーダルUI要素格納クラス
/// Component-based設計準拠
class ModalUIElements {
  late RectangleComponent background;
  late RectangleComponent modalPanel;
  late TextComponent titleText;
  late TextComponent contentText;
  SpriteComponent? imageComponent;
  NumberPuzzleInputComponent? puzzleInput;
}

/// モーダル表示コンテキスト
/// Strategy Pattern使用の制御クラス
class ModalDisplayContext {
  final List<ModalDisplayStrategy> _strategies = [];
  ModalDisplayStrategy? _currentStrategy;
  
  /// 戦略追加
  void addStrategy(ModalDisplayStrategy strategy) {
    _strategies.add(strategy);
    debugPrint('📋 Modal strategy added: ${strategy.strategyName}');
  }
  
  /// デフォルト戦略を初期化
  void initializeDefaultStrategies() {
    addStrategy(ItemDisplayStrategy());
    addStrategy(PuzzleInputStrategy());
    addStrategy(InspectionDisplayStrategy());
    debugPrint('📋 Default modal strategies initialized: ${_strategies.length} strategies');
  }
  
  /// 適切な戦略を選択
  ModalDisplayStrategy? selectStrategy(ModalType type) {
    for (final strategy in _strategies) {
      if (strategy.canHandle(type)) {
        _currentStrategy = strategy;
        debugPrint('📋 Selected modal strategy: ${strategy.strategyName} for type: $type');
        return strategy;
      }
    }
    
    debugPrint('❌ No modal strategy found for type: $type');
    return null;
  }
  
  /// 現在の戦略取得
  ModalDisplayStrategy? get currentStrategy => _currentStrategy;
  
  /// 利用可能な戦略一覧
  List<String> get availableStrategies => _strategies.map((s) => s.strategyName).toList();
}