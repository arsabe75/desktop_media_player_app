import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

class VideoControls extends StatefulWidget {
  final Player player;
  final String title;

  const VideoControls({super.key, required this.player, required this.title});

  @override
  @override
  State<VideoControls> createState() => VideoControlsState();
}

class VideoControlsState extends State<VideoControls> {
  bool _visible = true;
  Timer? _hideTimer;
  double _lastVolume = 100.0;

  @override
  void initState() {
    super.initState();
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
    final currentVolume = widget.player.state.volume;
    if (currentVolume > 0) {
      _lastVolume = currentVolume;
      widget.player.setVolume(0);
    } else {
      widget.player.setVolume(_lastVolume > 0 ? _lastVolume : 100.0);
    }
    flashControls();
  }

  void _onHover() {
    flashControls();
  }

  @override
  void dispose() {
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
              widget.player.playOrPause();
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
                      StreamBuilder<Duration>(
                        stream: widget.player.stream.position,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration = widget.player.state.duration;
                          return RepaintBoundary(
                            child: Row(
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: position.inMilliseconds
                                        .toDouble()
                                        .clamp(
                                          0,
                                          duration.inMilliseconds.toDouble(),
                                        ),
                                    min: 0,
                                    max: duration.inMilliseconds.toDouble(),
                                    onChanged: (value) {
                                      widget.player.seek(
                                        Duration(milliseconds: value.toInt()),
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
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Play/Pause
                          StreamBuilder<bool>(
                            stream: widget.player.stream.playing,
                            builder: (context, snapshot) {
                              final playing =
                                  snapshot.data ?? widget.player.state.playing;
                              return IconButton(
                                icon: Icon(
                                  playing ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  widget.player.playOrPause();
                                  _startHideTimer();
                                },
                              );
                            },
                          ),
                          // Volume
                          Row(
                            children: [
                              StreamBuilder<double>(
                                stream: widget.player.stream.volume,
                                builder: (context, snapshot) {
                                  final volume = snapshot.data ?? 100.0;
                                  return IconButton(
                                    icon: Icon(
                                      volume == 0
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                    ),
                                    onPressed: toggleMute,
                                  );
                                },
                              ),
                              SizedBox(
                                width: 100,
                                child: StreamBuilder<double>(
                                  stream: widget.player.stream.volume,
                                  builder: (context, snapshot) {
                                    final volume = snapshot.data ?? 100.0;
                                    return Slider(
                                      value: volume,
                                      min: 0,
                                      max: 100,
                                      onChanged: (value) {
                                        widget.player.setVolume(value);
                                        _startHideTimer();
                                      },
                                    );
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
