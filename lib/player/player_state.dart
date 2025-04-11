import 'package:just_audio/just_audio.dart';

abstract class PlayerState {}

class PlayerInitial extends PlayerState {}

class PlayerLoaded extends PlayerState {
  final AudioPlayer player;
  PlayerLoaded(this.player);
}

class PlayerError extends PlayerState {
  final String message;

  PlayerError(this.message);
}
