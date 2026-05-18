import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Hatırlatma toggle satırı.
///
/// Görsel 5: "Morning reminder | 9:00 AM" + switch (icon yok)
/// Görsel 7: 🔔 + "Hydration Reminder | 1:00 PM • Every day" + switch
///
/// Tek kart içinde birden fazlası stack edilebilir
/// (Card → Column → ReminderToggleTile x N, divider olmadan).
class ReminderToggleTile extends StatefulWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const ReminderToggleTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.initialValue = true,
    this.onChanged,
  });

  @override
  State<ReminderToggleTile> createState() => _ReminderToggleTileState();
}

class _ReminderToggleTileState extends State<ReminderToggleTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _handleChanged(bool newValue) {
    setState(() => _value = newValue);
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          if (widget.icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CupertinoSwitch(
            value: _value,
            onChanged: _handleChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
