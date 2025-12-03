import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/video_player_providers.dart';
import 'custom_track_shape.dart';

/// Progress bar widget showing current position and allowing seeks
class PlayerProgressBar extends ConsumerWidget {
  const PlayerProgressBar({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(videoPositionProvider);
    final duration = ref.watch(videoDurationProvider);
    final controller = ref.watch(videoControllerProvider);

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // Handle async position value
    return positionAsync.when(
      data: (position) => Row(
        children: [
          Text(
            _formatDuration(position),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.3),
                trackShape: CustomTrackShape(),
              ),
              child: Slider(
                value: position.inMilliseconds.toDouble().clamp(
                  0,
                  duration.inMilliseconds.toDouble(),
                ),
                min: 0,
                max: duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  final newPosition = Duration(milliseconds: value.toInt());
                  controller.seekTo(newPosition);
                },
                onChangeStart: (_) {
                  ref.read(controlsVisibilityProvider.notifier).flash();
                },
                onChangeEnd: (_) {
                  ref.read(controlsVisibilityProvider.notifier).flash();
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(duration),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      loading: () =>
          const SizedBox(height: 40, child: Center(child: SizedBox.shrink())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
