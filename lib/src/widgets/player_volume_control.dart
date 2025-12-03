import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/video_player_providers.dart';
import 'custom_track_shape.dart';

/// Volume control widget with mute button and slider
class PlayerVolumeControl extends ConsumerStatefulWidget {
  const PlayerVolumeControl({super.key});

  @override
  ConsumerState<PlayerVolumeControl> createState() =>
      _PlayerVolumeControlState();
}

class _PlayerVolumeControlState extends ConsumerState<PlayerVolumeControl> {
  double _lastNonZeroVolume = 1.0;

  void _toggleMute() {
    final currentVolume = ref.read(videoVolumeProvider);

    if (currentVolume > 0) {
      _lastNonZeroVolume = currentVolume;
      ref.read(videoVolumeProvider.notifier).setVolume(0);
    } else {
      ref.read(videoVolumeProvider.notifier).setVolume(_lastNonZeroVolume);
    }

    ref.read(controlsVisibilityProvider.notifier).flash();
  }

  @override
  Widget build(BuildContext context) {
    final volume = ref.watch(videoVolumeProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            volume == 0
                ? Icons.volume_off
                : volume < 0.5
                ? Icons.volume_down
                : Icons.volume_up,
            color: Colors.white,
            size: 26,
          ),
          onPressed: _toggleMute,
          tooltip: volume == 0 ? 'Unmute' : 'Mute',
        ),
        SizedBox(
          width: 100,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.3),
              trackShape: CustomTrackShape(),
            ),
            child: Slider(
              value: volume,
              min: 0,
              max: 1.0,
              onChanged: (value) {
                ref.read(videoVolumeProvider.notifier).setVolume(value);
                if (value > 0) {
                  _lastNonZeroVolume = value;
                }
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
      ],
    );
  }
}
