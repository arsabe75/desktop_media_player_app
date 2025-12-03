import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/video_player_providers.dart';

/// Playback control buttons (play/pause, fullscreen)
class PlayerControlButtons extends ConsumerWidget {
  const PlayerControlButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(isPlayingProvider);
    final isFullscreen = ref.watch(isFullscreenProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Pause button
        IconButton(
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () {
            ref.read(isPlayingProvider.notifier).togglePlayPause();
            ref.read(controlsVisibilityProvider.notifier).flash();
          },
          tooltip: isPlaying ? 'Pause' : 'Play',
        ),
        const SizedBox(width: 8),
        // Fullscreen button
        IconButton(
          icon: Icon(
            isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () async {
            final newFullscreenState = !isFullscreen;
            await windowManager.setFullScreen(newFullscreenState);
            ref
                .read(isFullscreenProvider.notifier)
                .setFullscreen(newFullscreenState);
            ref.read(controlsVisibilityProvider.notifier).flash();
          },
          tooltip: isFullscreen ? 'Exit Fullscreen' : 'Fullscreen',
        ),
      ],
    );
  }
}
