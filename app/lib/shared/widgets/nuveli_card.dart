import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Liquid-glass card with translucent fill, soft blur, and a thin white border.
///
/// Use as the standard container for grouped content on Nuveli screens.
/// Optionally tappable via [onTap], which wraps the content in an InkWell
/// with a matching cyan-tinted ripple.
///
/// Example:
/// ```dart
/// NuveliCard(
///   padding: const EdgeInsets.all(20),
///   onTap: () => debugPrint('tapped'),
///   child: Text('Hello'),
/// )
/// ```
class NuveliCard extends StatelessWidget {
  const NuveliCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.blurSigma = 12,
  });

  /// Card content.
  final Widget child;

  /// Optional tap handler. When provided, the card becomes a tappable surface
  /// with an InkWell ripple matching the cyan brand color.
  final VoidCallback? onTap;

  /// Inner padding. Defaults to 16px on all sides.
  final EdgeInsetsGeometry padding;

  /// Corner radius. Defaults to [AppRadius.card] (20px).
  final BorderRadius? borderRadius;

  /// Background fill color. Defaults to translucent [AppColors.cardBackground].
  /// Pass a fully opaque color if you don't want the glass effect.
  final Color? backgroundColor;

  /// Border color. Defaults to [AppColors.borderGlass] (rgba 255,255,255,0.1).
  final Color? borderColor;

  /// Gaussian blur amount applied behind the card. Set to 0 to disable.
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.card);
    final bg = backgroundColor ?? AppColors.cardBackground.withValues(alpha: 0.6);
    final border = borderColor ?? AppColors.borderGlass;

    // Glass: blur whatever is behind the card, then layer the translucent fill.
    Widget content = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: border, width: 1),
      ),
      child: Padding(padding: padding, child: child),
    );

    // Wrap in InkWell only if interactive.
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppColors.primaryCyan.withValues(alpha: 0.12),
          highlightColor: AppColors.primaryCyan.withValues(alpha: 0.05),
          child: content,
        ),
      );
    }

    // ClipRRect ensures BackdropFilter only blurs inside the card bounds.
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: content,
      ),
    );
  }
}
