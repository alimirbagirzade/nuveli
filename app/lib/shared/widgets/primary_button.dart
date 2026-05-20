import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_haptics.dart';

/// Nuveli standart primary button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width = double.infinity,
    this.height = 54,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double width;
  final double height;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final canPress = isEnabled && !isLoading && onPressed != null;

    return Semantics(
      label: label,
      button: true,
      enabled: canPress,
      excludeSemantics: true,
      hint: isLoading ? 'Loading' : null,
      child: SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: canPress
            ? () {
                AppHaptics.light();
                onPressed!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppTextStyles.buttonLarge),
                ],
              ),
      ),
      ),
    );
  }
}

/// İkincil (ghost) button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label, style: AppTextStyles.buttonLarge),
      ),
    );
  }
}
