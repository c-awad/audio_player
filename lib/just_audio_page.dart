import 'package:audio_player/player_bloc/just_audio_player_cubit.dart';
import 'package:audio_player/tracks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return BlocBuilder<JustAudioPlayerCubit, JustAudioPlayerState>(
    builder: (context, state) {
      final cubit = context.read<JustAudioPlayerCubit>();
      final canSeek = state.duration > Duration.zero;
      return Scaffold(
        appBar: AppBar(title: const Text('Audio Player Demo'), backgroundColor: Color.fromRGBO(10, 220, 255, 0.8),),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Track selector
              Row(
                children: [
                  const Text('Track:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<Track>(
                      isExpanded: true,
                      value: cubit.state.currentTrack,
                      items: tracks.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.title));
                      }).toList(),
                      onChanged: (t) async {
                        if(t != null){
                          await cubit.loadTrack(t);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Transport controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: ()async{
                      if(cubit.state.currentState == CurrentState.playing){
                        await cubit.pause();
                      }else{
                        await cubit.play();
                      }
                      },
                    icon: cubit.state.currentState == CurrentState.playing? Icon(Icons.pause) : Icon(Icons.play_arrow),
                    label:  Text(cubit.state.currentState == CurrentState.playing?'Pause': 'Play'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: cubit.state.currentState == CurrentState.loading ? null : () async {
                      await cubit.player.stop();
                      await cubit.player.seek(Duration.zero);
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: state.seek.inMilliseconds
                    .clamp(0, state.duration.inMilliseconds)
                    .toDouble(),
                min: 0,
                max: state.duration.inMilliseconds
                    .toDouble()
                    .clamp(1, double.infinity),
                onChanged: canSeek
                    ? (v) => cubit.seek(Duration(milliseconds: v.toInt()))
                    : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDurationString(state.seek)),
                  Text(formatDurationString(state.duration)),
                ],
              ),
              if (cubit.state.currentState == CurrentState.loading) const LinearProgressIndicator(),
            ],
          ),
        ),
      );
    },
    );
  }

  String formatDurationString(Duration d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${h}:${two(m)}:${two(s)}' : '${m}:${two(s)}';
  }

}