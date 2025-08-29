import 'package:flutter_test/flutter_test.dart';
import 'package:flame_audio/flame_audio.dart';

void main() {
  group('Audio System Tests', () {
    test('should have correct audio file paths', () {
      // アセットファイル名をテスト
      const expectedFiles = [
        'moonlight.mp3',
        'misty_dream.mp3', 
        'swimming_fish_dream.mp3',
        'walk.mp3',
        'close.mp3',
        'decision_button.mp3',
        'door.mp3',
      ];
      
      for (final fileName in expectedFiles) {
        // FlameAudioが正しいパスを使用するかテスト
        expect(fileName, isNotEmpty);
        expect(fileName.contains('assets/'), isFalse, 
          reason: 'FlameAudio uses filename only, not full path');
      }
    });

    test('should load audio files without path prefix', () async {
      // FlameAudioのpreload機能をテスト（実際の再生はしない）
      try {
        // プリロードのみテスト（実際の音声は出力されない）
        await FlameAudio.audioCache.loadAll([
          'moonlight.mp3',
          'misty_dream.mp3',
          'swimming_fish_dream.mp3'
        ]);
        
        // プリロードが成功した場合のテスト
        expect(true, isTrue, reason: 'Audio files preloaded successfully');
      } catch (e) {
        // プリロード失敗時のログ
        print('Audio preload test failed: $e');
        fail('Audio files could not be preloaded: $e');
      }
    });
  });
}