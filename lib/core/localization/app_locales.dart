import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

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

  static String oppositeLanguageName(Locale locale) => switch (locale.languageCode) {
        'ar' => 'English',
        _ => 'العربية',
      };

  static String fontFamily(Locale locale) =>
      locale.languageCode == 'ar' ? 'Cairo' : 'Manrope';
}

// ── Locale Manager ────────────────────────────────────────────────────────────
/// Manages the active locale and persists it across app sessions
class LocaleManager extends ChangeNotifier {
  static final LocaleManager instance = LocaleManager._internal();

  Locale _locale = AppLocales.english;

  Locale get locale => _locale;
  bool get isRtl => AppLocales.isRtl(_locale);

  factory LocaleManager() => instance;

  LocaleManager._internal() {
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
    final next = _locale.languageCode == 'en'
        ? AppLocales.arabic
        : AppLocales.english;
    await setLocale(next);
  }
}

// ── Language Switch Button Widget ─────────────────────────────────────────────
class LanguageSwitchButton extends StatelessWidget {
  final bool isDark;
  final bool isCompact;

  const LanguageSwitchButton({
    super.key,
    this.isDark = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleManager.instance,
      builder: (context, _) {
        final current = LocaleManager.instance.locale;
        final targetName = AppLocales.oppositeLanguageName(current);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => LocaleManager.instance.toggleLocale(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: isCompact ? 5 : 7,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.08)
                    : AppColors.navyDark.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? AppColors.gold.withValues(alpha: 0.4)
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: isCompact ? 15 : 17,
                    color: isDark ? AppColors.gold : AppColors.royalBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    targetName,
                    style: TextStyle(
                      color: isDark ? AppColors.white : AppColors.navyDark,
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 12 : 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
