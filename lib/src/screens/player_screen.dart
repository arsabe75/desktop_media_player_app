import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:desktop_media_player_app/src/models/video_source.dart';
import 'package:path/path.dart' as p;
import 'package:desktop_media_player_app/src/widgets/video_controls.dart';

import 'package:window_manager/window_manager.dart';
import 'package:desktop_media_player_app/src/services/playback_service.dart';

class PlayerScreen extends StatefulWidget {
  final VideoSource videoSource;

  const PlayerScreen({super.key, required this.videoSource});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player player;

  late final VideoController controller;
  final _playbackService = PlaybackService();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await player.open(Media(widget.videoSource.pathOrUrl), play: false);

    // Wait for duration to be available
    await player.stream.duration.firstWhere(
      (duration) => duration != Duration.zero,
    );

    await _loadSavedPosition();
    await player.play();

    // Error handling
    player.stream.error.listen((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    });
  }

  @override
  void dispose() {
    _savePosition();
    windowManager.setFullScreen(false);
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          player.playOrPause();
        },
        const SingleActivator(LogicalKeyboardKey.keyF): () async {
          final isFullScreen = await windowManager.isFullScreen();
          windowManager.setFullScreen(!isFullScreen);
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          player.seek(player.state.position + const Duration(seconds: 10));
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          player.seek(player.state.position - const Duration(seconds: 10));
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: null,
          extendBodyBehindAppBar: true,
          body: _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading video:\n$_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Center(
                      child: Video(
                        controller: controller,
                        controls: NoVideoControls,
                      ),
                    ),
                    VideoControls(
                      player: player,
                      title: p.basename(widget.videoSource.pathOrUrl),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _loadSavedPosition() async {
    final position = await _playbackService.getPosition(
      widget.videoSource.pathOrUrl,
    );
    if (position != Duration.zero) {
      await player.seek(position);
    }
  }

  Future<void> _savePosition() async {
    await _playbackService.savePosition(
      widget.videoSource.pathOrUrl,
      player.state.position,
    );
  }
}
