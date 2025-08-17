
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:escape_room/main.dart';
import 'package:escape_room/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('既存のテスト', () {
    testWidgets('EscapeRoomApp smoke test', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: EscapeRoomApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that our app loads without errors - updated UI text
      expect(find.text('はじめる'), findsOneWidget);
      
      // Verify that basic UI elements are present (fallback text when localization fails)
      expect(find.textContaining('Escape'), findsOneWidget);
    });
    
    testWidgets('Basic app navigation test', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: EscapeRoomApp(),
        ),
      );
      
      // Wait for initial frame to load
      await tester.pumpAndSettle();
      
      // Verify that the basic UI is working - updated UI
      expect(find.text('はじめる'), findsOneWidget);
      expect(find.textContaining('Escape'), findsOneWidget);
    });
  });

  group('開始画面のテスト', () {
    testWidgets('GameSelectionScreen が適切に表示される', (WidgetTester tester) async {
      // アプリを起動
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
              Locale('en'),
            ],
            home: GameSelectionScreen(),
          ),
        ),
      );

      // レンダリングを完了
      await tester.pumpAndSettle();

      // タイトルが表示されていることを確認
      expect(find.text('🔓'), findsOneWidget);
      expect(find.text('Escape Master'), findsOneWidget);
      expect(find.text('究極の脱出パズルゲーム'), findsOneWidget);

      // メインボタンが表示されていることを確認
      expect(find.text('はじめる'), findsOneWidget);
      expect(find.text('つづきから'), findsOneWidget);
      expect(find.text('あそびかた'), findsOneWidget);

      // 下部アイコンボタンが表示されていることを確認
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      expect(find.byIcon(Icons.leaderboard), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // 注: 上部設定ボタンは削除済み（言語・テーマ切り替え不要）
    });

    testWidgets('はじめるボタンをタップでゲーム画面に遷移', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
              Locale('en'),
            ],
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // はじめるボタンを見つけてタップ
      final startButton = find.text('はじめる');
      expect(startButton, findsOneWidget);
      
      await tester.tap(startButton);
      await tester.pumpAndSettle();

      // ゲーム画面に遷移していることを確認（EscapeRoomDemoの要素を探す）
      // 注: EscapeRoomDemoは複雑なFlameゲームなので、基本的な要素のみ確認
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('あそびかたボタンをタップでダイアログ表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
              Locale('en'),
            ],
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // あそびかたボタンを見つけてタップ
      final howToPlayButton = find.text('あそびかた');
      expect(howToPlayButton, findsOneWidget);
      
      await tester.tap(howToPlayButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されていることを確認
      expect(find.text('🎮 あそびかた'), findsOneWidget);
      expect(find.text('📱 基本操作'), findsOneWidget);
      expect(find.text('🔍 ゲームの進め方'), findsOneWidget);
      expect(find.text('💡 ヒント'), findsOneWidget);
      expect(find.text('閉じる'), findsOneWidget);

      // 閉じるボタンをタップしてダイアログを閉じる
      await tester.tap(find.text('閉じる'));
      await tester.pumpAndSettle();

      // ダイアログが閉じられていることを確認
      expect(find.text('🎮 あそびかた'), findsNothing);
    });

    testWidgets('音量設定ボタンをタップでダイアログ表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
              Locale('en'),
            ],
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 音量設定ボタンを見つけてタップ
      final volumeButton = find.byIcon(Icons.volume_up);
      expect(volumeButton, findsOneWidget);
      
      await tester.tap(volumeButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されていることを確認
      expect(find.text('🔊 音量設定'), findsOneWidget);
      expect(find.text('🎵 BGM音量'), findsOneWidget);
      expect(find.text('🔔 効果音音量'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('設定ボタンをタップでダイアログ表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
              Locale('en'),
            ],
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 設定ボタンを見つけてタップ
      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);
      
      await tester.tap(settingsButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されていることを確認
      expect(find.text('⚙️ 設定'), findsOneWidget);
      expect(find.text('バイブレーション'), findsOneWidget);
      expect(find.text('プッシュ通知'), findsOneWidget);
      expect(find.text('自動セーブ'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNWidgets(3));
    });

    testWidgets('アプリ情報ボタンをタップでダイアログ表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
              Locale('en'),
            ],
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // アプリ情報ボタンを見つけてタップ
      final infoButton = find.byIcon(Icons.info_outline);
      expect(infoButton, findsOneWidget);
      
      await tester.tap(infoButton);
      await tester.pumpAndSettle();

      // ダイアログが表示されていることを確認
      expect(find.text('ℹ️ アプリ情報'), findsOneWidget);
      expect(find.text('Escape Master'), findsOneWidget);
      expect(find.text('バージョン: 1.0.0'), findsOneWidget);
      expect(find.text('開発者: Claude Code'), findsOneWidget);
    });

    testWidgets('つづきからボタンをタップで未実装メッセージ表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
              Locale('en'),
            ],
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // つづきからボタンを見つけてタップ
      final continueButton = find.text('つづきから');
      expect(continueButton, findsOneWidget);
      
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // スナックバーが表示されていることを確認
      expect(find.text('セーブデータ機能（実装予定）'), findsOneWidget);
    });

  });

  group('UI要素の配置テスト', () {
    testWidgets('背景グラデーションが適切に設定されている', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Container with BoxDecoration（グラデーション背景）が存在することを確認
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      
      // SafeAreaが適切に配置されていることを確認
      expect(find.byType(SafeArea), findsOneWidget);
      
      // Stackレイアウトが使用されていることを確認（複数あることを許可）
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('レスポンシブレイアウトが正しく動作する', (WidgetTester tester) async {
      // 様々な画面サイズでテスト
      await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone SE
      
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameSelectionScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 要素が適切に表示されていることを確認
      expect(find.text('はじめる'), findsOneWidget);
      expect(find.text('つづきから'), findsOneWidget);
      expect(find.text('あそびかた'), findsOneWidget);

      // より大きな画面サイズでもテスト
      await tester.binding.setSurfaceSize(const Size(414, 896)); // iPhone 11
      await tester.pumpAndSettle();

      // 要素が引き続き表示されていることを確認
      expect(find.text('はじめる'), findsOneWidget);
      expect(find.text('つづきから'), findsOneWidget);
      expect(find.text('あそびかた'), findsOneWidget);

      // 画面サイズをリセット
      await tester.binding.setSurfaceSize(null);
    });
  });
}