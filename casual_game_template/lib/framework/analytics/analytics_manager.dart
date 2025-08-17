import 'analytics_models.dart';
import 'analytics_configuration.dart';
import 'analytics_providers.dart';

/// 分析マネージャー
class AnalyticsManager {
  AnalyticsProvider _provider;
  AnalyticsConfiguration _configuration;
  final List<AnalyticsEvent> _eventQueue = [];
  DateTime _lastBatchSend = DateTime.now();
  String? _currentSessionId;
  int _sessionEventCount = 0;
  final Map<String, int> _eventCounts = {};
  
  AnalyticsManager({
    required AnalyticsProvider provider,
    required AnalyticsConfiguration configuration,
  }) : _provider = provider, _configuration = configuration;
  
  /// 現在のプロバイダー
  AnalyticsProvider get provider => _provider;
  
  /// 現在の設定
  AnalyticsConfiguration get configuration => _configuration;
  
  /// 現在のセッションID
  String? get currentSessionId => _currentSessionId;
  
  /// 初期化
  Future<bool> initialize() async {
    final success = await _provider.initialize(_configuration);
    
    if (success && _configuration.autoTrackingEnabled) {
      // 自動セッション開始
      await startSession();
    }
    
    return success;
  }
  
  /// プロバイダー変更
  Future<void> setProvider(AnalyticsProvider newProvider) async {
    // 残りのイベントを送信
    await flushEvents();
    
    await _provider.dispose();
    _provider = newProvider;
    await _provider.initialize(_configuration);
  }
  
  /// 設定更新
  Future<void> updateConfiguration(AnalyticsConfiguration newConfiguration) async {
    _configuration = newConfiguration;
    await _provider.updateConfiguration(_configuration);
  }
  
  /// イベント追跡
  Future<bool> trackEvent(String eventName, {
    Map<String, dynamic> parameters = const {},
    EventPriority priority = EventPriority.medium,
  }) async {
    final event = AnalyticsEvent(
      name: eventName,
      parameters: parameters,
      priority: priority,
      timestamp: DateTime.now(),
      userId: null,  // プロバイダーで設定
      sessionId: _currentSessionId,
    );
    
    return await _trackEvent(event);
  }
  
  Future<bool> _trackEvent(AnalyticsEvent event) async {
    // 統計更新
    _eventCounts[event.name] = (_eventCounts[event.name] ?? 0) + 1;
    _sessionEventCount++;
    
    // キューに追加
    _eventQueue.add(event);
    
    // バッチ送信チェック
    await _checkBatchSend();
    
    return true;
  }
  
  /// バッチ送信チェック
  Future<void> _checkBatchSend() async {
    final now = DateTime.now();
    final elapsed = now.difference(_lastBatchSend).inSeconds;
    
    if (_eventQueue.length >= _configuration.batchSize || 
        elapsed >= _configuration.batchInterval) {
      await flushEvents();
    }
  }
  
  /// イベント即座送信
  Future<bool> flushEvents() async {
    if (_eventQueue.isEmpty) return true;
    
    final eventsToSend = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();
    
    final success = await _provider.trackEventBatch(eventsToSend);
    
    if (success) {
      _lastBatchSend = DateTime.now();
    } else {
      // 失敗時はキューに戻す（オフライン対応）
      if (_configuration.offlineEventsEnabled) {
        _eventQueue.insertAll(0, eventsToSend);
        
        // 最大イベント数チェック
        if (_eventQueue.length > _configuration.maxOfflineEvents) {
          _eventQueue.removeRange(0, _eventQueue.length - _configuration.maxOfflineEvents);
        }
      }
    }
    
    return success;
  }
  
  /// セッション開始
  Future<bool> startSession() async {
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessionEventCount = 0;
    
    final success = await _provider.startSession(_currentSessionId!);
    
    if (success && _configuration.autoTrackingEnabled) {
      await trackEvent('session_start', parameters: {
        'session_id': _currentSessionId!,
      });
    }
    
    return success;
  }
  
  /// セッション終了
  Future<bool> endSession() async {
    if (_currentSessionId == null) return true;
    
    if (_configuration.autoTrackingEnabled) {
      await trackEvent('session_end', parameters: {
        'session_id': _currentSessionId!,
        'session_event_count': _sessionEventCount,
        'session_duration_seconds': 0,  // 実際の実装では計算が必要
      });
    }
    
    await flushEvents();
    
    final success = await _provider.endSession(_currentSessionId!);
    _currentSessionId = null;
    
    return success;
  }
  
  /// ユーザーID設定
  Future<bool> setUserId(String userId) async {
    return await _provider.setUserId(userId);
  }
  
  /// ユーザープロパティ設定
  Future<bool> setUserProperty(String name, String value) async {
    return await _provider.setUserProperty(name, value);
  }
  
  /// 画面表示追跡
  Future<bool> trackScreenView(String screenName) async {
    return await _provider.trackScreenView(screenName);
  }
  
  /// エラー追跡
  Future<bool> trackError(String error, {String? stackTrace}) async {
    return await _provider.trackError(error, stackTrace);
  }
  
  /// カスタムメトリクス送信
  Future<bool> trackMetric(String name, double value) async {
    return await _provider.trackMetric(name, value);
  }
  
  /// ゲーム固有イベント
  Future<bool> trackGameStart({Map<String, dynamic> gameConfig = const {}}) async {
    return await trackEvent('game_start', 
      parameters: gameConfig,
      priority: EventPriority.high,
    );
  }
  
  Future<bool> trackGameEnd({
    required int score,
    required Duration duration,
    Map<String, dynamic> additionalData = const {},
  }) async {
    return await trackEvent('game_end', parameters: {
      'score': score,
      'duration_seconds': duration.inSeconds,
      ...additionalData,
    }, priority: EventPriority.high);
  }
  
  Future<bool> trackLevelComplete({
    required int level,
    required int score,
    required Duration duration,
  }) async {
    return await trackEvent('level_complete', parameters: {
      'level': level,
      'score': score,
      'duration_seconds': duration.inSeconds,
    }, priority: EventPriority.high);
  }
  
  Future<bool> trackAdShown({
    required String adType,
    required String adId,
  }) async {
    return await trackEvent('ad_shown', parameters: {
      'ad_type': adType,
      'ad_id': adId,
    }, priority: EventPriority.medium);
  }
  
  Future<bool> trackPurchase({
    required String itemId,
    required double price,
    required String currency,
  }) async {
    return await trackEvent('purchase', parameters: {
      'item_id': itemId,
      'price': price,
      'currency': currency,
    }, priority: EventPriority.critical);
  }
  
  /// フレーム更新での定期処理
  void update() {
    // 定期的なバッチ送信チェック
    _checkBatchSend();
  }
  
  /// 統計情報取得
  Map<String, dynamic> getStatistics() {
    return {
      'session_id': _currentSessionId,
      'session_event_count': _sessionEventCount,
      'queued_events': _eventQueue.length,
      'event_counts': _eventCounts,
      'last_batch_send': _lastBatchSend.toIso8601String(),
      'total_tracked_events': _eventCounts.values.fold(0, (sum, count) => sum + count),
    };
  }
  
  /// デバッグ情報
  Map<String, dynamic> getDebugInfo() {
    return {
      'manager': runtimeType.toString(),
      'provider': _provider.runtimeType.toString(),
      'configuration': _configuration.runtimeType.toString(),
      'auto_tracking_enabled': _configuration.autoTrackingEnabled,
      'batch_size': _configuration.batchSize,
      'batch_interval': _configuration.batchInterval,
      'statistics': getStatistics(),
    };
  }
  
  /// リソース解放
  Future<void> dispose() async {
    await endSession();
    await flushEvents();
    await _provider.dispose();
  }
}