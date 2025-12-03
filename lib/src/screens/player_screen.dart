import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:desktop_media_player_app/src/models/video_source.dart';
import 'package:desktop_media_player_app/src/widgets/separated_controls_bar.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_media_player_app/src/services/playback_service.dart';
import 'package:desktop_media_player_app/src/providers/video_player_providers.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final VideoSource videoSource;

  const PlayerScreen({super.key, required this.videoSource});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _controller;
  final _playbackService = PlaybackService();
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

      // Set controller in provider
      ref.read(videoControllerProvider.notifier).setController(_controller);

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
    _controller?.pause(); // Ensure video stops playing
    windowManager.setFullScreen(false);
    // Use a microtask to avoid modifying provider during build/dispose cycle if possible,
    // though here it's likely safe.
    Future.microtask(() {
      if (mounted) {
        ref.read(videoControllerProvider.notifier).setController(null);
      }
    });
    _controller?.dispose();
    super.dispose();
  }

  void _handleMouseMove() {
    ref.read(controlsVisibilityProvider.notifier).show();
  }

  @override
  Widget build(BuildContext context) {
    final controlsVisible = ref.watch(controlsVisibilityProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          ref.read(isPlayingProvider.notifier).togglePlayPause();
          ref.read(controlsVisibilityProvider.notifier).flash();
        },
        const SingleActivator(LogicalKeyboardKey.keyF): () async {
          ref.read(isFullscreenProvider.notifier).toggle();
          final newState = ref.read(isFullscreenProvider);
          await windowManager.setFullScreen(newState);
          ref.read(controlsVisibilityProvider.notifier).flash();
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          if (_controller != null) {
            final newPosition =
                _controller!.value.position + const Duration(seconds: 10);
            _controller!.seekTo(newPosition);
          }
          ref.read(controlsVisibilityProvider.notifier).flash();
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          if (_controller != null) {
            final newPosition =
                _controller!.value.position - const Duration(seconds: 10);
            _controller!.seekTo(newPosition);
          }
          ref.read(controlsVisibilityProvider.notifier).flash();
        },
        const SingleActivator(LogicalKeyboardKey.keyM): () {
          final currentVolume = ref.read(videoVolumeProvider);
          if (currentVolume > 0) {
            ref.read(videoVolumeProvider.notifier).setVolume(0);
          } else {
            ref.read(videoVolumeProvider.notifier).setVolume(1.0);
          }
          ref.read(controlsVisibilityProvider.notifier).flash();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: null,
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
              : MouseRegion(
                  onHover: (_) => _handleMouseMove(),
                  cursor: controlsVisible
                      ? SystemMouseCursors.basic
                      : SystemMouseCursors.none,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(isPlayingProvider.notifier).togglePlayPause();
                      ref.read(controlsVisibilityProvider.notifier).flash();
                    },
                    onDoubleTap: () async {
                      ref.read(isFullscreenProvider.notifier).toggle();
                      final newState = ref.read(isFullscreenProvider);
                      await windowManager.setFullScreen(newState);
                      ref.read(controlsVisibilityProvider.notifier).flash();
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            // Video player area
                            Expanded(
                              child: Center(
                                child:
                                    _controller != null &&
                                        _controller!.value.isInitialized
                                    ? AspectRatio(
                                        aspectRatio:
                                            _controller!.value.aspectRatio,
                                        child: VideoPlayer(_controller!),
                                      )
                                    : const CircularProgressIndicator(),
                              ),
                            ),

                            // Separated controls bar
                            if (_controller != null &&
                                _controller!.value.isInitialized)
                              SeparatedControlsBar(
                                videoTitle: widget.videoSource.pathOrUrl,
                              ),
                          ],
                        ),

                        // Back button overlay (top-left)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: AnimatedOpacity(
                            opacity: controlsVisible ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: IgnorePointer(
                              ignoring: !controlsVisible,
                              child: SafeArea(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const BackButton(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
