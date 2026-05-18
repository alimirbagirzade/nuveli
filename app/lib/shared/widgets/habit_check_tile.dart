import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Habit satırı (checkable, 200ms animasyonlu).
///
/// Görsel 7:
/// - 🥗 Log breakfast | Track your first meal | ✓ (cyan dolu)
/// - 🌙 Sleep before 11 PM | Get quality rest | ○ (boş outline)
class HabitCheckTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool initialChecked;
  final ValueChanged<bool>? onChanged;

  const HabitCheckTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.initialChecked = false,
    this.onChanged,
  });

  @override
  State<HabitCheckTile> createState() => _HabitCheckTileState();
}

class _HabitCheckTileState extends State<HabitCheckTile> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.initialChecked;
  }

  void _toggle() {
    setState(() => _checked = !_checked);
    widget.onChanged?.call(_checked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        child: Row(
          children: [
            // Habit icon (circle with tinted background)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      decoration: _checked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor:
                          AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _CheckCircle(checked: _checked),
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool checked;

  const _CheckCircle({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: checked ? AppColors.primaryCyan : Colors.transparent,
        border: Border.all(
          color: checked
              ? AppColors.primaryCyan
              : AppColors.textSecondary.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: checked
            ? [
                BoxShadow(
                  color: AppColors.primaryCyan.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: checked
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey(true),
                color: Colors.white,
                size: 18,
              )
            : const SizedBox.shrink(key: ValueKey(false)),
      ),
    );
  }
}
