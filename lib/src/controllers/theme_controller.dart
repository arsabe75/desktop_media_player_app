import 'package:flutter/material.dart';
import 'package:desktop_media_player_app/src/services/theme_service.dart';

class ThemeController with ChangeNotifier {
  final ThemeService _themeService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeController(this._themeService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadTheme() async {
    _themeMode = await _themeService.getThemeMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    await _themeService.saveThemeMode(_themeMode);
    notifyListeners();
  }
}
