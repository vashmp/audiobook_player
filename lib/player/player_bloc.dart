import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'player_event.dart';
import 'player_state.dart';
import 'player_service.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final PlayerService _playerService;

  PlayerBloc(this._playerService) : super(PlayerInitial()) {
    on<LoadAudio>(_onLoadAudio);
    on<Play>(_onPlay);
    on<Pause>(_onPause);
    on<SavePosition>(_onSavePosition);
    on<ChangeSpeed>(_onChangeSpeed);
    on<LoadPreviousAudio>(_onLoadPreviousAudio);
  }

  Future<void> _onLoadAudio(LoadAudio event, Emitter<PlayerState> emit) async {
    try {
      await _playerService.player
          .setAudioSource(just_audio.AudioSource.uri(Uri.parse(event.uri)));

      if (event.initialPosition != null) {
        await _playerService.player
            .seek(Duration(milliseconds: event.initialPosition!));
      }

      emit(PlayerLoaded(_playerService.player));
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  void _onPlay(Play event, Emitter<PlayerState> emit) {
    _playerService.player.play();
  }

  void _onPause(Pause event, Emitter<PlayerState> emit) {
    _playerService.player.pause();
  }

  Future<void> _onSavePosition(
      SavePosition event, Emitter<PlayerState> emit) async {
    await _playerService.savePosition();
  }

  void _onChangeSpeed(ChangeSpeed event, Emitter<PlayerState> emit) {
    _playerService.player.setSpeed(event.speed);
  }

  Future<void> _onLoadPreviousAudio(
      LoadPreviousAudio event, Emitter<PlayerState> emit) async {
    final playbackInfo = await _playerService.getLastPlaybackInfo();
    if (playbackInfo != null) {
      add(LoadAudio(playbackInfo['filePath'],
          initialPosition: playbackInfo['position']));
    }
  }
}
