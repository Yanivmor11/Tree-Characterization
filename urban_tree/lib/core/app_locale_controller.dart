import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists optional app [locale]; `null` means follow the device language.
class AppLocaleController extends ChangeNotifier {
  AppLocaleController();

  static const _prefsKey = 'app_locale_language_code';

  Locale? _locale;
  bool _ready = false;

  Locale? get locale => _locale;
  bool get isReady => _ready;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) {
      _locale = null;
    } else {
      _locale = Locale(code);
    }
    _ready = true;
    notifyListeners();
  }

  /// `null` = use device default (from [localeResolutionCallback]).
  Future<void> setLocale(Locale? newLocale) async {
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (newLocale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, newLocale.languageCode);
    }
  }
}
