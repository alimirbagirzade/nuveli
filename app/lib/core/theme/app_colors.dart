import 'package:flutter/material.dart';

/// Nuveli Ocean Palette
///
/// SADECE STATIC CONST. const TextStyle/Icon/BoxDecoration kullanan tum
/// widget'lar bozulmaz. Default DARK renkler.
///
/// Light tema icin: ColorScheme + Theme.of(context) kullanilir.
class AppColors {
  // Loading skeleton / shimmer placeholder
  static const Color shimmerBase = Color(0xFF143040);

  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // CORE BRAND (her temada ayni)
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF14C8D8);      // Aqua
  static const Color primaryLight = Color(0xFF14C8D8);
  static const Color primaryDark = Color(0xFF051824);
  static const Color primary600 = Color(0xFF0A6C8C);
  static const Color primary500 = Color(0xFF0C7AA0);

  static const Color accent = Color(0xFF7BE6D5);       // Seafoam
  static const Color accentLight = Color(0xFF7BE6D5);
  static const Color accentAqua = Color(0xFF14C8D8);
  static const Color accentSeafoam = Color(0xFF7BE6D5);

  // Status renkleri (her temada ayni)
  static const Color success = Color(0xFF1AA38C);
  static const Color warning = Color(0xFFB87911);
  static const Color error = Color(0xFFC84D5B);
  static const Color info = Color(0xFF14C8D8);

  // ═══════════════════════════════════════════════════════════════
  // DARK COLORS (default - mevcut widget'lar bunlari gorir)
  // ═══════════════════════════════════════════════════════════════
  static const Color background = Color(0xFF051824);
  static const Color surface = Color(0xFF0A2A3D);
  static const Color surfaceMuted = Color(0xFF0F3A52);
  static const Color card = Color(0xFF102B3F);
  static const Color surfaceElevated = Color(0xFF102B3F);
  static const Color surfaceHighlight = Color(0xFF14455F);

  static const Color textPrimary = Color(0xFFF2FCFB);
  static const Color textSecondary = Color(0xFFB8D4D2);
  static const Color textTertiary = Color(0xFF7A95A0);

  static const Color border = Color(0xFF1A3D52);
  static const Color borderStrong = Color(0xFF2A5168);
  static const Color divider = Color(0xFF1A3D52);

  // ═══════════════════════════════════════════════════════════════
  // LIGHT COLORS (statik - direkt erisim icin)
  // ═══════════════════════════════════════════════════════════════
  static const Color lightBackground = Color(0xFFF2FCFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFE6F7F6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceHighlight = Color(0xFFD8F6F5);

  static const Color lightTextPrimary = Color(0xFF0B2231);
  static const Color lightTextSecondary = Color(0xFF4A6472);
  static const Color lightTextTertiary = Color(0xFF7A8C97);

  static const Color lightBorder = Color(0xFFCFE7E6);
  static const Color lightBorderStrong = Color(0xFFA8D4D2);
  static const Color lightPrimary = Color(0xFF0A6C8C);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════
  static const Gradient gradientCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14C8D8), Color(0xFF7BE6D5)],
  );

  static const Gradient gradientPro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF062B45), Color(0xFF0A6C8C)],
  );

  static const Gradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF051824), Color(0xFF0A2A3D), Color(0xFF0F3A52)],
    stops: [0.0, 0.5, 1.0],
  );
}

// ═══════════════════════════════════════════════════════════════
// TEMA-AWARE EXTENSION
// Kullanim: context.appColors.background → tema gore degisir
// ═══════════════════════════════════════════════════════════════
extension AppColorsContext on BuildContext {
  AppColorsTheme get appColors => AppColorsTheme(this);
}

class AppColorsTheme {
  final BuildContext context;
  AppColorsTheme(this.context);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get background => _isDark ? AppColors.background : AppColors.lightBackground;
  Color get surface => _isDark ? AppColors.surface : AppColors.lightSurface;
  Color get surfaceMuted => _isDark ? AppColors.surfaceMuted : AppColors.lightSurfaceMuted;
  Color get card => _isDark ? AppColors.card : AppColors.lightCard;
  Color get surfaceElevated => _isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceElevated;
  Color get surfaceHighlight => _isDark ? AppColors.surfaceHighlight : AppColors.lightSurfaceHighlight;
  Color get textPrimary => _isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => _isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get textTertiary => _isDark ? AppColors.textTertiary : AppColors.lightTextTertiary;
  Color get border => _isDark ? AppColors.border : AppColors.lightBorder;
  Color get borderStrong => _isDark ? AppColors.borderStrong : AppColors.lightBorderStrong;
  Color get divider => border;
  Color get primary => _isDark ? AppColors.primary : AppColors.lightPrimary;
}
