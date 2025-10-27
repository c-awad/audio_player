
import 'dart:async';

import 'package:audio_player/tracks.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';





class AudioPlayerDemo extends StatefulWidget {
  const AudioPlayerDemo({super.key});

  @override
  State<AudioPlayerDemo> createState() => _AudioPlayerDemoState();
}


class _AudioPlayerDemoState extends State<AudioPlayerDemo> {
  final _player = AudioPlayer();

  Track? _selected;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<PlayerState>? _stateSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selected = tracks.first;
    _initAudioSession().then((_) => _loadSelected());
    _posSub = _player.positionStream.listen((p) {
      setState(() => _position = p);
    });
    _player.durationStream.listen((d) {
      setState(() => _duration = d ?? Duration.zero);
    });
    _stateSub = _player.playerStateStream.listen((s) {
      setState(() => _isLoading = s.processingState == ProcessingState.loading ||
          s.processingState == ProcessingState.buffering);
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _loadSelected() async {
    if (_selected == null) return;
    try {
      setState(() => _isLoading = true);
      await _player.setUrl(_selected!.url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load audio: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${h}:${two(m)}:${two(s)}' : '${m}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _player.playing;
    final canSeek = _duration > Duration.zero;

    return Scaffold(
      appBar: AppBar(title: const Text('Citizen DJ Audio Player')),
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
                    value: _selected,
                    items: tracks.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.title));
                    }).toList(),
                    onChanged: (t) async {
                      setState(() => _selected = t);
                      await _loadSelected();
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
                  onPressed: _isLoading ? null : () => _player.play(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _player.pause(),
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () async {
                    await _player.stop();
                    await _player.seek(Duration.zero);
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Seek bar
            Column(
              children: [
                Slider(
                  value: (_position.inMilliseconds).clamp(0, _duration.inMilliseconds).toDouble(),
                  onChanged: canSeek
                      ? (v) => _player.seek(Duration(milliseconds: v.toInt()))
                      : null,
                  min: 0,
                  max: _duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmt(_position)),
                    Text(_fmt(_duration)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              isPlaying ? 'Playing' : 'Paused',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            const Text(
              'Audio courtesy of Citizen DJ / Free Music Archive (public domain).',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
