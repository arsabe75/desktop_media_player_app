// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_player_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current VideoPlayerController instance
/// This is set by the PlayerScreen when a video is loaded

@ProviderFor(VideoController)
const videoControllerProvider = VideoControllerProvider._();

/// Holds the current VideoPlayerController instance
/// This is set by the PlayerScreen when a video is loaded
final class VideoControllerProvider
    extends $NotifierProvider<VideoController, VideoPlayerController?> {
  /// Holds the current VideoPlayerController instance
  /// This is set by the PlayerScreen when a video is loaded
  const VideoControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoControllerHash();

  @$internal
  @override
  VideoController create() => VideoController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VideoPlayerController? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VideoPlayerController?>(value),
    );
  }
}

String _$videoControllerHash() => r'abaae9576e97f908b5231675c36e3f4a30904464';

/// Holds the current VideoPlayerController instance
/// This is set by the PlayerScreen when a video is loaded

abstract class _$VideoController extends $Notifier<VideoPlayerController?> {
  VideoPlayerController? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<VideoPlayerController?, VideoPlayerController?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VideoPlayerController?, VideoPlayerController?>,
              VideoPlayerController?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provides the current video position with throttled updates (200ms)
/// This prevents excessive rebuilds while maintaining smooth visual feedback

@ProviderFor(videoPosition)
const videoPositionProvider = VideoPositionProvider._();

/// Provides the current video position with throttled updates (200ms)
/// This prevents excessive rebuilds while maintaining smooth visual feedback

final class VideoPositionProvider
    extends
        $FunctionalProvider<AsyncValue<Duration>, Duration, Stream<Duration>>
    with $FutureModifier<Duration>, $StreamProvider<Duration> {
  /// Provides the current video position with throttled updates (200ms)
  /// This prevents excessive rebuilds while maintaining smooth visual feedback
  const VideoPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoPositionHash();

  @$internal
  @override
  $StreamProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Duration> create(Ref ref) {
    return videoPosition(ref);
  }
}

String _$videoPositionHash() => r'2e4b69d4e118bd23100c9f50cdc708d31876e81d';

/// Provides the video duration

@ProviderFor(videoDuration)
const videoDurationProvider = VideoDurationProvider._();

/// Provides the video duration

final class VideoDurationProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Provides the video duration
  const VideoDurationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoDurationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoDurationHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return videoDuration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$videoDurationHash() => r'9a798b8a2e5652b94d86b2995798ab0a1b5db823';

/// Provides the current volume level (0.0 - 1.0)

@ProviderFor(VideoVolume)
const videoVolumeProvider = VideoVolumeProvider._();

/// Provides the current volume level (0.0 - 1.0)
final class VideoVolumeProvider extends $NotifierProvider<VideoVolume, double> {
  /// Provides the current volume level (0.0 - 1.0)
  const VideoVolumeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'videoVolumeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$videoVolumeHash();

  @$internal
  @override
  VideoVolume create() => VideoVolume();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$videoVolumeHash() => r'df6fff0e049336c0b7cf8cd1c3b0eb6a6f415c00';

/// Provides the current volume level (0.0 - 1.0)

abstract class _$VideoVolume extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provides the playback state (playing/paused)

@ProviderFor(IsPlaying)
const isPlayingProvider = IsPlayingProvider._();

/// Provides the playback state (playing/paused)
final class IsPlayingProvider extends $NotifierProvider<IsPlaying, bool> {
  /// Provides the playback state (playing/paused)
  const IsPlayingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isPlayingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isPlayingHash();

  @$internal
  @override
  IsPlaying create() => IsPlaying();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isPlayingHash() => r'850937b7ee306e7afac45e4fad3058832adb6e09';

/// Provides the playback state (playing/paused)

abstract class _$IsPlaying extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provides fullscreen state

@ProviderFor(IsFullscreen)
const isFullscreenProvider = IsFullscreenProvider._();

/// Provides fullscreen state
final class IsFullscreenProvider extends $NotifierProvider<IsFullscreen, bool> {
  /// Provides fullscreen state
  const IsFullscreenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isFullscreenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isFullscreenHash();

  @$internal
  @override
  IsFullscreen create() => IsFullscreen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isFullscreenHash() => r'1618fd55ff4bc77f3e29f2557133f35792458251';

/// Provides fullscreen state

abstract class _$IsFullscreen extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provides controls visibility state (for auto-hide behavior in fullscreen)

@ProviderFor(ControlsVisibility)
const controlsVisibilityProvider = ControlsVisibilityProvider._();

/// Provides controls visibility state (for auto-hide behavior in fullscreen)
final class ControlsVisibilityProvider
    extends $NotifierProvider<ControlsVisibility, bool> {
  /// Provides controls visibility state (for auto-hide behavior in fullscreen)
  const ControlsVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'controlsVisibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$controlsVisibilityHash();

  @$internal
  @override
  ControlsVisibility create() => ControlsVisibility();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$controlsVisibilityHash() =>
    r'540946f4c8fdcd4ec7464b87865a1559b6830b66';

/// Provides controls visibility state (for auto-hide behavior in fullscreen)

abstract class _$ControlsVisibility extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
