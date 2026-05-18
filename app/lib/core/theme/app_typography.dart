import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Nuveli tipografi sistemi
///
/// Chat 4-11 kodundaki gerçek kullanım:
/// - AppTypography.cardTitle    (most common)
/// - AppTypography.body
/// - AppTypography.bodyMedium
/// - AppTypography.titleMedium
/// - AppTypography.titleSmall
/// - AppTypography.caption
///
/// Mevcut `AppTextStyles` sınıfı bozulmadı, bu yanına paralel olarak çalışır.
/// Yeni kodda bu sınıfı kullan; eski kodda AppTextStyles çalışmaya devam eder.
class AppTypography {
  AppTypography._();

  // Font ailesi: Default sistem font (SF Pro on iOS, Roboto on Android).
  // İleride Inter eklemek istersen: fontFamily: 'Inter' yap + pubspec'e ekle.

  // ─── HERO (büyük rakamlar — "1,480" gibi) ───
  static const TextStyle heroLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1.0,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static const TextStyle heroMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.0,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // ─── TITLE ───
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ─── CARD TITLE (kart başlıkları) ───
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ─── BODY ───
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ─── CAPTION ───
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ─── BUTTON ───
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  // ─── LABEL ───
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textPrimary,
  );
}
