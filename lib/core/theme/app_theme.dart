import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Material 3 theme configuration for Travella
class AppTheme {
  AppTheme._();

  // ── Light Theme (Primary) ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Primary
      primary: AppColors.royalBlue,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.royalBlueFaded,
      onPrimaryContainer: AppColors.royalBlueDark,
      // Secondary
      secondary: AppColors.navy,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.navyLight,
      onSecondaryContainer: AppColors.white,
      // Tertiary (Gold accent)
      tertiary: AppColors.gold,
      onTertiary: AppColors.navy,
      tertiaryContainer: AppColors.goldFaded,
      onTertiaryContainer: AppColors.goldDark,
      // Error
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.error,
      // Background
      surface: AppColors.white,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.lightGray,
      onSurfaceVariant: AppColors.textSecondary,
      // Outline
      outline: AppColors.borderMedium,
      outlineVariant: AppColors.borderLight,
      // Shadow & Scrim
      shadow: AppColors.navy.withValues(alpha: 0.08),
      scrim: AppColors.navy.withValues(alpha: 0.5),
      // Inverse
      inverseSurface: AppColors.navy,
      onInverseSurface: AppColors.white,
      inversePrimary: AppColors.royalBlueLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.englishFont,

      // Scaffold
      scaffoldBackgroundColor: AppColors.white,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.surfaceNavbar,
        foregroundColor: AppColors.white,
        titleTextStyle: AppTextStyles.h5.copyWith(color: AppColors.white),
        iconTheme: const IconThemeData(color: AppColors.white, size: 24),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        color: AppColors.white,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
      ),

      // ElevatedButton (Primary CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.royalBlue,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.gray200,
          disabledForegroundColor: AppColors.gray400,
          textStyle: AppTextStyles.buttonMD,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // FilledButton (Gold CTA)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navy,
          textStyle: AppTextStyles.buttonMD,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.royalBlue,
          side: const BorderSide(color: AppColors.royalBlue, width: 1.5),
          textStyle: AppTextStyles.buttonMD,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.royalBlue,
          textStyle: AppTextStyles.buttonSM,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // InputDecoration (Form fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.royalBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.textMuted),
        labelStyle:
            AppTextStyles.bodySM.copyWith(color: AppColors.textSecondary),
        prefixIconColor: AppColors.gray400,
        suffixIconColor: AppColors.gray400,
        errorStyle: AppTextStyles.bodyXS.copyWith(color: AppColors.error),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGray,
        selectedColor: AppColors.royalBlueFaded,
        labelStyle: AppTextStyles.labelMD,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppColors.gray500,
        size: 22,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.bodyXS.copyWith(color: AppColors.white),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy,
        contentTextStyle: AppTextStyles.bodyMD.copyWith(color: AppColors.white),
        actionTextColor: AppColors.gold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Navigation Bar (Mobile bottom nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        indicatorColor: AppColors.royalBlueFaded,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelMD.copyWith(color: AppColors.royalBlue);
          }
          return AppTextStyles.labelMD.copyWith(color: AppColors.gray400);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.royalBlue, size: 24);
          }
          return const IconThemeData(color: AppColors.gray400, size: 24);
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.royalBlue,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayXL,
        displayMedium: AppTextStyles.displayLG,
        displaySmall: AppTextStyles.displayMD,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h4,
        titleMedium: AppTextStyles.h5,
        titleSmall: AppTextStyles.h6,
        bodyLarge: AppTextStyles.bodyLG,
        bodyMedium: AppTextStyles.bodyMD,
        bodySmall: AppTextStyles.bodySM,
        labelLarge: AppTextStyles.labelLG,
        labelMedium: AppTextStyles.labelMD,
        labelSmall: AppTextStyles.labelSM,
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.royalBlueLight,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.royalBlueDark,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.gray200,
      onSecondary: AppColors.navy,
      secondaryContainer: AppColors.navyMedium,
      onSecondaryContainer: AppColors.gray200,
      tertiary: AppColors.goldLight,
      onTertiary: AppColors.navy,
      tertiaryContainer: AppColors.goldDark,
      onTertiaryContainer: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: AppColors.errorLight,
      onErrorContainer: AppColors.error,
      surface: AppColors.navyDark,
      onSurface: AppColors.white,
      surfaceContainerHighest: AppColors.navyMedium,
      onSurfaceVariant: AppColors.gray300,
      outline: AppColors.gray600,
      outlineVariant: AppColors.gray700,
      shadow: Colors.black.withValues(alpha: 0.3),
      scrim: Colors.black.withValues(alpha: 0.6),
      inverseSurface: AppColors.gray100,
      onInverseSurface: AppColors.navy,
      inversePrimary: AppColors.royalBlue,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.englishFont,
      scaffoldBackgroundColor: AppColors.navyDark,
    );
  }
}
