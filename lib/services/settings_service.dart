import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyLanguageCode = 'language_code';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyExportFormat = 'export_format';
  static const String _keySaveLocation = 'save_location';
  static const String _keyGridQuality = 'grid_quality';
  static const String _keyDefaultFrameCount = 'default_frame_count';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;

  String get languageCode => _prefs.getString(_keyLanguageCode) ?? 'ar'; // Arabic-first per §4

  ThemeMode get themeMode {
    final val = _prefs.getString(_keyThemeMode);
    if (val == 'light') return ThemeMode.light;
    return ThemeMode.dark; // Dark mode default
  }

  String get defaultExportFormat => _prefs.getString(_keyExportFormat) ?? 'png';

  String? get defaultSaveLocation => _prefs.getString(_keySaveLocation);

  String get gridQuality => _prefs.getString(_keyGridQuality) ?? 'standard';

  int get defaultFrameCount => _prefs.getInt(_keyDefaultFrameCount) ?? 8;

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_keyOnboardingComplete, complete);
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) async {
    await _prefs.setString(_keyLanguageCode, code);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode == ThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> setDefaultExportFormat(String format) async {
    await _prefs.setString(_keyExportFormat, format.toLowerCase());
    notifyListeners();
  }

  Future<void> setDefaultSaveLocation(String? location) async {
    if (location == null) {
      await _prefs.remove(_keySaveLocation);
    } else {
      await _prefs.setString(_keySaveLocation, location);
    }
    notifyListeners();
  }

  Future<void> setGridQuality(String quality) async {
    await _prefs.setString(_keyGridQuality, quality.toLowerCase());
    notifyListeners();
  }

  Future<void> setDefaultFrameCount(int count) async {
    await _prefs.setInt(_keyDefaultFrameCount, count);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
    // Keep onboarding complete or allow user to reset?
    // §8 says "Clear all local data"
    notifyListeners();
  }
}
