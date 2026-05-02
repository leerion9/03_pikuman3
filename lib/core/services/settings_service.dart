// ?§Ï†ï ?Ä???úÎπÑ?? ?®Í≥º?å¬∑BGM¬∑ÏßÑÎèô¬∑?∏Ïñ¥ ?§Ï†ï??SharedPreferences???Ä?•¬∑Ï°∞?åÌï©?àÎã§.

import 'package:shared_preferences/shared_preferences.dart';

/// ?®Í≥º?å¬∑BGM¬∑ÏßÑÎèô¬∑?∏Ïñ¥ ?§Ï†ï??Î°úÏª¨???Ä?•ÌïòÍ≥?Î∂àÎü¨?§Îäî ?úÎπÑ??
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keySfx = 'settings_sfx';
  static const String _keyMusic = 'settings_music';
  static const String _keyVibration = 'settings_vibration';
  static const String _keyLocale = 'settings_locale';

  /// ?∏Ïñ¥ ÏΩîÎìú (en, ko, es, ja). Í∏∞Î≥∏Í∞?en
  String get localeCode => _prefs.getString(_keyLocale) ?? 'en';

  /// ?®Í≥º???¨ÏÉù ?¨Î? (Í∏∞Î≥∏Í∞?true)
  bool get sfxEnabled => _prefs.getBool(_keySfx) ?? true;

  /// BGM(Î∞∞Í≤Ω ?åÏïÖ) ?¨ÏÉù ?¨Î? (Í∏∞Î≥∏Í∞?true)
  bool get musicEnabled => _prefs.getBool(_keyMusic) ?? true;

  /// ÏßÑÎèô(?ÖÌã±) ?¨Ïö© ?¨Î? (Í∏∞Î≥∏Í∞?true)
  bool get vibrationEnabled => _prefs.getBool(_keyVibration) ?? true;

  /// ?®Í≥º???§Ï†ï ?Ä??
  Future<void> setSfxEnabled(bool value) async {
    await _prefs.setBool(_keySfx, value);
  }

  /// BGM ?§Ï†ï ?Ä??
  Future<void> setMusicEnabled(bool value) async {
    await _prefs.setBool(_keyMusic, value);
  }

  /// ÏßÑÎèô ?§Ï†ï ?Ä??
  Future<void> setVibrationEnabled(bool value) async {
    await _prefs.setBool(_keyVibration, value);
  }

  /// ?∏Ïñ¥ ÏΩîÎìú ?Ä??(en, ko, es, ja)
  Future<void> setLocaleCode(String code) async {
    await _prefs.setString(_keyLocale, code);
  }
}
