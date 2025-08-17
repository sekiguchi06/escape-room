import 'package:flutter_test/flutter_test.dart';
import 'package:casual_game_template/framework/audio/volume_manager.dart';

void main() {
  group('VolumeManager Tests', () {
    late VolumeManager volumeManager;

    setUp(() {
      volumeManager = VolumeManager();
    });

    test('音量の初期値が正しく設定される', () {
      expect(volumeManager.bgmVolume, 0.7);
      expect(volumeManager.sfxVolume, 0.8);
      expect(volumeManager.isMuted, false);
    });

    test('BGM音量の設定が正しく動作する', () async {
      await volumeManager.setBgmVolume(0.5);
      expect(volumeManager.bgmVolume, 0.5);
      expect(volumeManager.effectiveBgmVolume, 0.5);
    });

    test('SFX音量の設定が正しく動作する', () async {
      await volumeManager.setSfxVolume(0.3);
      expect(volumeManager.sfxVolume, 0.3);
      expect(volumeManager.effectiveSfxVolume, 0.3);
    });

    test('ミュート機能が正しく動作する', () async {
      await volumeManager.toggleMute();
      expect(volumeManager.isMuted, true);
      expect(volumeManager.effectiveBgmVolume, 0.0);
      expect(volumeManager.effectiveSfxVolume, 0.0);

      await volumeManager.toggleMute();
      expect(volumeManager.isMuted, false);
      expect(volumeManager.effectiveBgmVolume, 0.7);
      expect(volumeManager.effectiveSfxVolume, 0.8);
    });

    test('音量値が範囲内に制限される', () async {
      await volumeManager.setBgmVolume(1.5); // 範囲外
      expect(volumeManager.bgmVolume, 1.0);

      await volumeManager.setSfxVolume(-0.1); // 範囲外
      expect(volumeManager.sfxVolume, 0.0);
    });

    test('リセット機能が正しく動作する', () async {
      // 値を変更
      await volumeManager.setBgmVolume(0.2);
      await volumeManager.setSfxVolume(0.1);
      await volumeManager.toggleMute();

      // リセット実行
      await volumeManager.resetToDefaults();

      // デフォルト値に戻ることを確認
      expect(volumeManager.bgmVolume, 0.7);
      expect(volumeManager.sfxVolume, 0.8);
      expect(volumeManager.isMuted, false);
    });

    test('GameSfxType enumが正しく定義されている', () {
      // 全ての効果音タイプが定義されていることを確認
      expect(GameSfxType.values.length, 7);
      expect(GameSfxType.values.contains(GameSfxType.buttonTap), true);
      expect(GameSfxType.values.contains(GameSfxType.itemFound), true);
      expect(GameSfxType.values.contains(GameSfxType.puzzleSolved), true);
      expect(GameSfxType.values.contains(GameSfxType.error), true);
      expect(GameSfxType.values.contains(GameSfxType.success), true);
      expect(GameSfxType.values.contains(GameSfxType.doorOpen), true);
      expect(GameSfxType.values.contains(GameSfxType.escape), true);
    });
  });
}