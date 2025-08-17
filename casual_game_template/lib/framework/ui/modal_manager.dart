import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'escape_room_modal_system.dart';
import 'modal_config.dart';
import 'concentration_lines_component.dart';
import '../effects/particle_system.dart';

/// モーダルマネージャー
/// 複数モーダルの管理とスタック処理
/// Component-based設計準拠、単一責任原則適用
class ModalManager extends Component {
  final List<ModalComponent> _modalStack = [];
  
  // エフェクトマネージャーの参照
  ConcentrationLinesManager? _concentrationLinesManager;
  ParticleEffectManager? _particleEffectManager;
  
  /// エフェクトマネージャーを設定
  void setEffectManagers({
    ConcentrationLinesManager? concentrationLinesManager,
    ParticleEffectManager? particleEffectManager,
  }) {
    _concentrationLinesManager = concentrationLinesManager;
    _particleEffectManager = particleEffectManager;
    debugPrint('🎊 ModalManager: Effect managers set');
  }
  
  /// モーダル表示
  void showModal(ModalConfig config, Vector2 screenSize) {
    debugPrint('🎊 ModalManager: Showing modal type: ${config.type}');
    
    final modal = ModalComponent(
      config: config,
      size: screenSize,
      concentrationLinesManager: _concentrationLinesManager,
      particleEffectManager: _particleEffectManager,
    );
    
    _modalStack.add(modal);
    add(modal);
    modal.show();
    
    debugPrint('🎊 ModalManager: Modal added to stack, count: ${_modalStack.length}');
  }
  
  /// 最前面のモーダルを閉じる
  void hideTopModal() {
    if (_modalStack.isNotEmpty) {
      final modal = _modalStack.removeLast();
      modal.hide();
      remove(modal);
    }
  }
  
  /// 全モーダルを閉じる
  void hideAllModals() {
    for (final modal in _modalStack.reversed) {
      modal.hide();
      remove(modal);
    }
    _modalStack.clear();
  }
  
  /// モーダルが表示中かチェック
  bool get hasActiveModal => _modalStack.isNotEmpty;
  
  /// 表示中のモーダル数
  int get modalCount => _modalStack.length;
  
  /// 最前面のモーダル取得
  ModalComponent? get topModal => _modalStack.isNotEmpty ? _modalStack.last : null;
}