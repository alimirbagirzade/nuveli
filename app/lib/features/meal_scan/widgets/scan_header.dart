import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Üst başlık: ✕ close + "AI Meal Scan" + ⚡ flash
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBtn(icon: Icons.close, size: 24, onTap: onClose),
          const Expanded(
            child: Text(
              'AI Meal Scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _IconBtn(
            icon: flashOn ? Icons.flash_on : Icons.flash_off,
            size: 22,
            color: AppColors.textSecondary,
            onTap: onFlashToggle,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final VoidCallback? onTap;

  const _IconBtn({
    required this.icon,
    required this.size,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, size: size, color: color ?? AppColors.textPrimary),
      ),
    );
  }
}
