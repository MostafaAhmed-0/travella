import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// ── Supported Locales ──────────────────────────────────────────────────────────
class AppLocales {
  AppLocales._();

  static const Locale english = Locale('en', 'US');
  static const Locale arabic = Locale('ar', 'EG');

  static const List<Locale> supportedLocales = [english, arabic];

  static const List<LocalizationsDelegate<dynamic>> delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static bool isRtl(Locale locale) => locale.languageCode == 'ar';

  static String languageName(Locale locale) => switch (locale.languageCode) {
        'ar' => 'العربية',
        _ => 'English',
      };

  static String fontFamily(Locale locale) =>
      locale.languageCode == 'ar' ? 'Cairo' : 'Manrope';
}

// ── Locale Cubit ──────────────────────────────────────────────────────────────
/// Manages the active locale and persists it
class LocaleManager extends ChangeNotifier {
  Locale _locale = AppLocales.english;

  Locale get locale => _locale;
  bool get isRtl => AppLocales.isRtl(_locale);

  LocaleManager() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(AppConstants.localeKey);
      if (code != null) {
        final found = AppLocales.supportedLocales
            .where((l) => l.languageCode == code)
            .firstOrNull;
        if (found != null) {
          _locale = found;
          notifyListeners();
        }
      }
    } catch (_) {
      // Silently fall back to default
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.localeKey, locale.languageCode);
    } catch (_) {}
  }

  Future<void> toggleLocale() async {
    final next = _locale == AppLocales.english
        ? AppLocales.arabic
        : AppLocales.english;
    await setLocale(next);
  }
}
