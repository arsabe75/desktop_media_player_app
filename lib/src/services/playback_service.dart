import 'package:shared_preferences/shared_preferences.dart';

class PlaybackService {
  static const String _prefix = 'playback_pos_';

  Future<void> savePosition(String path, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$path', position.inMilliseconds);
  }

  Future<Duration> getPosition(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('$_prefix$path');
    return ms != null ? Duration(milliseconds: ms) : Duration.zero;
  }
}
