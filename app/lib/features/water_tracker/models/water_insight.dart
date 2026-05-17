import 'package:flutter/material.dart';

/// AI tarafından üretilen su tüketim içgörüsü.
///
/// Mock'ta sabit; Chat 11'de gerçek AI Coach insight'ları gelecek.
class WaterInsight {
  final String mainText;
  final String? subText;
  final IconData icon;

  const WaterInsight({
    required this.mainText,
    this.subText,
    this.icon = Icons.water_drop,
  });
}
