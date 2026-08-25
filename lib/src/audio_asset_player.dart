import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'asset_message.dart';

/// Displays an audio asset with playback and seeking controls.
class AudioAssetPlayer extends StatefulWidget {
  const AudioAssetPlayer({super.key, required this.asset});

  final String asset;

  @override
  State<AudioAssetPlayer> createState() => _AudioAssetState();
}

class _AudioAssetState extends State<AudioAssetPlayer> {
  late final AudioPlayer _player;
  late final Future<Duration?> _initialized;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initialized = _player.setAsset(widget.asset);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Duration?>(
      future: _initialized,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AssetMessage(
            icon: Icons.error_outline,
            message: 'Unable to play ${widget.asset}',
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, state) {
              final playing = state.data?.playing ?? false;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.audio_file, size: 72),
                  const SizedBox(height: 16),
                  Text(widget.asset, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, position) {
                      final duration = _player.duration ?? Duration.zero;
                      final value = position.data ?? Duration.zero;
                      return Slider(
                        max: duration.inMilliseconds
                            .toDouble()
                            .clamp(1.0, double.infinity)
                            .toDouble(),
                        value: value.inMilliseconds
                            .clamp(0, duration.inMilliseconds)
                            .toDouble(),
                        onChanged: (milliseconds) => _player.seek(
                          Duration(milliseconds: milliseconds.round()),
                        ),
                      );
                    },
                  ),
                  IconButton.filled(
                    tooltip: playing ? 'Pause' : 'Play',
                    icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    onPressed: playing ? _player.pause : _player.play,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
