import 'package:flutter/foundation.dart';

/// ゲーム状態の定義
enum SimpleGameState { start, playing, gameOver }

/// ゲーム状態を管理するProvider
/// Flutterベストプラクティスに準拠した状態管理
class GameStateProvider extends ChangeNotifier {
  SimpleGameState _currentState = SimpleGameState.start;
  double _gameTimer = 5.0;
  final double _initialTimer = 5.0;
  
  // デバッグ情報
  int _gameSessionCount = 0;
  int _totalGamesPlayed = 0;

  /// 現在のゲーム状態を取得
  SimpleGameState get currentState => _currentState;

  /// 現在のタイマー時間を取得
  double get gameTimer => _gameTimer;

  /// 初期タイマー時間を取得
  double get initialTimer => _initialTimer;

  /// セッション内でのゲーム数を取得
  int get gameSessionCount => _gameSessionCount;

  /// 総ゲーム数を取得
  int get totalGamesPlayed => _totalGamesPlayed;

  /// ゲームを開始状態に設定
  void setStartState() {
    _currentState = SimpleGameState.start;
    _gameTimer = _initialTimer;
    notifyListeners();
    
    debugPrint('GameStateProvider: ゲーム開始状態に設定');
  }

  /// ゲームをプレイ中状態に設定
  void setPlayingState() {
    _currentState = SimpleGameState.playing;
    _gameTimer = _initialTimer;
    _gameSessionCount++;
    _totalGamesPlayed++;
    notifyListeners();
    
    debugPrint('GameStateProvider: ゲームプレイ中状態に設定 (セッション: $_gameSessionCount, 総数: $_totalGamesPlayed)');
  }

  /// ゲームをゲームオーバー状態に設定
  void setGameOverState() {
    _currentState = SimpleGameState.gameOver;
    _gameTimer = 0.0;
    notifyListeners();
    
    debugPrint('GameStateProvider: ゲームオーバー状態に設定');
  }

  /// タイマーを更新（主にゲーム内で使用）
  void updateTimer(double newTime) {
    if (_currentState == SimpleGameState.playing) {
      final clampedTime = newTime.clamp(0.0, _initialTimer);
      
      // 値が変わった場合のみ更新
      if ((_gameTimer - clampedTime).abs() > 0.1) { // 0.1秒単位で更新
        _gameTimer = clampedTime;
        
        // タイマーが0になったら自動的にゲームオーバー
        if (_gameTimer <= 0) {
          setGameOverState();
        } else {
          notifyListeners();
        }
      } else if (_gameTimer != clampedTime) {
        _gameTimer = clampedTime;
        if (_gameTimer <= 0) {
          setGameOverState();
        }
      }
    }
  }

  /// ゲームをリセット（セッション情報は保持）
  void resetGame() {
    setStartState();
    debugPrint('GameStateProvider: ゲームリセット');
  }

  /// セッション情報もクリア
  void resetSession() {
    _currentState = SimpleGameState.start;
    _gameTimer = _initialTimer;
    _gameSessionCount = 0;
    notifyListeners();
    
    debugPrint('GameStateProvider: セッション情報クリア');
  }

  /// 状態の説明テキストを取得
  String getStateDescription() {
    switch (_currentState) {
      case SimpleGameState.start:
        return 'TAP TO START';
      case SimpleGameState.playing:
        return 'TIME: ${_gameTimer.toStringAsFixed(1)}';
      case SimpleGameState.gameOver:
        return 'GAME OVER\nTAP TO RESTART';
    }
  }

  /// デバッグ情報を取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'currentState': _currentState.toString(),
      'gameTimer': _gameTimer,
      'gameSessionCount': _gameSessionCount,
      'totalGamesPlayed': _totalGamesPlayed,
    };
  }
}