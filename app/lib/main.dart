import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuveli/features/dashboard/dashboard_screen.dart';

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
      home: const DashboardScreen(),
    );
  }
}
