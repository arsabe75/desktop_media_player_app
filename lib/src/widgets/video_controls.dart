import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:window_manager/window_manager.dart';

class VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final String title;

  const VideoControls({
    super.key,
    required this.controller,
    required this.title,
  });

  @override
  @override
  State<VideoControls> createState() => VideoControlsState();
}

class VideoControlsState extends State<VideoControls> {
  bool _visible = true;
  Timer? _hideTimer;
  double _lastVolume = 1.0;
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (mounted) setState(() {});
    };
    widget.controller.addListener(_listener);
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  void flashControls() {
    if (!_visible) {
      setState(() {
        _visible = true;
      });
    }
    _startHideTimer();
  }

  void toggleMute() {
    final currentVolume = widget.controller.value.volume;
    if (currentVolume > 0) {
      _lastVolume = currentVolume;
      widget.controller.setVolume(0);
    } else {
      widget.controller.setVolume(_lastVolume > 0 ? _lastVolume : 1.0);
    }
    flashControls();
  }

  void _onHover() {
    flashControls();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    _hideTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: ValueKey(_visible),
      cursor: _visible ? SystemMouseCursors.basic : SystemMouseCursors.none,
      onHover: (_) => _onHover(),
      child: Stack(
        children: [
          // Invisible container to catch hover events across the entire screen
          GestureDetector(
            onTap: () {
              widget.controller.value.isPlaying
                  ? widget.controller.pause()
                  : widget.controller.play();
              _startHideTimer();
            },
            onDoubleTap: () async {
              bool isFullScreen = await windowManager.isFullScreen();
              if (isFullScreen) {
                windowManager.setFullScreen(false);
              } else {
                windowManager.setFullScreen(true);
              }
              _startHideTimer();
            },
            child: Container(color: Colors.transparent),
          ),

          // Top Bar (Back button + Title)
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const BackButton(color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Controls Overlay
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress Bar
                      Builder(
                        builder: (context) {
                          final position = widget.controller.value.position;
                          final duration = widget.controller.value.duration;
                          return Row(
                            children: [
                              Text(
                                _formatDuration(position),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Slider(
                                  value: position.inSeconds.toDouble().clamp(
                                    0,
                                    duration.inSeconds.toDouble(),
                                  ),
                                  min: 0,
                                  max: duration.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    widget.controller.seekTo(
                                      Duration(seconds: value.toInt()),
                                    );
                                    _startHideTimer();
                                  },
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Play/Pause
                          IconButton(
                            icon: Icon(
                              widget.controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              widget.controller.value.isPlaying
                                  ? widget.controller.pause()
                                  : widget.controller.play();
                              _startHideTimer();
                            },
                          ),
                          // Volume
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  widget.controller.value.volume == 0
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
                                ),
                                onPressed: toggleMute,
                              ),
                              SizedBox(
                                width: 100,
                                child: Slider(
                                  value: widget.controller.value.volume,
                                  min: 0,
                                  max: 1.0,
                                  onChanged: (value) {
                                    widget.controller.setVolume(value);
                                    _startHideTimer();
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Fullscreen
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () async {
                              bool isFullScreen = await windowManager
                                  .isFullScreen();
                              if (isFullScreen) {
                                windowManager.setFullScreen(false);
                              } else {
                                windowManager.setFullScreen(true);
                              }
                              _startHideTimer();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
