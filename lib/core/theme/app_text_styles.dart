import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system for Travella
/// English: Manrope | Arabic: Cairo
class AppTextStyles {
  AppTextStyles._();

  // ── Font Families ──────────────────────────────────────────────────────────
  static const String englishFont = 'Manrope';
  static const String arabicFont = 'Cairo';

  static String fontFamily(Locale locale) =>
      locale.languageCode == 'ar' ? arabicFont : englishFont;

  // ── Display ────────────────────────────────────────────────────────────────
  static const TextStyle displayXL = TextStyle(
    fontFamily: englishFont,
    fontSize: 72,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    height: 1.05,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayLG = TextStyle(
    fontFamily: englishFont,
    fontSize: 56,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMD = TextStyle(
    fontFamily: englishFont,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySM = TextStyle(
    fontFamily: englishFont,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // ── Headings ───────────────────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: englishFont,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: englishFont,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: englishFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: englishFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: englishFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: englishFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // ── Body ───────────────────────────────────────────────────────────────────
  static const TextStyle bodyXL = TextStyle(
    fontFamily: englishFont,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.7,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyLG = TextStyle(
    fontFamily: englishFont,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.7,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: englishFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.65,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySM = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.6,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyXS = TextStyle(
    fontFamily: englishFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ── Labels ─────────────────────────────────────────────────────────────────
  static const TextStyle labelLG = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.4,
  );

  static const TextStyle labelMD = TextStyle(
    fontFamily: englishFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.4,
  );

  static const TextStyle labelSM = TextStyle(
    fontFamily: englishFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.4,
  );

  // ── Button ─────────────────────────────────────────────────────────────────
  static const TextStyle buttonLG = TextStyle(
    fontFamily: englishFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.0,
  );

  static const TextStyle buttonMD = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  static const TextStyle buttonSM = TextStyle(
    fontFamily: englishFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.0,
  );

  // ── Caption / Overline ─────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: englishFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.5,
    color: AppColors.textMuted,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: englishFont,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    height: 1.4,
  );

  static const TextStyle navItem = TextStyle(
    fontFamily: englishFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.0,
  );

  // ── Price ──────────────────────────────────────────────────────────────────
  static const TextStyle priceLG = TextStyle(
    fontFamily: englishFont,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.0,
    color: AppColors.gold,
  );

  static const TextStyle priceMD = TextStyle(
    fontFamily: englishFont,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.0,
    color: AppColors.gold,
  );

  static const TextStyle priceSM = TextStyle(
    fontFamily: englishFont,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.0,
    color: AppColors.gold,
  );

  // ── Responsive helpers ─────────────────────────────────────────────────────
  static TextStyle responsive(
    TextStyle base, {
    double mobileFactor = 0.78,
    double tabletFactor = 0.9,
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return base.copyWith(
        fontSize: base.fontSize != null ? base.fontSize! * mobileFactor : null,
      );
    } else if (isTablet) {
      return base.copyWith(
        fontSize: base.fontSize != null ? base.fontSize! * tabletFactor : null,
      );
    }
    return base;
  }
}
