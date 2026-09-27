import 'package:flutter/material.dart';

/// Travella brand color palette
/// Inspired by: Deep Navy, Royal Blue, Gold, White, Light Gray
class AppColors {
  AppColors._();

  // ── Brand Primary ──────────────────────────────────────────────────────────
  /// Deep Navy — primary brand color
  static const Color navy = Color(0xFF0B1929);

  /// Navy variants
  static const Color navyDark = Color(0xFF060F1A);
  static const Color navyMedium = Color(0xFF0F2236);
  static const Color navyLight = Color(0xFF152D47);

  // ── Brand Secondary ────────────────────────────────────────────────────────
  /// Royal Blue — secondary brand color
  static const Color royalBlue = Color(0xFF1A6BE0);
  static const Color royalBlueDark = Color(0xFF1457B8);
  static const Color royalBlueLight = Color(0xFF2D7EF0);
  static const Color royalBlueFaded = Color(0x1A1A6BE0);

  // ── Brand Accent ───────────────────────────────────────────────────────────
  /// Gold — accent color (use sparingly for CTAs, highlights)
  static const Color gold = Color(0xFFF5B800);
  static const Color goldDark = Color(0xFFCC9800);
  static const Color goldLight = Color(0xFFFFCA28);
  static const Color goldFaded = Color(0x1AF5B800);

  // ── Neutrals ───────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8FAFC);
  static const Color lightGray = Color(0xFFF1F4F8);
  static const Color gray100 = Color(0xFFE8EDF4);
  static const Color gray200 = Color(0xFFCDD5E0);
  static const Color gray300 = Color(0xFFABB8C8);
  static const Color gray400 = Color(0xFF7A8FA6);
  static const Color gray500 = Color(0xFF5A6F84);
  static const Color gray600 = Color(0xFF3E5268);
  static const Color gray700 = Color(0xFF2D3F52);
  static const Color gray800 = Color(0xFF1E2D3D);
  static const Color gray900 = Color(0xFF111E2B);
  static const Color black = Color(0xFF060D14);

  // ── Semantic Colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Gradient Definitions ───────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, navyMedium],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xCC060F1A),
      Color(0x800B1929),
      Color(0x330F2236),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xCC0B1929),
    ],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDark],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royalBlueLight, royalBlue, royalBlueDark],
  );

  // ── Surface Colors ─────────────────────────────────────────────────────────
  static const Color surfaceLight = white;
  static const Color surfaceCard = offWhite;
  static const Color surfaceDark = navyMedium;
  static const Color surfaceNavbar = Color(0xF50B1929);
  static const Color surfaceFooter = navyDark;

  // ── Text Colors ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0B1929);
  static const Color textSecondary = Color(0xFF5A6F84);
  static const Color textMuted = Color(0xFFABB8C8);
  static const Color textLightMuted = textMuted;
  static const Color textOnDark = white;
  static const Color textOnDarkMuted = Color(0xFFCDD5E0);
  static const Color textLightSecondary = textSecondary;
  static const Color textGold = gold;
  static const Color textLink = royalBlue;

  // ── Divider & Border Colors ────────────────────────────────────────────────
  static const Color dividerLight = gray100;
  static const Color dividerDark = Color(0x26FFFFFF);
  static const Color borderLight = gray100;
  static const Color borderMedium = gray200;
  static const Color borderDark = gray600;
  static const Color borderGold = Color(0x4DF5B800);

  // ── Overlay ────────────────────────────────────────────────────────────────
  static const Color overlay20 = Color(0x330B1929);
  static const Color overlay50 = Color(0x800B1929);
  static const Color overlay70 = Color(0xB30B1929);
  static const Color overlay85 = Color(0xD90B1929);
  static const Color shimmerBase = Color(0xFFE8EDF4);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // ── Helper ─────────────────────────────────────────────────────────────────
  static Color withOpacity(Color color, double opacity) =>
      color.withValues(alpha: opacity);
}
