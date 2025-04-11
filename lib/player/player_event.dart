abstract class PlayerEvent {}

class LoadAudio extends PlayerEvent {
  final String uri;
  final int? initialPosition;
  
  LoadAudio(this.uri, {this.initialPosition});
}

class Play extends PlayerEvent {}

class Pause extends PlayerEvent {}

class SavePosition extends PlayerEvent {}

class ChangeSpeed extends PlayerEvent {
  final double speed;
  
  ChangeSpeed(this.speed);
}

class LoadPreviousAudio extends PlayerEvent {}
