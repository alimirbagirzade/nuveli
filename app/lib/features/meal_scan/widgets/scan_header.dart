import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Üst başlık: ✕ close (sol) + "AI Meal Scan" (orta) + ⚡ flash (sağ)
class ScanHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onFlashToggle;
  final bool flashOn;

  const ScanHeader({
    super.key,
    required this.onClose,
    this.onFlashToggle,
    this.flashOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 4,
      ),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.close,
            size: 24,
            onTap: onClose,
            tooltip: 'Close',
          ),
          Expanded(
            child: Text(
              'AI Meal Scan',
              textAlign: TextAlign.center,
              style: AppTypography.cardTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _IconButton(
            icon: flashOn ? Icons.flash_on : Icons.flash_off,
            size: 22,
            color: AppColors.secondaryText,
            onTap: onFlashToggle,
            tooltip: 'Toggle flash',
          ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final VoidCallback? onTap;
  final String? tooltip;

  const _IconButton({
    required this.icon,
    required this.size,
    this.color,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = InkResponse(
      onTap: onTap,
      radius: 24,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: size, color: color ?? Colors.white),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: btn);
    return btn;
  }
}
