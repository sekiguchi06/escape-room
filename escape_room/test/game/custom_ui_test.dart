import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:escape_room/game/widgets/custom_game_ui.dart';

/// カスタムゲームUI Widgetの単体テスト
void main() {
  group('カスタムゲームUI テスト', () {
    testWidgets('CustomGameUI基本表示テスト', (WidgetTester tester) async {
      // テスト用のWidgetをレンダリング
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomGameUI(
              score: 1500,
              timeRemaining: '01:30',
              isGameActive: true,
              onPausePressed: () {},
              onRestartPressed: () {},
            ),
          ),
        ),
      );

      // スコア表示の確認
      expect(find.text('1500'), findsOneWidget);

      // タイマー表示の確認
      expect(find.text('01:30'), findsOneWidget);

      // アクションボタンの存在確認
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('CustomScoreWidget グラデーション表示テスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CustomScoreWidget(score: 2500))),
      );

      // スコア数値の確認
      expect(find.text('2500'), findsOneWidget);

      // アイコンの存在確認
      expect(find.byIcon(Icons.stars), findsOneWidget);

      // Container Decorationの確認（グラデーション）
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());

      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.gradient, isA<LinearGradient>());
      expect(boxDecoration.borderRadius, isA<BorderRadius>());
      expect(boxDecoration.boxShadow, isNotNull);
    });

    testWidgets('CustomTimerWidget 色変化テスト', (WidgetTester tester) async {
      // 緑色（通常時間）
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CustomTimerWidget(timeRemaining: '02:00')),
        ),
      );

      expect(find.text('02:00'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);

      // オレンジ色（60秒以下）
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CustomTimerWidget(timeRemaining: '00:45')),
        ),
      );

      expect(find.text('00:45'), findsOneWidget);

      // 赤色（30秒以下）
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CustomTimerWidget(timeRemaining: '00:15')),
        ),
      );

      expect(find.text('00:15'), findsOneWidget);
    });

    testWidgets('CustomActionButton アニメーションテスト', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomActionButton(
              icon: Icons.play_arrow,
              onPressed: () {
                buttonPressed = true;
              },
              color: Colors.blue,
            ),
          ),
        ),
      );

      // ボタンの存在確認
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // タップ動作の確認
      await tester.tap(find.byType(CustomActionButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      // コールバック実行の確認
      expect(buttonPressed, isTrue);
    });

    testWidgets('CustomGameOverUI 表示テスト', (WidgetTester tester) async {
      bool restartPressed = false;
      bool menuPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomGameOverUI(
              finalScore: 3500,
              onRestartPressed: () {
                restartPressed = true;
              },
              onMenuPressed: () {
                menuPressed = true;
              },
            ),
          ),
        ),
      );

      // ゲームオーバータイトルの確認
      expect(find.text('GAME OVER'), findsOneWidget);

      // 最終スコアの確認
      expect(find.text('3500'), findsOneWidget);
      expect(find.text('Final Score'), findsOneWidget);

      // アクションボタンの存在確認
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // ボタン動作の確認
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      expect(restartPressed, isTrue);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(menuPressed, isTrue);
    });
  });

  group('カスタムUI統合テスト', () {
    testWidgets('ゲームアクティブ状態でのUI表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomGameUI(
              score: 1200,
              timeRemaining: '01:15',
              isGameActive: true,
              onPausePressed: () {},
              onRestartPressed: () {},
            ),
          ),
        ),
      );

      // アクティブ状態でポーズボタンが表示されること
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('ゲーム非アクティブ状態でのUI表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomGameUI(
              score: 1200,
              timeRemaining: '00:00',
              isGameActive: false,
              onPausePressed: () {},
              onRestartPressed: () {},
            ),
          ),
        ),
      );

      // 非アクティブ状態でポーズボタンが非表示になること
      expect(find.byIcon(Icons.pause), findsNothing);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
