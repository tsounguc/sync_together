import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider extends ChangeNotifier {
  ThemeModeProvider(this._prefs) {
    final theme = _prefs.getString(_key) ?? 'system';
    _themeMode = _getThemeModeFromString(theme);
  }

  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setString(_key, mode.name);
    notifyListeners();
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
