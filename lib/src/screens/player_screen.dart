import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _controller;
  final _playbackService = PlaybackService();
  final GlobalKey<VideoControlsState> _videoControlsKey =
      GlobalKey<VideoControlsState>();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _controller = VideoPlayerController.file(
        File(widget.videoSource.pathOrUrl),
      );
      await _controller!.initialize();
      await _loadSavedPosition();
      await _controller!.play();
      setState(() {});
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  @override
  void dispose() {
    _savePosition();
    windowManager.setFullScreen(false);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          if (_controller != null) {
            _controller!.value.isPlaying
                ? _controller!.pause()
                : _controller!.play();
          }
          _videoControlsKey.currentState?.flashControls();
        },
        const SingleActivator(LogicalKeyboardKey.keyF): () async {
          final isFullScreen = await windowManager.isFullScreen();
          windowManager.setFullScreen(!isFullScreen);
          _videoControlsKey.currentState?.flashControls();
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          if (_controller != null) {
            _controller!.seekTo(
              _controller!.value.position + const Duration(seconds: 10),
            );
          }
          _videoControlsKey.currentState?.flashControls();
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          if (_controller != null) {
            _controller!.seekTo(
              _controller!.value.position - const Duration(seconds: 10),
            );
          }
          _videoControlsKey.currentState?.flashControls();
        },
        const SingleActivator(LogicalKeyboardKey.keyM): () {
          _videoControlsKey.currentState?.toggleMute();
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
                      child:
                          _controller != null &&
                              _controller!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            )
                          : const CircularProgressIndicator(),
                    ),
                    if (_controller != null && _controller!.value.isInitialized)
                      VideoControls(
                        key: _videoControlsKey,
                        controller: _controller!,
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
      await _controller!.seekTo(position);
    }
  }

  Future<void> _savePosition() async {
    await _playbackService.savePosition(
      widget.videoSource.pathOrUrl,
      _controller?.value.position ?? Duration.zero,
    );
  }
}
