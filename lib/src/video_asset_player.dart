import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'asset_message.dart';

/// Displays a video asset with playback and scrubbing controls.
class VideoAssetPlayer extends StatefulWidget {
  const VideoAssetPlayer({super.key, required this.asset, this.package});

  final String asset;
  final String? package;

  @override
  State<VideoAssetPlayer> createState() => _VideoAssetState();
}

class _VideoAssetState extends State<VideoAssetPlayer> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialized;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.asset,
      package: widget.package,
    );
    _controller.addListener(_handleControllerUpdate);
    _initialized = _controller.initialize();
  }

  void _handleControllerUpdate() {
    final isPlaying = _controller.value.isPlaying;
    if (mounted && isPlaying != _isPlaying) {
      setState(() => _isPlaying = isPlaying);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
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
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
            VideoProgressIndicator(_controller, allowScrubbing: true),
            IconButton(
              tooltip: _isPlaying ? 'Pause' : 'Play',
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                _isPlaying ? _controller.pause() : _controller.play();
              },
            ),
          ],
        );
      },
    );
  }
}
