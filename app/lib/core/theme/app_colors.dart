import 'package:flutter/material.dart';

/// Nuveli Ocean Palette — Light + Dark
///
/// Web sitesi (nuveli.com.tr) ile birebir uyumlu.
/// Default: Dark (premium hissi)
/// Toggle: Settings ekranında
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // CORE BRAND TOKENS — Her iki temada da AYNI kalır
  // ═══════════════════════════════════════════════════════════════

  /// Aksent rengi — her iki temada da aqua mavi (CTA, link, vurgu)
  static const Color accentAqua = Color(0xFF14C8D8);

  /// Seafoam — gradient bitişi
  static const Color accentSeafoam = Color(0xFF7BE6D5);

  /// Deep ocean — primary 600
  static const Color primary600 = Color(0xFF0A6C8C);

  /// Bright ocean — primary 500
  static const Color primary500 = Color(0xFF0C7AA0);

  // ═══════════════════════════════════════════════════════════════
  // STATUS COLORS — Her iki temada da AYNI
  // ═══════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF1AA38C);
  static const Color warning = Color(0xFFB87911);
  static const Color error = Color(0xFFC84D5B);
  static const Color info = Color(0xFF14C8D8);

  // ═══════════════════════════════════════════════════════════════
  // LIGHT THEME — Web ile birebir
  // ═══════════════════════════════════════════════════════════════

  static const _LightColors light = _LightColors();

  // ═══════════════════════════════════════════════════════════════
  // DARK THEME — Premium ocean night (default)
  // ═══════════════════════════════════════════════════════════════

  static const _DarkColors dark = _DarkColors();

  // ═══════════════════════════════════════════════════════════════
  // BACKWARD COMPATIBILITY — Eski kod bozulmasın
  // (Eski kod doğrudan AppColors.background gibi çağırabilir)
  // ═══════════════════════════════════════════════════════════════

  // Default = dark (mevcut app'i bozma)
  static const Color background = Color(0xFF051824);
  static const Color surface = Color(0xFF0A2A3D);
  static const Color surfaceMuted = Color(0xFF0F3A52);
  static const Color card = Color(0xFF102B3F);
  static const Color textPrimary = Color(0xFFF2FCFB);
  static const Color textSecondary = Color(0xFFB8D4D2);
  static const Color textTertiary = Color(0xFF7A95A0);
  static const Color border = Color(0xFF1A3D52);
  static const Color borderStrong = Color(0xFF2A5168);
  static const Color divider = Color(0xFF1A3D52);
  static const Color primary = Color(0xFF14C8D8);
  static const Color accent = Color(0xFF7BE6D5);
  static const Color primaryDark = Color(0xFF051824);
  static const Color primaryLight = Color(0xFF14C8D8);
  static const Color accentLight = Color(0xFF7BE6D5);
  static const Color surfaceElevated = Color(0xFF102B3F);
  static const Color surfaceHighlight = Color(0xFF14455F);

  // Gradients (default = dark)
  static const Gradient gradientCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14C8D8), Color(0xFF7BE6D5)],
  );

  static const Gradient gradientPro = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF051824), Color(0xFF0A6C8C)],
  );

  static const Gradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF051824), Color(0xFF0A2A3D), Color(0xFF0F3A52)],
    stops: [0.0, 0.5, 1.0],
  );
}

/// Light theme color tokens
class _LightColors {
  const _LightColors();

  // Backgrounds
  Color get background => const Color(0xFFF2FCFB);
  Color get surface => const Color(0xFFFFFFFF);
  Color get surfaceMuted => const Color(0xFFE6F7F6);
  Color get surfaceDeeper => const Color(0xFFD8F6F5);
  Color get card => const Color(0xFFFFFFFF);

  // Text
  Color get textPrimary => const Color(0xFF0B2231);
  Color get textSecondary => const Color(0xFF4A6472);
  Color get textTertiary => const Color(0xFF7A8C97);
  Color get textOnAccent => const Color(0xFFFFFFFF);

  // Borders
  Color get border => const Color(0xFFCFE7E6);
  Color get borderStrong => const Color(0xFFA8D4D2);
  Color get divider => const Color(0xFFCFE7E6);

  // Brand
  Color get primary => const Color(0xFF0A6C8C);
  Color get accent => const Color(0xFF14C8D8);
  Color get primaryDark => const Color(0xFF062B45);

  // Gradients
  Gradient get gradientCta => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A6C8C), Color(0xFF0C7AA0)],
      );

  Gradient get gradientHero => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF2FCFB), Color(0xFFE6F7F6), Color(0xFFD8F6F5)],
        stops: [0.0, 0.42, 1.0],
      );

  Gradient get gradientPro => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF062B45), Color(0xFF0A6C8C)],
      );

  Gradient get gradientAqua => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14C8D8), Color(0xFF7BE6D5)],
      );

  // Shadows
  List<BoxShadow> get shadowCard => [
        BoxShadow(
          color: const Color(0xFF062B45).withValues(alpha: 0.08),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get shadowCta => [
        BoxShadow(
          color: const Color(0xFF0A6C8C).withValues(alpha: 0.28),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

/// Dark theme color tokens (default)
class _DarkColors {
  const _DarkColors();

  // Backgrounds
  Color get background => const Color(0xFF051824);
  Color get surface => const Color(0xFF0A2A3D);
  Color get surfaceMuted => const Color(0xFF0F3A52);
  Color get surfaceDeeper => const Color(0xFF14455F);
  Color get card => const Color(0xFF102B3F);

  // Text
  Color get textPrimary => const Color(0xFFF2FCFB);
  Color get textSecondary => const Color(0xFFB8D4D2);
  Color get textTertiary => const Color(0xFF7A95A0);
  Color get textOnAccent => const Color(0xFF051824);

  // Borders
  Color get border => const Color(0xFF1A3D52);
  Color get borderStrong => const Color(0xFF2A5168);
  Color get divider => const Color(0xFF1A3D52);

  // Brand
  Color get primary => const Color(0xFF14C8D8);
  Color get accent => const Color(0xFF7BE6D5);
  Color get primaryDark => const Color(0xFF051824);

  // Gradients
  Gradient get gradientCta => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14C8D8), Color(0xFF7BE6D5)],
      );

  Gradient get gradientHero => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF051824), Color(0xFF0A2A3D), Color(0xFF0F3A52)],
        stops: [0.0, 0.5, 1.0],
      );

  Gradient get gradientPro => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF051824), Color(0xFF0A6C8C)],
      );

  Gradient get gradientAqua => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF14C8D8), Color(0xFF7BE6D5)],
      );

  // Shadows
  List<BoxShadow> get shadowCard => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ];

  List<BoxShadow> get shadowCta => [
        BoxShadow(
          color: const Color(0xFF14C8D8).withValues(alpha: 0.4),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}
