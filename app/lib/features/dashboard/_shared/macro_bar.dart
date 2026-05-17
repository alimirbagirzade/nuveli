import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final Color color;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: DashboardColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${current.toInt()}g',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: DashboardColors.textPrimary,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '/ ${target.toInt()}g',
          style: const TextStyle(
            fontSize: 11,
            color: DashboardColors.textTertiary,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
