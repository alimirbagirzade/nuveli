import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Nuveli App Theme
///
/// İki tema:
///   - AppTheme.dark()  → Default (premium hissi)
///   - AppTheme.light() → Web ile uyumlu (soft mint)
///
/// Kullanıcı Settings ekranından seçer.
/// Tercih shared_preferences'ta saklanır.
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME (DEFAULT)
  // ═══════════════════════════════════════════════════════════════

  static ThemeData dark() {
    final colors = AppColors.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        onPrimary: colors.textOnAccent,
        secondary: colors.accent,
        onSecondary: colors.textOnAccent,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: colors.border,
        surfaceContainerHighest: colors.surfaceMuted,
      ),

      // Backgrounds
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      cardColor: colors.card,
      dividerColor: colors.divider,

      // System UI
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
      ),

      // Bottom nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnAccent,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonLarge,
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textTertiary),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),

      // Bottom sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.4);
          }
          return colors.border;
        }),
      ),

      // Typography
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: colors.textPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: colors.textPrimary),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: colors.textPrimary),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: colors.textPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colors.textTertiary),
      ),

      // Misc
      splashFactory: InkSparkle.splashFactory,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME (Web uyumlu, opsiyonel)
  // ═══════════════════════════════════════════════════════════════

  static ThemeData light() {
    final colors = AppColors.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: colors.textOnAccent,
        secondary: colors.accent,
        onSecondary: colors.primaryDark,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
        outline: colors.border,
        surfaceContainerHighest: colors.surfaceMuted,
      ),

      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.surface,
      cardColor: colors.card,
      dividerColor: colors.divider,

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: colors.textPrimary,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonLarge,
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primaryDark,
          side: BorderSide(color: colors.borderStrong),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accentAqua, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: colors.textTertiary),
      ),

      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.4);
          }
          return colors.border;
        }),
      ),

      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: colors.textPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: colors.textPrimary),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: colors.textPrimary),
        headlineMedium: AppTextStyles.headingMedium.copyWith(color: colors.textPrimary),
        headlineSmall: AppTextStyles.headingSmall.copyWith(color: colors.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: colors.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: colors.textPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: colors.textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: colors.textTertiary),
      ),

      splashFactory: InkSparkle.splashFactory,
    );
  }
}
