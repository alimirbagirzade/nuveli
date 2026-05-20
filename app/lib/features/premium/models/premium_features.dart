// lib/features/premium/models/premium_features.dart
//
// Paywall ekranında listelenen feature'lar.
// Lokalize edilebilir (TR/EN) — şimdilik EN.
// İkon adları lucide-react / Material set'ten — UI'da IconData'ya çevriliyor.

import 'package:flutter/material.dart';

@immutable
class PremiumFeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const PremiumFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class PremiumFeatures {
  PremiumFeatures._();

  /// Paywall'da gösterilen ana feature listesi.
  /// Sıralama önemli — en değerli olanlar üstte.
  static const List<PremiumFeatureItem> all = [
    PremiumFeatureItem(
      icon: Icons.auto_awesome_rounded,
      title: 'Unlimited AI Coach insights',
      description: 'Personalized daily tips that adapt to your goals',
    ),
    PremiumFeatureItem(
      icon: Icons.camera_alt_rounded,
      title: 'Unlimited meal scans',
      description: 'AI-powered nutrition analysis from a single photo',
    ),
    PremiumFeatureItem(
      icon: Icons.timeline_rounded,
      title: 'Full analytics history',
      description: 'See every trend, all the way back to day one',
    ),
    PremiumFeatureItem(
      icon: Icons.restaurant_menu_rounded,
      title: 'AI meal planner',
      description: 'Generate weekly plans tailored to your calorie target',
    ),
    PremiumFeatureItem(
      icon: Icons.check_circle_outline_rounded,
      title: 'Unlimited custom habits',
      description: 'Track every habit that matters to you',
    ),
    PremiumFeatureItem(
      icon: Icons.favorite_rounded,
      title: 'Apple Health & Google Fit sync',
      description: 'Steps, heart rate, sleep — all in one place',
    ),
    PremiumFeatureItem(
      icon: Icons.file_download_outlined,
      title: 'Export your data',
      description: 'CSV and PDF reports — yours to keep, always',
    ),
    PremiumFeatureItem(
      icon: Icons.palette_outlined,
      title: 'Premium themes',
      description: 'Reef, Aurora, and Midnight — beyond the default ocean',
    ),
  ];

  /// Free user'a upsell dialog'unda gösterilen kısa liste (3-4 item).
  static const List<PremiumFeatureItem> shortlist = [
    PremiumFeatureItem(
      icon: Icons.auto_awesome_rounded,
      title: 'Unlimited AI insights',
      description: '',
    ),
    PremiumFeatureItem(
      icon: Icons.timeline_rounded,
      title: 'Full analytics history',
      description: '',
    ),
    PremiumFeatureItem(
      icon: Icons.restaurant_menu_rounded,
      title: 'AI meal plans',
      description: '',
    ),
  ];

  /// Feature-specific paywall'lar için kontekstüel mesaj.
  /// UpsellDialog'da source'a göre üst başlık değişir.
  static String headlineForSource(String? source) {
    return switch (source) {
      'ai_coach' => 'Unlock unlimited AI insights',
      'analytics' => 'See your full progress story',
      'meal_planner' => 'Let AI plan your week',
      'meal_scan' => 'Scan every meal you eat',
      'habits' => 'Track every habit that matters',
      'export' => 'Take your data anywhere',
      'health_sync' => 'Connect your full health picture',
      'themes' => 'Make Nuveli truly yours',
      _ => 'Unlock the full Nuveli experience',
    };
  }
}
