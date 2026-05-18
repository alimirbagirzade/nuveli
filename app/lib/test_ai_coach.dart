// Geçici test entry — Chat 11a UI'ı simulator'de görmek için.
// SİL veya git'e commit'leme (zaten test_*.dart .gitignore'da olabilir).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/ai_coach/ai_coach_screen.dart';

void main() {
  runApp(const ProviderScope(child: _TestApp()));
}

class _TestApp extends StatelessWidget {
  const _TestApp();
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AICoachScreen(),
    );
  }
}
