import 'package:flutter_test/flutter_test.dart';

import 'package:flame/components.dart';
import 'package:escape_room/framework/input/flame_input_system.dart';

/// Flame公式events準拠InputSystemの単体テスト
/// 既存インターフェース互換性とFlame公式準拠実装の確認
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('🎮 Flame公式events準拠InputSystem テスト', () {
    group('InputEventData テスト', () {
      test('InputEventData 作成確認', () {
        final event = InputEventData(
          type: InputEventType.tap,
          position: Vector2(100, 200),
          duration: const Duration(milliseconds: 100),
        );

        expect(event.type, equals(InputEventType.tap));
        expect(event.position, equals(Vector2(100, 200)));
        expect(event.duration, equals(const Duration(milliseconds: 100)));
        expect(event.additionalData, isEmpty);
      });

      test('InputEventData toString実装確認', () {
        final event = InputEventData(
          type: InputEventType.tap,
          position: Vector2(50, 75),
        );

        final str = event.toString();
        expect(str, contains('InputEventData'));
        expect(str, contains('tap'));
        expect(str, contains('50'));
        expect(str, contains('75'));
      });
    });

    group('DefaultInputConfiguration テスト', () {
      test('デフォルト設定値確認', () {
        const config = DefaultInputConfiguration();

        expect(config.tapSensitivity, equals(10.0));
        expect(config.doubleTapInterval, equals(300));
        expect(config.longPressDuration, equals(500));
        expect(config.swipeMinDistance, equals(50.0));
        expect(config.swipeMaxDuration, equals(500));
        expect(config.pinchSensitivity, equals(0.1));
        expect(config.debugMode, isFalse);
        expect(config.enabledInputTypes, isNotEmpty);
        expect(config.enabledInputTypes, contains(InputEventType.tap));
      });

      test('カスタム設定値確認', () {
        const config = DefaultInputConfiguration(
          tapSensitivity: 20.0,
          debugMode: true,
          enabledInputTypes: {InputEventType.tap, InputEventType.doubleTap},
        );

        expect(config.tapSensitivity, equals(20.0));
        expect(config.debugMode, isTrue);
        expect(config.enabledInputTypes.length, equals(2));
        expect(config.enabledInputTypes, contains(InputEventType.tap));
        expect(config.enabledInputTypes, contains(InputEventType.doubleTap));
      });
    });

    group('FlameInputProcessor テスト', () {
      late FlameInputProcessor processor;
      late DefaultInputConfiguration config;

      setUp(() {
        processor = FlameInputProcessor();
        config = const DefaultInputConfiguration(debugMode: true);
        processor.initialize(config);
      });

      test('初期化確認', () {
        expect(processor, isNotNull);
        // 初期化が正常に完了していることを確認
      });

      test('Flame公式TapCallbacks準拠 - タップダウン処理', () {
        final position = Vector2(100, 150);
        final result = processor.processTapDown(position);

        expect(result, isTrue);
        // Flame公式準拠のタップダウンが正常に処理されることを確認
      });

      test('Flame公式TapCallbacks準拠 - タップアップ処理', () {
        final downPosition = Vector2(100, 150);
        final upPosition = Vector2(105, 155); // tapSensitivity以内

        processor.processTapDown(downPosition);
        final result = processor.processTapUp(upPosition);

        expect(result, isTrue);
        // Flame公式準拠のタップアップが正常に処理されることを確認
      });

      test('タップキャンセル処理', () {
        final position = Vector2(100, 150);

        processor.processTapDown(position);
        final result = processor.processTapCancel();

        expect(result, isTrue);
        // タップキャンセルが正常に処理されることを確認
      });

      test('Flame公式DragCallbacks準拠 - ドラッグ処理', () {
        final startPosition = Vector2(100, 150);
        final updatePosition = Vector2(150, 200);
        final endPosition = Vector2(200, 250);
        final velocity = Vector2(10, 5);

        expect(processor.processPanStart(startPosition), isTrue);
        expect(
          processor.processPanUpdate(updatePosition, Vector2(50, 50)),
          isTrue,
        );
        expect(processor.processPanEnd(endPosition, velocity), isTrue);
        // Flame公式DragCallbacks準拠のドラッグ処理が正常に動作することを確認
      });

      test('Flame公式ScaleCallbacks準拠 - スケール処理', () {
        final focalPoint = Vector2(150, 200);
        const scale = 1.5;

        expect(processor.processScaleStart(focalPoint, scale), isTrue);
        expect(processor.processScaleUpdate(focalPoint, scale * 1.2), isTrue);
        expect(processor.processScaleEnd(), isTrue);
        // Flame公式ScaleCallbacks準拠のスケール処理が正常に動作することを確認
      });

      test('入力イベントリスナー登録・削除', () {
        var eventReceived = false;
        InputEventData? receivedEvent;

        void listener(InputEventData event) {
          eventReceived = true;
          receivedEvent = event;
        }

        processor.addInputListener(listener);

        // タップイベントを発生させる
        final position = Vector2(125, 175);
        processor.processTapDown(position);
        processor.processTapUp(position);

        expect(eventReceived, isTrue);
        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.type, equals(InputEventType.tap));
        expect(receivedEvent!.position, equals(position));

        // リスナー削除テスト
        processor.removeInputListener(listener);
        eventReceived = false;
        receivedEvent = null;

        processor.processTapDown(position);
        processor.processTapUp(position);

        expect(eventReceived, isFalse);
        expect(receivedEvent, isNull);
        // リスナーが正常に削除されることを確認
      });

      test('ダブルタップ検出', () {
        const config = DefaultInputConfiguration(
          doubleTapInterval: 300,
          tapSensitivity: 15.0,
          enabledInputTypes: {InputEventType.tap, InputEventType.doubleTap},
        );
        processor.updateConfiguration(config);

        var doubleTapDetected = false;
        processor.addInputListener((event) {
          if (event.type == InputEventType.doubleTap) {
            doubleTapDetected = true;
          }
        });

        final position = Vector2(100, 150);

        // 1回目のタップ
        processor.processTapDown(position);
        processor.processTapUp(position);

        // 短い間隔で2回目のタップ
        processor.processTapDown(position);
        processor.processTapUp(position);

        expect(doubleTapDetected, isTrue);
        // ダブルタップが正常に検出されることを確認
      });

      test('設定更新確認', () {
        const newConfig = DefaultInputConfiguration(
          tapSensitivity: 25.0,
          debugMode: false,
        );

        processor.updateConfiguration(newConfig);
        // 設定更新が正常に処理されることを確認
        // 実際の動作は内部状態のため直接確認は困難
      });

      test('フレーム更新処理', () {
        // Flame公式では個別のCallbacksが状態管理するため軽量実装
        expect(() => processor.update(0.016), returnsNormally);
        // エラーなく更新処理が実行されることを確認
      });
    });

    group('FlameInputManager テスト', () {
      late FlameInputManager manager;
      late FlameInputProcessor processor;
      late DefaultInputConfiguration config;

      setUp(() {
        processor = FlameInputProcessor();
        config = const DefaultInputConfiguration(debugMode: true);
        manager = FlameInputManager(
          processor: processor,
          configuration: config,
        );
        manager.initialize();
      });

      test('初期化確認', () {
        expect(manager, isNotNull);
        expect(manager.processor, equals(processor));
        expect(manager.configuration, equals(config));
      });

      test('Flame公式events準拠の入力処理', () {
        final position = Vector2(200, 300);

        // Flame公式TapCallbacks準拠の処理が正常に動作することを確認
        expect(() => manager.handleTapDown(position), returnsNormally);
        expect(() => manager.handleTapUp(position), returnsNormally);
        expect(() => manager.handleTapCancel(), returnsNormally);

        // Flame公式DragCallbacks準拠の処理が正常に動作することを確認
        expect(() => manager.handlePanStart(position), returnsNormally);
        expect(
          () => manager.handlePanUpdate(position, Vector2(10, 20)),
          returnsNormally,
        );
        expect(
          () => manager.handlePanEnd(position, Vector2(5, 10)),
          returnsNormally,
        );

        // Flame公式ScaleCallbacks準拠の処理が正常に動作することを確認
        expect(() => manager.handleScaleStart(position, 1.0), returnsNormally);
        expect(() => manager.handleScaleUpdate(position, 1.5), returnsNormally);
        expect(() => manager.handleScaleEnd(), returnsNormally);
      });

      test('プロセッサー変更', () {
        final newProcessor = FlameInputProcessor();
        manager.setProcessor(newProcessor);

        expect(manager.processor, equals(newProcessor));
        // プロセッサーが正常に変更されることを確認
      });

      test('設定更新', () {
        const newConfig = DefaultInputConfiguration(
          tapSensitivity: 30.0,
          debugMode: false,
        );

        manager.updateConfiguration(newConfig);
        expect(manager.configuration, equals(newConfig));
        // 設定が正常に更新されることを確認
      });

      test('入力イベントリスナー管理', () {
        var eventCount = 0;

        void listener(InputEventData event) {
          eventCount++;
        }

        manager.addInputListener(listener);

        // タップイベントを発生させる
        final position = Vector2(150, 250);
        manager.handleTapDown(position);
        manager.handleTapUp(position);

        expect(eventCount, greaterThan(0));

        // リスナー削除
        manager.removeInputListener(listener);
        final oldCount = eventCount;

        manager.handleTapDown(position);
        manager.handleTapUp(position);

        expect(eventCount, equals(oldCount));
        // リスナーが正常に削除されることを確認
      });

      test('フレーム更新', () {
        expect(() => manager.update(0.016), returnsNormally);
        // フレーム更新が正常に処理されることを確認
      });

      test('デバッグ情報取得', () {
        final debugInfo = manager.getDebugInfo();

        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo.keys, contains('processor_type'));
        expect(debugInfo.keys, contains('configuration_type'));
        expect(debugInfo.keys, contains('enabled_input_types'));
        expect(debugInfo.keys, contains('flame_events_compliant'));
        expect(debugInfo['flame_events_compliant'], isTrue);
        // Flame公式準拠であることが明示されることを確認
      });
    });

    group('後方互換性テスト', () {
      test('InputManagerエイリアス確認', () {
        final manager = InputManager();
        expect(manager, isA<FlameInputManager>());
        // 既存コードとの互換性が保たれることを確認
      });

      test('BasicInputProcessorエイリアス確認', () {
        final processor = BasicInputProcessor();
        expect(processor, isA<FlameInputProcessor>());
        // 既存コードとの互換性が保たれることを確認
      });
    });

    group('Flame公式準拠性テスト', () {
      test('TapCallbacks準拠確認', () {
        final processor = FlameInputProcessor();
        const config = DefaultInputConfiguration();
        processor.initialize(config);

        // Flame公式TapCallbacksのonTapDown/onTapUp相当の処理
        final position = Vector2(100, 200);
        expect(processor.processTapDown(position), isTrue);
        expect(processor.processTapUp(position), isTrue);
        // Flame公式TapCallbacks準拠の処理が実装されることを確認
      });

      test('DragCallbacks準拠確認', () {
        final processor = FlameInputProcessor();
        const config = DefaultInputConfiguration();
        processor.initialize(config);

        // Flame公式DragCallbacksのonDragStart/Update/End相当の処理
        final position = Vector2(150, 250);
        expect(processor.processPanStart(position), isTrue);
        expect(processor.processPanUpdate(position, Vector2(10, 15)), isTrue);
        expect(processor.processPanEnd(position, Vector2(5, 8)), isTrue);
        // Flame公式DragCallbacks準拠の処理が実装されることを確認
      });

      test('ScaleCallbacks準拠確認', () {
        final processor = FlameInputProcessor();
        const config = DefaultInputConfiguration();
        processor.initialize(config);

        // Flame公式ScaleCallbacksのonScaleStart/Update/End相当の処理
        final focalPoint = Vector2(200, 300);
        expect(processor.processScaleStart(focalPoint, 1.0), isTrue);
        expect(processor.processScaleUpdate(focalPoint, 1.5), isTrue);
        expect(processor.processScaleEnd(), isTrue);
        // Flame公式ScaleCallbacks準拠の処理が実装されることを確認
      });
    });
  });
}
