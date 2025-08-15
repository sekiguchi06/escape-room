import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:casual_game_template/framework/state/game_state_system.dart';

/// EscapeRoomState移植テスト
/// 移植ガイド完了判定基準準拠
void main() {
  group('🚪 EscapeRoomState移植テスト - Phase 1', () {
    
    group('EscapeRoomState列挙型テスト', () {
      test('状態値・名前・説明確認', () {
        final states = EscapeRoomState.values;
        expect(states.length, equals(5));
        
        // exploring状態
        expect(EscapeRoomState.exploring.name, equals('exploring'));
        expect(EscapeRoomState.exploring.description, equals('部屋を探索中'));
        
        // escaped状態
        expect(EscapeRoomState.escaped.name, equals('escaped'));
        expect(EscapeRoomState.escaped.description, equals('脱出成功！'));
        
        // timeUp状態
        expect(EscapeRoomState.timeUp.name, equals('timeUp'));
        expect(EscapeRoomState.timeUp.description, equals('時間切れ'));
      });
    });
    
    group('EscapeRoomStateProvider状態遷移テスト', () {
      late EscapeRoomStateProvider stateProvider;
      
      setUp(() {
        stateProvider = EscapeRoomStateProvider();
      });
      
      test('初期状態確認', () {
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
        expect(stateProvider.currentPuzzleId, isNull);
      });
      
      test('exploring ↔ inventory 状態遷移', () {
        // exploring → inventory
        stateProvider.showInventory();
        expect(stateProvider.currentState, equals(EscapeRoomState.inventory));
        
        // inventory → exploring
        stateProvider.hideInventory();
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
        
        // inventory状態でない時のhideInventory
        stateProvider.hideInventory();
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
      });
      
      test('exploring → puzzle → exploring 状態遷移', () {
        const puzzleId = 'safe_combination';
        
        // exploring → puzzle
        stateProvider.startPuzzle(puzzleId);
        expect(stateProvider.currentState, equals(EscapeRoomState.puzzle));
        expect(stateProvider.currentPuzzleId, equals(puzzleId));
        
        // puzzle → exploring
        stateProvider.completePuzzle();
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
        expect(stateProvider.currentPuzzleId, isNull);
        
        // puzzle状態でない時のcompletePuzzle
        stateProvider.completePuzzle();
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
      });
      
      test('脱出成功状態遷移', () {
        stateProvider.escapeSuccess();
        expect(stateProvider.currentState, equals(EscapeRoomState.escaped));
      });
      
      test('時間切れ状態遷移', () {
        // exploring → timeUp
        stateProvider.timeUp();
        expect(stateProvider.currentState, equals(EscapeRoomState.timeUp));
        
        // inventory → timeUp
        stateProvider.forceStateChange(EscapeRoomState.inventory);
        stateProvider.timeUp();
        expect(stateProvider.currentState, equals(EscapeRoomState.timeUp));
        
        // puzzle → timeUp
        stateProvider.forceStateChange(EscapeRoomState.puzzle);
        stateProvider.timeUp();
        expect(stateProvider.currentState, equals(EscapeRoomState.timeUp));
      });
      
      test('状態遷移可能性確認', () {
        // exploring状態からの遷移可能性
        expect(stateProvider.canTransitionTo(EscapeRoomState.inventory), isTrue);
        expect(stateProvider.canTransitionTo(EscapeRoomState.puzzle), isTrue);
        expect(stateProvider.canTransitionTo(EscapeRoomState.escaped), isTrue);
        expect(stateProvider.canTransitionTo(EscapeRoomState.timeUp), isTrue);
        
        // inventory状態からの遷移可能性
        stateProvider.showInventory();
        expect(stateProvider.canTransitionTo(EscapeRoomState.exploring), isTrue);
        expect(stateProvider.canTransitionTo(EscapeRoomState.timeUp), isTrue);
      });
    });
    
    group('移植ガイド完了判定テスト', () {
      test('EscapeRoomState状態遷移移植完了確認', () {
        final stateProvider = EscapeRoomStateProvider();
        
        // 1. exploring ↔ inventory ↔ puzzle の切り替え確認
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
        
        stateProvider.showInventory();
        expect(stateProvider.currentState, equals(EscapeRoomState.inventory));
        
        stateProvider.hideInventory();
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
        
        stateProvider.startPuzzle('test_puzzle');
        expect(stateProvider.currentState, equals(EscapeRoomState.puzzle));
        
        stateProvider.completePuzzle();
        expect(stateProvider.currentState, equals(EscapeRoomState.exploring));
        
        // 2. 脱出・時間切れ状態確認
        stateProvider.escapeSuccess();
        expect(stateProvider.currentState, equals(EscapeRoomState.escaped));
        
        stateProvider.forceStateChange(EscapeRoomState.exploring);
        stateProvider.timeUp();
        expect(stateProvider.currentState, equals(EscapeRoomState.timeUp));
        
        debugPrint('✅ EscapeRoomState状態遷移移植完了: exploring ↔ inventory ↔ puzzle の切り替え');
      });
    });
  });
}