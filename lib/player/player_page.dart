import 'dart:async';
import 'package:audiobook_player/player/player_speed_controls.dart';
import 'package:flutter/material.dart';
import 'package:audiobook_player/player/player_service.dart';
import 'package:audiobook_player/player/player_control.dart';
import 'package:file_picker/file_picker.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late PlayerService _playerService;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _playerService = PlayerService();
    _initPlayer();

    _saveTimer = Timer.periodic(Duration(seconds: 3), (_) {
      _playerService.savePosition();
    });
  }

  Future<void> _initPlayer() async {
    final playbackInfo = await _playerService.getLastPlaybackInfo();
    if (playbackInfo != null) {
      await _playerService.player.setUrl(playbackInfo['filePath']);
      await _playerService.player
          .seek(Duration(milliseconds: playbackInfo['position']));
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    if (result != null) {
      final filePath = result.files.single.path!;
      await _playerService.player.setUrl(filePath);
      await _playerService.savePlaybackInfo(filePath, Duration.zero);
      setState(() {}); // Обновим UI, если нужно
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _playerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audiobook Player'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _pickFile,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PlayerControls(playerService: _playerService),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10),
                  iconSize: 40,
                  onPressed: () {
                    final newPosition =
                        _playerService.player.position - Duration(seconds: 10);
                    _playerService.seekTo(newPosition);
                  },
                ),
                StreamBuilder<bool>(
                  stream: _playerService.player.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled),
                      iconSize: 60,
                      onPressed: () {
                        if (isPlaying) {
                          _playerService.player.pause();
                        } else {
                          _playerService.player.play();
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward_30),
                  iconSize: 40,
                  onPressed: () {
                    final newPosition =
                        _playerService.player.position + Duration(seconds: 30);
                    _playerService.seekTo(newPosition);
                  },
                ),
              ],
            ),
          ),
          PlaybackSpeedControls(playerService: _playerService),
        ],
      ),
    );
  }
}
