part of 'just_audio_player_cubit.dart';

enum CurrentState {loading, playing, paused}

@immutable
class JustAudioPlayerState {
  final Track currentTrack;
  final CurrentState currentState;
  final Duration seek;
  final Duration duration;

  const JustAudioPlayerState({required this.currentTrack, required this.currentState, required this.seek, required this.duration});

  JustAudioPlayerState copyWith({Track? currentTrack, CurrentState? currentState, Duration? seek, Duration? duration}){
    return JustAudioPlayerState(
        currentTrack : currentTrack ?? this.currentTrack,
        currentState: currentState ?? this.currentState,
        seek: seek ?? this.seek,
        duration: duration ?? this.duration
    );
  }
  static JustAudioPlayerState init() {
    return JustAudioPlayerState(currentTrack: tracks.first, currentState: CurrentState.paused, seek: Duration.zero, duration: Duration.zero);
  }

}


