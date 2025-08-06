import 'package:flutter/foundation.dart';

/// Flutter公式準拠のゲーム状態管理システム
/// 
/// 参考ドキュメント:
/// - https://flutter.dev/docs/development/data-and-backend/state-mgmt
/// - https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html
/// - https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html
/// 
/// 設計原則:
/// 1. Flutter公式ChangeNotifierパターンを使用
/// 2. 複雑な状態遷移ロジックを排除し、シンプルな実装を重視
/// 3. providerパッケージとの統合を前提とした設計
/// 4. 既存APIとの互換性を維持

/// ゲーム状態の基底クラス
/// Flutter公式準拠: 状態オブジェクトはimmutableであることを推奨
abstract class GameState {
  const GameState();
  
  /// 状態の名前（デバッグ・ログ用）
  String get name;
  
  /// 状態の説明（オプション）
  String get description => name;
  
  /// 状態データ（JSON形式）
  /// Flutter公式: toJson()メソッドでシリアライゼーション対応
  Map<String, dynamic> toJson() => {'name': name, 'description': description};
  
  @override
  String toString() => name;
  
  @override
  bool operator ==(Object other) => other is GameState && other.name == name;
  
  @override
  int get hashCode => name.hashCode;
}

/// Flutter公式準拠のゲーム状態プロバイダー
/// 
/// ChangeNotifierを継承し、Flutter公式の状態管理パターンに従う
/// 複雑な状態遷移ロジックを排除し、シンプルなnotifyListeners()を使用
class FlutterGameStateProvider<T extends GameState> extends ChangeNotifier {
  T _currentState;
  
  // 統計情報（既存互換性のため保持）
  int _sessionCount = 0;
  int _totalStateChanges = 0;
  DateTime _sessionStartTime = DateTime.now();
  final Map<String, int> _stateVisitCounts = <String, int>{};
  final List<StateTransitionRecord<T>> _transitionHistory = <StateTransitionRecord<T>>[];
  
  /// Flutter公式推奨: コンストラクタで初期状態を設定
  FlutterGameStateProvider(this._currentState) {
    _recordStateVisit(_currentState);
  }
  
  /// 現在の状態を取得
  /// Flutter公式: getter推奨パターン
  T get currentState => _currentState;
  
  /// セッション数を取得
  int get sessionCount => _sessionCount;
  
  /// 総状態変更数を取得
  int get totalStateChanges => _totalStateChanges;
  
  /// セッション開始時刻を取得
  DateTime get sessionStartTime => _sessionStartTime;
  
  /// 状態訪問回数を取得（不変マップ）
  Map<String, int> get stateVisitCounts => Map.unmodifiable(_stateVisitCounts);
  
  /// 遷移履歴を取得（不変リスト）
  List<StateTransitionRecord<T>> get transitionHistory => List.unmodifiable(_transitionHistory);
  
  /// 状態遷移を実行
  /// 
  /// Flutter公式準拠: シンプルな状態変更 + notifyListeners()パターン
  /// 複雑な遷移チェックを排除し、ビジネスロジック側で制御
  void transitionTo(T newState) {
    if (_currentState == newState) {
      // 同じ状態への遷移はスキップ（パフォーマンス最適化）
      return;
    }
    
    final T oldState = _currentState;
    
    // Flutter公式パターン: 状態変更 + 通知
    _currentState = newState;
    
    // 統計情報更新
    _totalStateChanges++;
    _recordStateVisit(newState);
    _recordTransition(oldState, newState);
    
    // Flutter公式: 状態変更をリスナーに通知
    notifyListeners();
    
    // デバッグ出力
    debugPrint('State transition: ${oldState.name} -> ${newState.name}');
  }
  
  /// 強制的に状態を設定
  /// 
  /// Flutter公式準拠: ValueNotifierのvalueセッターと同様のパターン
  void forceSetState(T newState) {
    final T oldState = _currentState;
    _currentState = newState;
    
    // Flutter公式: 変更通知は必須
    notifyListeners();
    
    debugPrint('Force state change: ${oldState.name} -> ${newState.name}');
  }
  
  /// 新しいセッション開始
  /// 
  /// Flutter公式準拠: 単純なカウンター増加 + 通知
  void startNewSession() {
    _sessionCount++;
    _sessionStartTime = DateTime.now();
    notifyListeners(); // セッション変更も通知対象
    debugPrint('New session started: $_sessionCount');
  }
  
  /// セッション継続時間を取得
  Duration get sessionDuration => DateTime.now().difference(_sessionStartTime);
  
  /// 状態訪問を記録（内部メソッド）
  void _recordStateVisit(T state) {
    final String stateName = state.name;
    _stateVisitCounts[stateName] = (_stateVisitCounts[stateName] ?? 0) + 1;
  }
  
  /// 遷移を記録（内部メソッド）
  void _recordTransition(T from, T to) {
    final StateTransitionRecord<T> record = StateTransitionRecord<T>(
      from: from,
      to: to,
      timestamp: DateTime.now(),
    );
    _transitionHistory.add(record);
    
    // メモリ使用量制限（固定サイズキュー）
    if (_transitionHistory.length > 1000) {
      _transitionHistory.removeAt(0);
    }
  }
  
  /// 状態統計を取得
  /// 
  /// Flutter公式準拠: データクラスを返すパターン
  StateStatistics getStatistics() {
    return StateStatistics(
      currentState: _currentState.name,
      sessionCount: _sessionCount,
      totalStateChanges: _totalStateChanges,
      sessionDuration: sessionDuration,
      stateVisitCounts: _stateVisitCounts,
      mostVisitedState: _getMostVisitedState(),
      averageStateTransitionsPerSession: _sessionCount > 0 ? _totalStateChanges / _sessionCount : 0.0,
    );
  }
  
  /// 最も訪問された状態を取得（内部ヘルパー）
  String? _getMostVisitedState() {
    if (_stateVisitCounts.isEmpty) return null;
    
    return _stateVisitCounts.entries
        .reduce((MapEntry<String, int> a, MapEntry<String, int> b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// デバッグ情報を取得
  /// 
  /// Flutter公式準拠: Map<String, dynamic>でデバッグ情報を返す
  Map<String, dynamic> getDebugInfo() {
    return <String, dynamic>{
      'flutter_official_compliant': true, // Flutter公式準拠であることを明示
      'provider_type': 'ChangeNotifier', // 使用している状態管理パターン
      'currentState': _currentState.name,
      'sessionCount': _sessionCount,
      'totalStateChanges': _totalStateChanges,
      'sessionDuration': sessionDuration.inSeconds,
      'stateVisitCounts': _stateVisitCounts,
      'transitionHistorySize': _transitionHistory.length,
    };
  }
  
  /// Flutter公式: リソース解放時のクリーンアップ
  @override
  void dispose() {
    // 大きなリストのクリア（メモリリーク防止）
    _transitionHistory.clear();
    _stateVisitCounts.clear();
    
    // 親クラスのdisposeを必ず呼び出す
    super.dispose();
  }
}

/// 状態遷移記録クラス
/// 
/// Flutter公式準拠: immutableデータクラス
@immutable
class StateTransitionRecord<T extends GameState> {
  /// 遷移前の状態
  final T from;
  
  /// 遷移後の状態
  final T to;
  
  /// 遷移が発生した時刻
  final DateTime timestamp;
  
  /// コンストラクタ
  const StateTransitionRecord({
    required this.from,
    required this.to,
    required this.timestamp,
  });
  
  /// 次の遷移までの継続時間を計算
  Duration? durationTo(StateTransitionRecord<T> next) {
    return next.timestamp.difference(timestamp);
  }
  
  /// JSON形式でシリアライズ
  /// Flutter公式: toJson()パターン
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'from': from.name,
      'to': to.name,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StateTransitionRecord<T> &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          timestamp == other.timestamp;
  
  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ timestamp.hashCode;
}

/// 状態統計情報クラス
/// 
/// Flutter公式準拠: immutableデータクラス
@immutable
class StateStatistics {
  /// 現在の状態名
  final String currentState;
  
  /// セッション数
  final int sessionCount;
  
  /// 総状態変更数
  final int totalStateChanges;
  
  /// セッション継続時間
  final Duration sessionDuration;
  
  /// 状態訪問回数
  final Map<String, int> stateVisitCounts;
  
  /// 最も訪問された状態
  final String? mostVisitedState;
  
  /// セッションあたりの平均状態遷移数
  final double averageStateTransitionsPerSession;
  
  /// コンストラクタ
  const StateStatistics({
    required this.currentState,
    required this.sessionCount,
    required this.totalStateChanges,
    required this.sessionDuration,
    required this.stateVisitCounts,
    required this.mostVisitedState,
    required this.averageStateTransitionsPerSession,
  });
  
  /// JSON形式でシリアライズ
  /// Flutter公式: toJson()パターン
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentState': currentState,
      'sessionCount': sessionCount,
      'totalStateChanges': totalStateChanges,
      'sessionDurationSeconds': sessionDuration.inSeconds,
      'stateVisitCounts': stateVisitCounts,
      'mostVisitedState': mostVisitedState,
      'averageStateTransitionsPerSession': averageStateTransitionsPerSession,
    };
  }
}

/// 後方互換性のためのエイリアス
/// 
/// 既存コードが引き続き動作するようにするため
typedef GameStateProvider<T extends GameState> = FlutterGameStateProvider<T>;