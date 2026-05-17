import 'package:flutter/material.dart';
import 'dashboard_theme.dart';

class NuveliButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const NuveliButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [
                DashboardColors.cyanGlow,
                DashboardColors.cyan,
                DashboardColors.cyanDark,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: DashboardColors.cyan.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
