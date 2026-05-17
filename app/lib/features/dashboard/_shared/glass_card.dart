import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class NuveliCard extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;
  final double radius;

  const NuveliCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: DashboardColors.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: DashboardColors.cardBorder, width: 1),
      ),
      child: child,
    );
  }
}
