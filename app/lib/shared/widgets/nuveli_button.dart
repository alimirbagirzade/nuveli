import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Primary cyan-gradient CTA button.
///
/// Supports two equivalent calling styles:
///
/// 1. Custom child (full control over content):
/// ```dart
/// NuveliButton(
///   onPressed: () {},
///   child: Row(children: [Icon(...), Text(...)]),
/// )
/// ```
///
/// 2. Label + optional icon (shorthand for the common case):
/// ```dart
/// NuveliButton(
///   onPressed: () {},
///   label: 'Continue',
///   icon: Icons.arrow_forward,
///   fullWidth: true,
/// )
/// ```
///
/// Exactly one of [child] or [label] must be provided.
class NuveliButton extends StatelessWidget {
  const NuveliButton({
    super.key,
    required this.onPressed,
    this.child,
    this.label,
    this.icon,
    this.fullWidth = false,
    this.height = 52,
    this.padding,
  })  : assert(
          (child != null) ^ (label != null),
          'NuveliButton requires either child OR label, not both.',
        ),
        assert(
          icon == null || label != null,
          'icon can only be used together with label, not child.',
        );

  /// Tap handler. Pass null to render the button in a disabled state.
  final VoidCallback? onPressed;

  /// Custom content widget. Use when you need full control over the layout.
  /// Mutually exclusive with [label].
  final Widget? child;

  /// Shorthand label text. Mutually exclusive with [child].
  /// When provided, the button renders [icon] + [label] horizontally centered.
  final String? label;

  /// Optional leading icon. Only valid when [label] is used.
  final IconData? icon;

  /// Stretches the button to the full available width.
  final bool fullWidth;

  /// Vertical button height. Defaults to 52 (Apple HIG touch-target).
  final double height;

  /// Horizontal padding override. Defaults to 24px.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final radius = BorderRadius.circular(AppRadius.pill);
    final resolvedPadding =
        padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg);

    final content = child ?? _buildLabelContent();

    Widget button = Container(
      height: height,
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryCyan, AppColors.cyanGlow],
              ),
        color: isDisabled ? AppColors.cyanDark.withValues(alpha: 0.4) : null,
        borderRadius: radius,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: resolvedPadding,
            child: Center(child: content),
          ),
        ),
      ),
    );

    if (fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildLabelContent() {
    final text = Text(
      label!,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );

    if (icon == null) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.white),
        const SizedBox(width: AppSpacing.sm),
        text,
      ],
    );
  }
}
