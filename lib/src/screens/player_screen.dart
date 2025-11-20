import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:desktop_media_player_app/src/models/video_source.dart';
import 'package:desktop_media_player_app/src/widgets/video_controls.dart';

class PlayerScreen extends StatefulWidget {
  final VideoSource videoSource;

  const PlayerScreen({super.key, required this.videoSource});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player player;
  late final VideoController controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);

    player.open(Media(widget.videoSource.pathOrUrl));

    // Error handling
    player.stream.error.listen((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Player'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      extendBodyBehindAppBar: true,
      body: _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading video:\n$_errorMessage',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Center(
                  child: Video(
                    controller: controller,
                    controls: NoVideoControls,
                  ),
                ),
                VideoControls(player: player),
              ],
            ),
    );
  }
}
