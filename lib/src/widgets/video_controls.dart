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
  bool _isDragging = false;
  Timer? _hideTimer;
  double _lastVolume = 1.0;

  // Stream controllers to emulate media_kit's streams
  late StreamController<Duration> _positionController;
  late StreamController<double> _volumeController;
  late StreamController<bool> _playingController;

  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();

    // Initialize broadcast stream controllers
    _positionController = StreamController<Duration>.broadcast();
    _volumeController = StreamController<double>.broadcast();
    _playingController = StreamController<bool>.broadcast();

    // Seed streams with initial values to prevent initial flicker
    final initialValue = widget.controller.value;
    _positionController.add(initialValue.position);
    _volumeController.add(initialValue.volume);
    _playingController.add(initialValue.isPlaying);

    // Listener that feeds the streams (throttled to prevent excessive updates)
    Timer? updateTimer;
    _listener = () {
      if (updateTimer?.isActive ?? false) return;
      updateTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && !_isDragging) {
          final value = widget.controller.value;
          _positionController.add(value.position);
          _volumeController.add(value.volume);
          _playingController.add(value.isPlaying);
        }
      });
    };

    widget.controller.addListener(_listener);
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    if (_isDragging) return;
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
    _positionController.close();
    _volumeController.close();
    _playingController.close();
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
    return RepaintBoundary(
      child: MouseRegion(
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
                        StreamBuilder<Duration>(
                          stream: _positionController.stream,
                          initialData: widget.controller.value.position,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = widget.controller.value.duration;
                            return Row(
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Expanded(
                                  child: RepaintBoundary(
                                    child: Slider(
                                      value: position.inMilliseconds
                                          .toDouble()
                                          .clamp(
                                            0,
                                            duration.inMilliseconds.toDouble(),
                                          ),
                                      min: 0,
                                      max: duration.inMilliseconds.toDouble(),
                                      onChanged: (val) {
                                        widget.controller.seekTo(
                                          Duration(milliseconds: val.toInt()),
                                        );
                                      },
                                      onChangeStart: (_) {
                                        _isDragging = true;
                                        _hideTimer?.cancel();
                                      },
                                      onChangeEnd: (_) {
                                        _isDragging = false;
                                        _startHideTimer();
                                      },
                                    ),
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
                            StreamBuilder<bool>(
                              stream: _playingController.stream,
                              initialData: widget.controller.value.isPlaying,
                              builder: (context, snapshot) {
                                final playing = snapshot.data ?? false;
                                return IconButton(
                                  icon: Icon(
                                    playing ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  onPressed: () {
                                    playing
                                        ? widget.controller.pause()
                                        : widget.controller.play();
                                    _startHideTimer();
                                  },
                                );
                              },
                            ),
                            // Volume
                            Row(
                              children: [
                                StreamBuilder<double>(
                                  stream: _volumeController.stream,
                                  initialData: widget.controller.value.volume,
                                  builder: (context, snapshot) {
                                    final volume = snapshot.data ?? 1.0;
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
                                  child: RepaintBoundary(
                                    child: StreamBuilder<double>(
                                      stream: _volumeController.stream,
                                      initialData:
                                          widget.controller.value.volume,
                                      builder: (context, snapshot) {
                                        final volume = snapshot.data ?? 1.0;
                                        return Slider(
                                          value: volume,
                                          min: 0,
                                          max: 1.0,
                                          onChanged: (val) {
                                            widget.controller.setVolume(val);
                                          },
                                          onChangeStart: (_) {
                                            _isDragging = true;
                                            _hideTimer?.cancel();
                                          },
                                          onChangeEnd: (_) {
                                            _isDragging = false;
                                            _startHideTimer();
                                          },
                                        );
                                      },
                                    ),
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
      ),
    );
  }
}
