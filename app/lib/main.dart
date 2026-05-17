import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuveli/features/meal_scan/meal_scan_screen.dart';

void main() {
  runApp(const ProviderScope(child: NuveliApp()));
}

class NuveliApp extends StatelessWidget {
  const NuveliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nuveli',
      home: const MealScanScreen(),
    );
  }
}
