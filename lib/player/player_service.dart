import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

class PlayerService {
  final AudioPlayer player = AudioPlayer();

  static const String _lastFileKey = 'last_audio_file';
  static const String _lastPositionKey = 'last_audio_position';
  static const String _lastFileNameKey = 'last_file_name';
  static const String _lastPlaybackSpeedKey = 'last_playback_speed';

  // Default playback speed
  static const double defaultSpeed = 1.0;
  // Available speed options with 0.25 step
  static const List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  // Stream controllers for UI updates
  final BehaviorSubject<String> _fileNameController = BehaviorSubject<String>();
  final BehaviorSubject<PositionData> _positionDataController =
      BehaviorSubject<PositionData>();
  final BehaviorSubject<double> _playbackSpeedController = BehaviorSubject<double>.seeded(defaultSpeed);

  // Expose streams for UI consumption
  Stream<String> get fileNameStream => _fileNameController.stream;
  Stream<PositionData> get positionDataStream => _positionDataController.stream;
  Stream<double> get playbackSpeedStream => _playbackSpeedController.stream;

  PlayerService() {
    // Initialize position tracking
    player.positionStream.listen((position) {
      final duration = player.duration ?? Duration.zero;
      _positionDataController.add(
        PositionData(
          position: position,
          duration: duration,
          bufferedPosition: player.bufferedPosition,
        ),
      );
    });

    // Listen for audio source changes
    player.currentIndexStream.listen((index) {
      _updateFileName();
    });

    // Load saved playback speed
    _loadSavedPlaybackSpeed();
  }

  Future<void> _loadSavedPlaybackSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble(_lastPlaybackSpeedKey) ?? defaultSpeed;
    await setPlaybackSpeed(savedSpeed);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    if (speed < 0.5 || speed > 2.0) {
      speed = defaultSpeed; // Fallback to default if out of range
    }
    
    await player.setSpeed(speed);
    _playbackSpeedController.add(speed);
    
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastPlaybackSpeedKey, speed);
  }

  // Increase playback speed by 0.25 step
  Future<void> increaseSpeed() async {
    final currentSpeed = _playbackSpeedController.value;
    final nextIndex = speedOptions.indexOf(currentSpeed) + 1;
    
    if (nextIndex < speedOptions.length) {
      await setPlaybackSpeed(speedOptions[nextIndex]);
    }
  }

  // Decrease playback speed by 0.25 step
  Future<void> decreaseSpeed() async {
    final currentSpeed = _playbackSpeedController.value;
    final prevIndex = speedOptions.indexOf(currentSpeed) - 1;
    
    if (prevIndex >= 0) {
      await setPlaybackSpeed(speedOptions[prevIndex]);
    }
  }

  void _updateFileName() {
    final source = player.audioSource;
    if (source != null && source is UriAudioSource) {
      final uri = source.uri;
      String fileName = '';

      if (uri.scheme == 'file') {
        fileName = path.basename(uri.toFilePath());
      } else {
        fileName = path.basename(uri.path);
      }

      _fileNameController.add(fileName);
      _saveFileName(fileName);
    }
  }

  Future<void> _saveFileName(String fileName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFileNameKey, fileName);
  }

  Future<void> savePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final position = player.position.inMilliseconds;
    await prefs.setInt(_lastPositionKey, position);

    // Save the current file path if it exists
    final source = player.audioSource;
    if (source != null && source is UriAudioSource) {
      await prefs.setString(_lastFileKey, source.uri.toString());

      // Save file name
      _updateFileName();
    }
  }

  Future<void> savePlaybackInfo(String filePath, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFileKey, filePath);
    await prefs.setInt(_lastPositionKey, position.inMilliseconds);
    await prefs.setString(_lastFileNameKey, path.basename(filePath));
  }

  Future<Map<String, dynamic>?> getLastPlaybackInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFile = prefs.getString(_lastFileKey);
    final lastPosition = prefs.getInt(_lastPositionKey);
    final lastName = prefs.getString(_lastFileNameKey);
    final lastSpeed = prefs.getDouble(_lastPlaybackSpeedKey) ?? defaultSpeed;

    if (lastFile != null) {
      return {
        'filePath': lastFile,
        'position': lastPosition ?? 0,
        'fileName': lastName ?? path.basename(lastFile),
        'playbackSpeed': lastSpeed,
      };
    }
    return null;
  }

  // Method to seek to a specific position
  Future<void> seekTo(Duration position) async {
    await player.seek(position);
  }

  // Clean up resources
  void dispose() {
    _fileNameController.close();
    _positionDataController.close();
    _playbackSpeedController.close();
    player.dispose();
  }
}

// Class to hold position data for the progress bar
class PositionData {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;

  PositionData({
    required this.position,
    required this.duration,
    required this.bufferedPosition,
  });
}
