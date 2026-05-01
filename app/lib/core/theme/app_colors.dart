import 'package:flutter/material.dart';

/// Nuveli renk paleti — dark premium tema.
/// Tüm renk kullanımları bu sınıftan alınır; hard-coded hex yasak.
class AppColors {
  AppColors._();

  // Background
  static const background = Color(0xFF0D0D0F);
  static const surface = Color(0xFF1A1A1E);
  static const surfaceElevated = Color(0xFF242428);
  static const surfaceHighlight = Color(0xFF2E2E34);

  // Brand
  static const primary = Color(0xFF7C5CFC);
  static const primaryLight = Color(0xFF9B7EFD);
  static const primaryDark = Color(0xFF5B3FD4);

  // Accent
  static const accent = Color(0xFF00E5A0);
  static const accentLight = Color(0xFF4DFFC0);

  // Text
  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFFAAAAAF);
  static const textTertiary = Color(0xFF6B6B72);
  static const textDisabled = Color(0xFF3D3D42);

  // Semantic
  static const success = Color(0xFF00C97A);
  static const warning = Color(0xFFFFB020);
  static const error = Color(0xFFFF4D6A);
  static const info = Color(0xFF3B9EFF);

  // Divider
  static const divider = Color(0xFF2A2A30);

  // Overlay
  static const overlay = Color(0x99000000);
  static const shimmerBase = Color(0xFF1E1E22);
  static const shimmerHighlight = Color(0xFF2A2A30);
}
