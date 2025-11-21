import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_media_player_app/src/models/video_source.dart';
import 'package:desktop_media_player_app/src/screens/player_screen.dart';
import 'package:desktop_media_player_app/src/controllers/theme_controller.dart';

class HomeScreen extends StatelessWidget {
  final ThemeController? themeController;

  const HomeScreen({super.key, this.themeController});

  Future<void> _openLocalFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'avi', 'mov'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              videoSource: VideoSource(
                pathOrUrl: result.files.single.path!,
                type: VideoSourceType.local,
              ),
            ),
          ),
        );
      }
    }
  }

  void _openUrlDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Video URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'Enter video URL'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      videoSource: VideoSource(
                        pathOrUrl: urlController.text,
                        type: VideoSourceType.network,
                      ),
                    ),
                  ),
                );
              }
            },
            child: const Text('Play'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Desktop Video Player'),
        centerTitle: true,
        actions: [
          if (themeController != null)
            IconButton(
              icon: Icon(
                themeController!.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                themeController!.toggleTheme();
              },
            ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openLocalFile(context),
              icon: const Icon(Icons.folder_open, size: 32),
              label: const Text('Open Local File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 32),
            ElevatedButton.icon(
              onPressed: () => _openUrlDialog(context),
              icon: const Icon(Icons.link, size: 32),
              label: const Text('Open Video URL'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
