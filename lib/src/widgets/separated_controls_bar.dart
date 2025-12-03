import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/video_player_providers.dart';
import 'player_progress_bar.dart';
import 'player_volume_control.dart';
import 'player_control_buttons.dart';
import 'package:path/path.dart' as p;

/// Main controls container - displays below video (not overlay)
/// Auto-hides in fullscreen mode
class SeparatedControlsBar extends ConsumerWidget {
  final String videoTitle;

  const SeparatedControlsBar({super.key, required this.videoTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullscreen = ref.watch(isFullscreenProvider);
    final isVisible = ref.watch(controlsVisibilityProvider);

    // In fullscreen, controls can be hidden
    // In normal mode, always show controls
    if (isFullscreen && !isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: (isFullscreen && !isVisible) ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video title (only in separated mode, not fullscreen)
            if (!isFullscreen) ...[
              Text(
                p.basename(videoTitle),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],

            // Progress bar
            const PlayerProgressBar(),
            const SizedBox(height: 8),

            // Control buttons row
            Row(
              children: [
                const PlayerControlButtons(),
                const Spacer(),
                const PlayerVolumeControl(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
