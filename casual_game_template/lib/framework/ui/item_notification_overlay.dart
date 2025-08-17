import 'package:flutter/material.dart';
import '../../gen/assets.gen.dart';
import '../../game/components/room_hotspot_system.dart';

/// Flutter Widgetベースのアイテム取得通知オーバーレイ
/// ゲーム画面の上に表示される横長の通知バー
class ItemNotificationOverlay extends StatefulWidget {
  const ItemNotificationOverlay({super.key});

  @override
  State<ItemNotificationOverlay> createState() => _ItemNotificationOverlayState();
}

class _ItemNotificationOverlayState extends State<ItemNotificationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  bool _isVisible = false;
  String _itemName = '';
  String _description = '';
  AssetGenImage? _itemAsset;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // 画面下から
      end: const Offset(0.0, 0.0),   // 表示位置
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    // アイテム発見コールバックを設定
    _setupItemDiscoveryCallback();
  }
  
  /// ホットスポットシステムにアイテム発見コールバックを設定
  void _setupItemDiscoveryCallback() {
    final hotspotSystem = RoomHotspotSystem();
    hotspotSystem.setItemDiscoveryCallback(_showNotification);
  }
  
  /// 通知を表示
  void _showNotification({
    required String itemId,
    required String itemName,
    required String description,
    required AssetGenImage itemAsset,
  }) {
    if (_isVisible) return;
    
    setState(() {
      _itemName = itemName;
      _description = description;
      _itemAsset = itemAsset;
      _isVisible = true;
    });
    
    _animationController.forward();
    
    debugPrint('🎊 Notification overlay: Showing $itemName');
    
    // 3秒後に自動的に非表示
    Future.delayed(const Duration(seconds: 3), () {
      _hideNotification();
    });
  }
  
  /// 通知を非表示
  void _hideNotification() {
    if (!_isVisible) return;
    
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
          _itemName = '';
          _description = '';
          _itemAsset = null;
        });
      }
    });
    
    debugPrint('🎊 Notification overlay: Hidden');
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _itemAsset == null) {
      return const SizedBox.shrink();
    }
    
    return Material(
      elevation: 100, // モーダルより高いelevation
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      child: Container(
        height: 120.0, // インベントリと同じ高さ
        child: SlideTransition(
          position: _slideAnimation,
          child: _buildNotificationCard(),
        ),
      ),
    );
  }
  
  /// 通知カードを構築
  Widget _buildNotificationCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.9),
        border: Border.all(
          color: Colors.yellow,
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // アイテムアイコン
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.yellow.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: _itemAsset!.image(
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.yellow.withValues(alpha: 0.3),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.yellow,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // テキスト部分
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // タイトル
                Text(
                  '✨ $_itemName を手に入れました！',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansJP',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // 説明
                Text(
                  _description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'NotoSansJP',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}