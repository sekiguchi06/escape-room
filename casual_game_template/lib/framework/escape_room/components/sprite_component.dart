import 'package:flame/components.dart';

/// 画像表示コンポーネント
/// 🎯 目的: スプライト管理機能を提供
class SpriteRenderComponent extends Component {
  final Map<String, Sprite> _sprites = {};
  String _currentState = '';
  SpriteComponent? _spriteComponent;
  
  /// スプライトセット読み込み
  Future<void> loadSpriteSet(Map<String, String> spritePaths) async {
    for (final entry in spritePaths.entries) {
      try {
        _sprites[entry.key] = await Sprite.load(entry.value);
        print('Loaded sprite: ${entry.key} from ${entry.value}');
      } catch (e) {
        print('Failed to load sprite: ${entry.key} from ${entry.value}, error: $e');
      }
    }
  }
  
  /// 初期状態設定
  void setInitialState(String state) {
    if (_sprites.containsKey(state)) {
      _currentState = state;
      _updateSprite();
    }
  }
  
  /// 状態切り替え
  void switchToState(String state) {
    if (_sprites.containsKey(state)) {
      _currentState = state;
      _updateSprite();
    }
  }
  
  /// アクティブ状態切り替え
  void switchToActivatedState() {
    switchToState('active');
  }
  
  /// 現在の状態取得
  String get currentState => _currentState;
  
  void _updateSprite() {
    if (_spriteComponent != null) {
      remove(_spriteComponent!);
      _spriteComponent = null;
    }
    
    if (_sprites.containsKey(_currentState)) {
      _spriteComponent = SpriteComponent(sprite: _sprites[_currentState]!);
      if (parent != null) {
        _spriteComponent!.size = (parent as PositionComponent).size;
      }
      add(_spriteComponent!);
      print('Updated sprite to state: $_currentState');
    }
  }
  
  /// リソース解放
  void dispose() {
    _sprites.clear();
    if (_spriteComponent != null) {
      parent?.remove(_spriteComponent!);
      _spriteComponent = null;
    }
  }
}