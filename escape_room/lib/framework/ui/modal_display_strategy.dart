import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'modal_config.dart';
import 'number_puzzle_input_component.dart';
import 'japanese_message_system.dart';
import 'concentration_lines_component.dart';
import '../effects/particle_system.dart';

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
        : 'hotspots/prison_bucket.png';
    
    // 安全な実装: RectangleComponentを使用
    elements.imageComponent = RectangleComponent(
      paint: Paint()..color = Colors.brown.withOpacity(0.5),
    )
      ..position = Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.15,
      )
      ..size = Vector2(
        squarePanelSize.x * 0.8,
        squarePanelSize.y * 0.65,
      );
    
    // 画像を非同期で読み込み
    
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
  Future<void> _loadImage(RectangleComponent component, String imagePath) async {
    // 無効化: モーダル画像は単色表示で統一
    try {
      // 無効化: 単色表示で統一
      debugPrint('Image loading disabled for stability: $imagePath');
    } catch (e) {
      debugPrint('❌ Failed to load modal image $imagePath: $e');
      // 画像読み込み失敗時は透明にする
      // 無効化: 既定の単色表示を維持
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
  Future<void> _loadImage(RectangleComponent component, String imagePath) async {
    // 無効化: モーダル画像は単色表示で統一
    try {
      // 無効化: 単色表示で統一
      debugPrint('Image loading disabled for stability: $imagePath');
    } catch (e) {
      debugPrint('❌ Failed to load modal image $imagePath: $e');
      // 画像読み込み失敗時は透明にする
      // 無効化: 既定の単色表示を維持
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
        : 'hotspots/prison_bucket.png';
    
    // 安全な実装: RectangleComponentを使用
    elements.imageComponent = RectangleComponent(
      paint: Paint()..color = Colors.brown.withOpacity(0.5),
    )
      ..position = Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.1,
      )
      ..size = Vector2(
        squarePanelSize.x * 0.8,
        squarePanelSize.y * 0.5,
      );
    
    // 画像を非同期で読み込み
    
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
      config.onPuzzleSuccess?.call(); // パズル成功時のコールバック呼び出し
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
  Future<void> _loadImage(RectangleComponent component, String imagePath) async {
    // 無効化: モーダル画像は単色表示で統一
    try {
      // 無効化: 単色表示で統一
      debugPrint('Image loading disabled for stability: $imagePath');
    } catch (e) {
      debugPrint('❌ Failed to load modal image $imagePath: $e');
      // 画像読み込み失敗時は透明にする
      // 無効化: 既定の単色表示を維持
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
        : 'hotspots/prison_bucket.png';
    
    // 安全な実装: RectangleComponentを使用
    elements.imageComponent = RectangleComponent(
      paint: Paint()..color = Colors.brown.withOpacity(0.5),
    )
      ..position = Vector2(
        squarePanelPosition.x + squarePanelSize.x * 0.1,
        squarePanelPosition.y + squarePanelSize.y * 0.15,
      )
      ..size = Vector2(
        squarePanelSize.x * 0.8,
        squarePanelSize.y * 0.65,
      );
    
    // 画像を非同期で読み込み
    
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

/// アイテム発見演出戦略
/// 下からスライド + 集中線 + パーティクルエフェクト
class ItemDiscoveryDisplayStrategy implements ModalDisplayStrategy {
  ConcentrationLinesManager? _concentrationLinesManager;
  ParticleEffectManager? _particleEffectManager;
  
  @override
  String get strategyName => 'item_discovery_display';
  
  @override
  bool canHandle(ModalType type) => type == ModalType.itemDiscovery;
  
  @override
  ModalUIElements createUIElements(
    ModalConfig config,
    Vector2 modalSize,
    Vector2 panelPosition,
    Vector2 panelSize,
  ) {
    debugPrint('🎊 Creating item discovery modal UI: ${config.title}');
    
    final elements = ModalUIElements();
    
    // アイテム画像サイズ（画面幅の60%）
    final imageSize = modalSize.x * 0.6;
    final imageDisplaySize = Vector2(imageSize, imageSize);
    
    // 最終位置（画面下80%の位置）
    final finalPosition = Vector2(
      (modalSize.x - imageSize) / 2,
      modalSize.y * 0.8 - imageSize,
    );
    
    // 開始位置（画面下120%の位置、見えない場所）
    final startPosition = Vector2(
      finalPosition.x,
      modalSize.y * 1.2,
    );
    
    // 背景オーバーレイ（少し暗め）
    elements.background = RectangleComponent(
      size: modalSize,
      paint: Paint()..color = Colors.black.withValues(alpha: 0.7),
    );
    
    // アイテム背景パネル（円形に近い角丸）
    elements.modalPanel = RectangleComponent(
      position: finalPosition,
      size: imageDisplaySize,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    
    // アイテム画像
    final imagePath = config.imagePath.isNotEmpty 
        ? config.imagePath 
        : 'hotspots/prison_bucket.png';
    
    // 安全な実装: RectangleComponentを使用
    elements.imageComponent = RectangleComponent(
      paint: Paint()..color = Colors.brown.withOpacity(0.5),
    )
      ..position = Vector2(
        finalPosition.x + imageDisplaySize.x * 0.1,
        finalPosition.y + imageDisplaySize.y * 0.1,
      )
      ..size = Vector2(
        imageDisplaySize.x * 0.8,
        imageDisplaySize.y * 0.8,
      );
    
    // 画像を非同期で読み込み
    
    // タイトル（画像の下）
    elements.titleText = TextComponent(
      text: config.title,
      textRenderer: JapaneseFontSystem.getTextPaint(24, Colors.yellow, FontWeight.bold),
      position: Vector2(
        finalPosition.x + imageDisplaySize.x / 2,
        finalPosition.y + imageDisplaySize.y + 20,
      ),
      anchor: Anchor.center,
    );
    
    // 説明文（タイトルの下）
    elements.contentText = TextComponent(
      text: config.content,
      textRenderer: JapaneseFontSystem.getTextPaint(16, Colors.white),
      position: Vector2(
        finalPosition.x + imageDisplaySize.x / 2,
        finalPosition.y + imageDisplaySize.y + 50,
      ),
      anchor: Anchor.center,
    );
    
    // アニメーション効果を追加
    _addAnimationEffects(elements, startPosition, finalPosition, modalSize);
    
    return elements;
  }
  
  /// アニメーション効果を追加
  void _addAnimationEffects(
    ModalUIElements elements,
    Vector2 startPosition,
    Vector2 finalPosition,
    Vector2 modalSize,
  ) {
    // モーダルパネルの初期位置を開始位置に設定
    elements.modalPanel.position = startPosition.clone();
    
    // スライドアップアニメーション
    final slideEffect = MoveToEffect(
      finalPosition,
      EffectController(
        duration: 0.8,
        curve: Curves.bounceOut,
      ),
    );
    elements.modalPanel.add(slideEffect);
    
    // スケールアニメーション（小さく始まって通常サイズに）
    elements.modalPanel.scale = Vector2.all(0.3);
    final scaleEffect = ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(
        duration: 0.8,
        curve: Curves.elasticOut,
      ),
    );
    elements.modalPanel.add(scaleEffect);
    
    // フェードインアニメーション
    elements.modalPanel.opacity = 0.0;
    final fadeEffect = OpacityEffect.to(
      1.0,
      LinearEffectController(0.5),
    );
    elements.modalPanel.add(fadeEffect);
    
    // 集中線エフェクト（遅延実行）
    Future.delayed(const Duration(milliseconds: 300), () {
      final center = Vector2(
        finalPosition.x + elements.modalPanel.size.x / 2,
        finalPosition.y + elements.modalPanel.size.y / 2,
      );
      
      _concentrationLinesManager?.playConcentrationLines(
        effectId: 'item_discovery',
        center: center,
        maxRadius: 400.0,
        lineCount: 32,
        lineColor: Colors.orange,
        animationDuration: 1.5,
      );
    });
    
    // パーティクルエフェクト（さらに遅延実行）
    Future.delayed(const Duration(milliseconds: 500), () {
      final center = Vector2(
        finalPosition.x + elements.modalPanel.size.x / 2,
        finalPosition.y + elements.modalPanel.size.y / 2,
      );
      
      _particleEffectManager?.playEffect('itemDiscovery', center);
    });
  }
  
  /// 画像を非同期で読み込み
  Future<void> _loadImage(RectangleComponent component, String imagePath) async {
    // 無効化: モーダル画像は単色表示で統一
    try {
      // 無効化: 単色表示で統一
      debugPrint('Image loading disabled for stability: $imagePath');
    } catch (e) {
      debugPrint('❌ Failed to load item discovery image $imagePath: $e');
      // 無効化: 既定の単色表示を維持
    }
  }
  
  /// エフェクトマネージャーを設定
  void setEffectManagers({
    ConcentrationLinesManager? concentrationLinesManager,
    ParticleEffectManager? particleEffectManager,
  }) {
    _concentrationLinesManager = concentrationLinesManager;
    _particleEffectManager = particleEffectManager;
  }
  
  @override
  bool validateInput(String input, ModalConfig config) {
    // アイテム発見演出は入力検証不要
    return true;
  }
  
  @override
  void executeConfirm(ModalConfig config, String? userInput) {
    debugPrint('🎊 Item discovery confirmed: ${config.data['itemId'] ?? 'unknown'}');
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
  RectangleComponent? imageComponent;
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
    addStrategy(ItemDiscoveryDisplayStrategy());
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