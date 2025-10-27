import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';

import '../tracks.dart';


part 'just_audio_player_state.dart';

class JustAudioPlayerCubit extends Cubit<JustAudioPlayerState> {
  JustAudioPlayerCubit() : super(JustAudioPlayerState.init());

  final player = AudioPlayer();
  StreamSubscription<Duration>? seekSubscription;
  StreamSubscription<PlayerState>? stateSubscription;
  StreamSubscription<Duration?>? durationSubscription;

  Future<void> init()async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    attachListeners();
    await loadTrack(state.currentTrack);
  }

  void attachListeners() {
    seekSubscription = player.positionStream.listen((seek) {
      emit(state.copyWith(seek: seek));
    });
    durationSubscription = player.durationStream.listen((d) {
      emit(state.copyWith(duration: d ?? Duration.zero));
    });
    stateSubscription = player.playerStateStream.listen((s) {
      final isLoading = s.processingState == ProcessingState.loading ||
          s.processingState == ProcessingState.buffering;
      emit(state.copyWith(currentState:player.playing ? CurrentState.playing : isLoading? CurrentState.loading: CurrentState.paused ));
    });
  }

  Future<void> loadTrack(Track track)async{
    emit(JustAudioPlayerState.init().copyWith(currentTrack: track, currentState: CurrentState.loading, seek: Duration.zero));
    try {
      await player.setUrl(track.url);
    } catch (_) {
      // You could emit an error state or show a snackbar
    } finally {
      await player.play();
      emit(state.copyWith(currentTrack: track,
          currentState: CurrentState.playing, duration: player.duration ?? Duration.zero));
    }
  }
  Future<void> pause() async{
    await player.pause();
    emit(state.copyWith(
        currentState: CurrentState.paused, duration: player.duration ?? Duration.zero));
  }
  Future<void> play() async{
    await player.play();
    emit(state.copyWith(
        currentState: CurrentState.playing, duration: player.duration ?? Duration.zero));
  }
  Future<void> seek(Duration position) async{
    await player.seek(position);
    emit(state.copyWith(
        currentState: CurrentState.playing, seek: position));
  }

  Future<void> close() {
    stateSubscription?.cancel();
    durationSubscription?.cancel();
    seekSubscription?.cancel();
    player.dispose();
    return super.close();
  }

}
