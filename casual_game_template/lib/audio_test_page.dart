import 'package:flutter/material.dart';
import 'package:casual_game_template/framework/audio/audio_system.dart';
import 'package:casual_game_template/framework/audio/providers/flame_audio_provider.dart';

class AudioTestPage extends StatefulWidget {
  const AudioTestPage({Key? key}) : super(key: key);

  @override
  _AudioTestPageState createState() => _AudioTestPageState();
}

class _AudioTestPageState extends State<AudioTestPage> {
  late FlameAudioProvider audioProvider;
  bool isInitialized = false;
  String status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    audioProvider = FlameAudioProvider();
    
    const config = DefaultAudioConfiguration(
      bgmAssets: {
        'menu_bgm': 'menu.mp3',
      },
      sfxAssets: {
        'tap': 'tap.wav',
        'success': 'success.wav',
        'error': 'error.wav',
      },
      masterVolume: 1.0,
      bgmVolume: 0.7,
      sfxVolume: 0.8,
      bgmEnabled: true,
      sfxEnabled: true,
      debugMode: true,
    );

    try {
      await audioProvider.initialize(config);
      setState(() {
        isInitialized = true;
        status = 'Audio system initialized successfully';
      });
    } catch (e) {
      setState(() {
        status = 'Initialization failed: $e';
      });
    }
  }

  @override
  void dispose() {
    if (isInitialized) {
      audioProvider.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Audio System Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status,
                      style: TextStyle(
                        color: isInitialized ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isInitialized) ...[
                      const SizedBox(height: 8),
                      Text('BGM Playing: ${audioProvider.isBgmPlaying}'),
                      Text('BGM Paused: ${audioProvider.isBgmPaused}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'BGM Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _playBgm() : null,
                    child: const Text('Play BGM'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _pauseBgm() : null,
                    child: const Text('Pause BGM'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _resumeBgm() : null,
                    child: const Text('Resume BGM'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _stopBgm() : null,
                    child: const Text('Stop BGM'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sound Effects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _playSfx('tap') : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Tap Sound'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _playSfx('success') : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Success Sound'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _playSfx('error') : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Error Sound'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isInitialized ? () => _stopAllSfx() : null,
                    child: const Text('Stop All SFX'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Volume Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('BGM Volume: '),
                Expanded(
                  child: Slider(
                    value: 0.7,
                    onChanged: isInitialized ? (value) => _setBgmVolume(value) : null,
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text('SFX Volume: '),
                Expanded(
                  child: Slider(
                    value: 0.8,
                    onChanged: isInitialized ? (value) => _setSfxVolume(value) : null,
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '🎵 Instructions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              '1. Click "Play BGM" to start background music\n'
              '2. Click sound effect buttons to hear different sounds\n'
              '3. Use volume sliders to adjust levels\n'
              '4. Listen for actual audio output from your speakers/headphones',
              style: TextStyle(fontSize: 14),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playBgm() async {
    try {
      await audioProvider.playBgm('menu_bgm', loop: true);
      setState(() {
        status = 'BGM started playing';
      });
    } catch (e) {
      setState(() {
        status = 'BGM play failed: $e';
      });
    }
  }

  Future<void> _pauseBgm() async {
    try {
      await audioProvider.pauseBgm();
      setState(() {
        status = 'BGM paused';
      });
    } catch (e) {
      setState(() {
        status = 'BGM pause failed: $e';
      });
    }
  }

  Future<void> _resumeBgm() async {
    try {
      await audioProvider.resumeBgm();
      setState(() {
        status = 'BGM resumed';
      });
    } catch (e) {
      setState(() {
        status = 'BGM resume failed: $e';
      });
    }
  }

  Future<void> _stopBgm() async {
    try {
      await audioProvider.stopBgm();
      setState(() {
        status = 'BGM stopped';
      });
    } catch (e) {
      setState(() {
        status = 'BGM stop failed: $e';
      });
    }
  }

  Future<void> _playSfx(String sfxId) async {
    try {
      await audioProvider.playSfx(sfxId, volume: 1.0);
      setState(() {
        status = 'SFX played: $sfxId';
      });
    } catch (e) {
      setState(() {
        status = 'SFX play failed: $e';
      });
    }
  }

  Future<void> _stopAllSfx() async {
    try {
      await audioProvider.stopAllSfx();
      setState(() {
        status = 'All SFX stopped';
      });
    } catch (e) {
      setState(() {
        status = 'SFX stop failed: $e';
      });
    }
  }

  Future<void> _setBgmVolume(double value) async {
    try {
      await audioProvider.setBgmVolume(value);
      setState(() {
        status = 'BGM volume set to ${(value * 100).round()}%';
      });
    } catch (e) {
      setState(() {
        status = 'BGM volume change failed: $e';
      });
    }
  }

  Future<void> _setSfxVolume(double value) async {
    try {
      await audioProvider.setSfxVolume(value);
      setState(() {
        status = 'SFX volume set to ${(value * 100).round()}%';
      });
    } catch (e) {
      setState(() {
        status = 'SFX volume change failed: $e';
      });
    }
  }
}