import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Underwater gradient background with soft cyan glows.
class NuveliBackground extends StatelessWidget {
  const NuveliBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgPrimaryStart,
            AppColors.bgPrimaryEnd,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.25,
            child: _Glow(
              diameter: size.width * 0.95,
              color: AppColors.primaryCyan,
              opacity: 0.18,
            ),
          ),
          Positioned(
            bottom: -size.width * 0.30,
            left: -size.width * 0.20,
            child: _Glow(
              diameter: size.width * 0.85,
              color: AppColors.cyanGlow,
              opacity: 0.12,
            ),
          ),
          Positioned(
            top: size.height * 0.42,
            left: -size.width * 0.30,
            child: _Glow(
              diameter: size.width * 0.55,
              color: AppColors.primaryCyan,
              opacity: 0.08,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.diameter,
    required this.color,
    required this.opacity,
  });

  final double diameter;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
