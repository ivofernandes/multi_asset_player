import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'asset_message.dart';
import 'media_time.dart';

/// Displays a video asset with playback and scrubbing controls.
class VideoAssetPlayer extends StatefulWidget {
  const VideoAssetPlayer({
    super.key,
    required this.asset,
    this.package,
    this.network = false,
  });

  final String asset;
  final String? package;
  final bool network;

  @override
  State<VideoAssetPlayer> createState() => _VideoAssetState();
}

class _VideoAssetState extends State<VideoAssetPlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialized;

  @override
  void initState() {
    super.initState();
    _controller = widget.network
        ? VideoPlayerController.networkUrl(Uri.parse(widget.asset))
        : VideoPlayerController.asset(
            widget.asset,
            package: widget.package,
          );
    _initialized = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
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
        return ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller,
          builder: (context, value, child) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              VideoProgressIndicator(_controller, allowScrubbing: true),
              Text(mediaTimerLabel(value.position, value.duration)),
              IconButton(
                tooltip: value.isPlaying ? 'Pause' : 'Play',
                icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  value.isPlaying ? _controller.pause() : _controller.play();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
