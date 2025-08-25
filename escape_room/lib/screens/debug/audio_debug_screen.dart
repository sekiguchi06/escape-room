import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

/// デバッグ用音響テスト画面
class AudioDebugScreen extends StatefulWidget {
  const AudioDebugScreen({super.key});

  @override
  State<AudioDebugScreen> createState() => _AudioDebugScreenState();
}

class _AudioDebugScreenState extends State<AudioDebugScreen> {
  String? _lastPlayed;
  String? _lastError;
  bool _isPlaying = false;
  bool _isLoading = true;
  List<AudioFile> _audioFiles = [];
  int _totalFiles = 0;

  @override
  void initState() {
    super.initState();
    _loadAudioFiles();
  }

  /// アセットからオーディオファイル一覧を動的に取得
  Future<void> _loadAudioFiles() async {
    setState(() {
      _isLoading = true;
      _audioFiles = [];
    });

    try {
      // AssetManifest.jsonからファイル一覧を取得
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = 
          jsonDecode(manifestContent) as Map<String, dynamic>;

      final List<String> audioAssets = manifestMap.keys
          .where((key) => key.contains('assets/audio/'))
          .where((key) => key.endsWith('.mp3') || key.endsWith('.wav'))
          .toList();

      final List<AudioFile> audioFiles = [];
      
      for (String assetPath in audioAssets) {
        final fileName = assetPath.split('/').last;
        
        // ファイルの実在性を確認（簡易チェック）
        try {
          await rootBundle.load(assetPath);
          final audioFile = _createAudioFileFromName(fileName);
          audioFiles.add(audioFile);
        } catch (e) {
          debugPrint('⚠️ Asset exists in manifest but failed to load: $assetPath - $e');
          // 読み込めないファイルはスキップ
        }
      }

      // ファイル名でソート
      audioFiles.sort((a, b) => a.fileName.compareTo(b.fileName));

      setState(() {
        _audioFiles = audioFiles;
        _totalFiles = audioFiles.length;
        _isLoading = false;
      });

    } catch (e) {
      // フォールバック：既知のファイル一覧を使用
      setState(() {
        _audioFiles = _getFallbackAudioFiles();
        _totalFiles = _audioFiles.length;
        _isLoading = false;
      });
      
      debugPrint('⚠️ Asset manifest loading failed, using fallback: $e');
    }
  }

  /// ファイル名から AudioFile を生成（AI推測ベース）
  AudioFile _createAudioFileFromName(String fileName) {
    final name = fileName.toLowerCase();
    
    // ファイル名パターンでタイプと説明を推測
    if (name.contains('ambient') || name.contains('exploration')) {
      return AudioFile(fileName, '🌲 ${_formatFileName(fileName)}', AudioType.bgm);
    } else if (name.contains('menu')) {
      return AudioFile(fileName, '🎶 ${_formatFileName(fileName)}', AudioType.bgm);
    } else if (name.contains('victory') || name.contains('fanfare')) {
      return AudioFile(fileName, '🎊 ${_formatFileName(fileName)}', AudioType.bgm);
    } else if (name.contains('tension') || name.contains('puzzle')) {
      return AudioFile(fileName, '⚡ ${_formatFileName(fileName)}', AudioType.bgm);
    } else if (name.contains('button') || name.contains('tap') || name.contains('decision')) {
      return AudioFile(fileName, '👆 ${_formatFileName(fileName)}', AudioType.ui);
    } else if (name.contains('door')) {
      return AudioFile(fileName, '🚪 ${_formatFileName(fileName)}', AudioType.game);
    } else if (name.contains('item')) {
      return AudioFile(fileName, '📦 ${_formatFileName(fileName)}', AudioType.game);
    } else if (name.contains('hotspot')) {
      return AudioFile(fileName, '🎯 ${_formatFileName(fileName)}', AudioType.game);
    } else if (name.contains('gimmick')) {
      return AudioFile(fileName, '⚙️ ${_formatFileName(fileName)}', AudioType.game);
    } else if (name.contains('success') || name.contains('clear') || name.contains('escape')) {
      return AudioFile(fileName, '🎉 ${_formatFileName(fileName)}', AudioType.result);
    } else if (name.contains('error')) {
      return AudioFile(fileName, '⚠️ ${_formatFileName(fileName)}', AudioType.error);
    } else {
      return AudioFile(fileName, '🔊 ${_formatFileName(fileName)}', AudioType.game);
    }
  }

  /// ファイル名を表示用にフォーマット
  String _formatFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'\\.(mp3|wav)\$'), '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  /// フォールバック用の既知ファイル一覧（空リスト + エラー表示）
  List<AudioFile> _getFallbackAudioFiles() {
    // AssetManifest.jsonの読み込みに失敗した場合の対処
    // 実際のファイルが存在する場合は、手動でここに追加できます
    final List<AudioFile> fallbackFiles = [];
    
    // 現在存在することがわかっているファイルを追加
    try {
      fallbackFiles.add(
        AudioFile('decision_button.mp3', '👆 Decision Button (Fallback)', AudioType.ui),
      );
    } catch (e) {
      debugPrint('⚠️ Even fallback file loading failed: $e');
    }
    
    return fallbackFiles;
  }

  Future<void> _playAudio(AudioFile audioFile) async {
    setState(() {
      _isPlaying = true;
      _lastError = null;
      _lastPlayed = null;
    });

    try {
      debugPrint('🎵 Playing: ${audioFile.fileName}');
      await FlameAudio.play(audioFile.fileName, volume: 0.8);
      
      setState(() {
        _lastPlayed = '✅ ${audioFile.description}';
        _lastError = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ 再生成功: ${audioFile.description}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastError = '❌ ${audioFile.description}\\nエラー: $e';
        _lastPlayed = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 再生失敗: ${audioFile.fileName}\\n$e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 音響テスト (デバッグ機能)'),
        backgroundColor: Colors.orange[100],
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAudioFiles,
              tooltip: '再読み込み',
            ),
        ],
      ),
      body: Column(
        children: [
          // ステータス表示エリア
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 デバッグモード - $_totalFiles ファイル',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                if (_isLoading)
                  const Text('📁 ファイル一覧を読み込み中...', style: TextStyle(color: Colors.orange)),
                
                if (_isPlaying)
                  const Text('🎵 再生中...', style: TextStyle(color: Colors.blue)),
                
                if (_lastPlayed != null)
                  Text(_lastPlayed!, style: const TextStyle(color: Colors.green)),
                
                if (_lastError != null)
                  Text(_lastError!, style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ),
          
          // ファイル一覧
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _audioFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              '❌ assets/audio/ ディレクトリに音声ファイルがありません',
                              style: TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '音声ファイル (.mp3, .wav) を assets/audio/ に配置してください',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadAudioFiles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('再スキャン'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _audioFiles.length,
                        itemBuilder: (context, index) {
                          final audioFile = _audioFiles[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: audioFile.type.color.withOpacity(0.2),
                                child: Icon(Icons.play_arrow, color: audioFile.type.color),
                              ),
                              title: Text(audioFile.description),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    audioFile.fileName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    audioFile.type.displayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: audioFile.type.color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: _isPlaying 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : null,
                              onTap: _isPlaying ? null : () => _playAudio(audioFile),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// オーディオファイル情報クラス
class AudioFile {
  final String fileName;
  final String description;
  final AudioType type;

  AudioFile(this.fileName, this.description, this.type);
}

// オーディオタイプ分類
enum AudioType {
  bgm(Colors.purple, '🎵', 'BGM'),
  ui(Colors.blue, '🎛️', 'UI音'),
  game(Colors.green, '🎮', 'ゲーム音'),
  result(Colors.orange, '🏆', '結果音'),
  error(Colors.red, '⚠️', 'エラー音');

  const AudioType(this.color, this.label, this.displayName);
  final Color color;
  final String label;
  final String displayName;
}