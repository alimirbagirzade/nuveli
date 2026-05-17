import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class NuveliBackground extends StatelessWidget {
  final Widget child;
  const NuveliBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [DashboardColors.bgTop, DashboardColors.bgBottom],
        ),
      ),
      child: child,
    );
  }
}
