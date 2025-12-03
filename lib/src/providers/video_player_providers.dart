import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

part 'video_player_providers.g.dart';

/// Holds the current VideoPlayerController instance
/// This is set by the PlayerScreen when a video is loaded
@Riverpod(keepAlive: true)
class VideoController extends _$VideoController {
  @override
  VideoPlayerController? build() {
    return null;
  }

  void setController(VideoPlayerController? controller) {
    state = controller;
  }
}

/// Provides the current video position with throttled updates (200ms)
/// This prevents excessive rebuilds while maintaining smooth visual feedback
@riverpod
Stream<Duration> videoPosition(Ref ref) async* {
  final controller = ref.watch(videoControllerProvider);

  if (controller == null || !controller.value.isInitialized) {
    yield Duration.zero;
    return;
  }

  // Initial value
  yield controller.value.position;

  // Stream position updates every 200ms
  await for (final _ in Stream.periodic(const Duration(milliseconds: 200))) {
    if (controller.value.isInitialized) {
      yield controller.value.position;
    }
  }
}

/// Provides the video duration
@riverpod
Duration videoDuration(Ref ref) {
  final controller = ref.watch(videoControllerProvider);

  if (controller == null || !controller.value.isInitialized) {
    return Duration.zero;
  }

  return controller.value.duration;
}

/// Provides the current volume level (0.0 - 1.0)
@riverpod
class VideoVolume extends _$VideoVolume {
  @override
  double build() {
    final controller = ref.watch(videoControllerProvider);

    if (controller == null || !controller.value.isInitialized) {
      return 1.0;
    }

    // Listen to controller updates
    void listener() {
      final newVolume = controller.value.volume;
      if (newVolume != state) {
        state = newVolume;
      }
    }

    controller.addListener(listener);
    ref.onDispose(() => controller.removeListener(listener));

    return controller.value.volume;
  }

  void setVolume(double volume) {
    final controller = ref.read(videoControllerProvider);
    controller?.setVolume(volume);
    state = volume;
  }
}

/// Provides the playback state (playing/paused)
@riverpod
class IsPlaying extends _$IsPlaying {
  @override
  bool build() {
    final controller = ref.watch(videoControllerProvider);

    if (controller == null || !controller.value.isInitialized) {
      return false;
    }

    // Listen to controller updates
    void listener() {
      final isPlaying = controller.value.isPlaying;
      if (isPlaying != state) {
        state = isPlaying;
      }
    }

    controller.addListener(listener);
    ref.onDispose(() => controller.removeListener(listener));

    return controller.value.isPlaying;
  }

  void togglePlayPause() {
    final controller = ref.read(videoControllerProvider);
    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    // State update will happen via listener
  }
}

/// Provides fullscreen state
@riverpod
class IsFullscreen extends _$IsFullscreen {
  @override
  bool build() {
    return false;
  }

  void setFullscreen(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }
}

/// Provides controls visibility state (for auto-hide behavior in fullscreen)
@riverpod
class ControlsVisibility extends _$ControlsVisibility {
  Timer? _hideTimer;

  @override
  bool build() {
    ref.onDispose(() {
      _hideTimer?.cancel();
    });
    return true;
  }

  void show() {
    state = true;
    _startHideTimer();
  }

  void hide() {
    state = false;
    _hideTimer?.cancel();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();

    // Only auto-hide if in fullscreen
    final isFullscreen = ref.read(isFullscreenProvider);
    if (!isFullscreen) return;

    _hideTimer = Timer(const Duration(seconds: 3), () {
      // Safety check: don't update if provider was disposed
      if (!ref.mounted) return;
      state = false;
    });
  }

  void flash() {
    show();
  }
}
