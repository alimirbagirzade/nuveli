import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_radius.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/l10n/generated/app_localizations.dart';

import '../models/weight_goal.dart';
import '../providers/profile_actions.dart';

/// Bottom sheet: create a new weight goal (or replace the active one).
class SetWeightGoalSheet extends ConsumerStatefulWidget {
  /// Current body weight from `/me` — used as starting_weight default.
  final double? currentWeightKg;

  const SetWeightGoalSheet({super.key, this.currentWeightKg});

  @override
  ConsumerState<SetWeightGoalSheet> createState() => _SetWeightGoalSheetState();
}

class _SetWeightGoalSheetState extends ConsumerState<SetWeightGoalSheet> {
  WeightGoalDirection _direction = WeightGoalDirection.lose;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _startCtrl;
  DateTime? _targetDate;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final start = widget.currentWeightKg;
    _startCtrl = TextEditingController(
      text: start?.toStringAsFixed(1) ?? '',
    );
    // Sensible default target based on direction.
    _targetCtrl = TextEditingController(
      text: start == null ? '' : (start - 5).toStringAsFixed(0),
    );
    // Default 12 weeks out.
    _targetDate = DateTime.now().add(const Duration(days: 84));
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _startCtrl.dispose();
    super.dispose();
  }

  void _onDirectionChange(WeightGoalDirection d) {
    setState(() {
      _direction = d;
      final start = double.tryParse(_startCtrl.text.replaceAll(',', '.'));
      if (start != null) {
        // Re-suggest target.
        if (d == WeightGoalDirection.lose) {
          _targetCtrl.text = (start - 5).toStringAsFixed(0);
        } else if (d == WeightGoalDirection.gain) {
          _targetCtrl.text = (start + 5).toStringAsFixed(0);
        } else {
          _targetCtrl.text = start.toStringAsFixed(0);
        }
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 84)),
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryCyan,
            surface: Color(0xFF0B1A3D),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final target = double.tryParse(_targetCtrl.text.replaceAll(',', '.'));
    final start = double.tryParse(_startCtrl.text.replaceAll(',', '.'));

    if (target == null || target < 20 || target > 400) {
      setState(() => _error = l10n?.profileGoalErrorTarget ??
          'Enter a target weight between 20 and 400 kg');
      return;
    }
    if (start == null || start < 20 || start > 400) {
      setState(() => _error = l10n?.profileGoalErrorStart ??
          'Enter a starting weight between 20 and 400 kg');
      return;
    }
    if (_direction == WeightGoalDirection.lose && target >= start) {
      setState(() => _error = l10n?.profileGoalErrorLoseLower ??
          'Target should be lower than starting weight');
      return;
    }
    if (_direction == WeightGoalDirection.gain && target <= start) {
      setState(() => _error = l10n?.profileGoalErrorGainHigher ??
          'Target should be higher than starting weight');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(profileActionsProvider).setWeightGoal(
            targetKg: target,
            targetDate: _targetDate,
            direction: _direction.toJson(),
            startingWeightKg: start,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = l10n?.profileGoalSaveError ??
              'Could not save. Check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B1A3D),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.cardLarge),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Text(
                  l10n?.profileSetWeightGoalTitle ?? 'Set your weight goal',
                  style: AppTypography.sectionTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  l10n?.profileSetWeightGoalSubtitle ??
                      'We\'ll track your progress and adjust suggestions.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),

                // Direction selector
                Text(
                  l10n?.profileGoalType ?? 'GOAL TYPE',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                _DirectionSelector(
                  current: _direction,
                  onChanged: _onDirectionChange,
                  l10n: l10n,
                ),
                const SizedBox(height: AppSpacing.s16),

                // Starting weight
                _NumberField(
                  label: l10n?.profileStartingWeight ?? 'Starting weight',
                  controller: _startCtrl,
                  suffix: 'kg',
                ),
                const SizedBox(height: AppSpacing.s12),

                // Target weight
                _NumberField(
                  label: _direction == WeightGoalDirection.maintain
                      ? (l10n?.profileMaintainWeightAt ?? 'Maintain weight at')
                      : (l10n?.profileTargetWeight ?? 'Target weight'),
                  controller: _targetCtrl,
                  suffix: 'kg',
                ),
                const SizedBox(height: AppSpacing.s12),

                // Target date
                _DateField(
                  label: l10n?.profileTargetDate ?? 'Target date',
                  value: _targetDate,
                  onTap: _pickDate,
                  l10n: l10n,
                ),

                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    _error!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.s24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppColors.primaryCyan.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n?.profileSaveGoal ?? 'Save goal',
                            style: AppTypography.cardTitle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                Center(
                  child: TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      l10n?.commonCancel ?? 'Cancel',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DirectionSelector extends StatelessWidget {
  final WeightGoalDirection current;
  final ValueChanged<WeightGoalDirection> onChanged;
  final AppLocalizations? l10n;

  const _DirectionSelector({
    required this.current,
    required this.onChanged,
    this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _Tab(
            label: l10n?.profileGoalLose ?? 'Lose',
            icon: Icons.trending_down_rounded,
            selected: current == WeightGoalDirection.lose,
            onTap: () => onChanged(WeightGoalDirection.lose),
          ),
          _Tab(
            label: l10n?.profileGoalMaintain ?? 'Maintain',
            icon: Icons.trending_flat_rounded,
            selected: current == WeightGoalDirection.maintain,
            onTap: () => onChanged(WeightGoalDirection.maintain),
          ),
          _Tab(
            label: l10n?.profileGoalGain ?? 'Gain',
            icon: Icons.trending_up_rounded,
            selected: current == WeightGoalDirection.gain,
            onTap: () => onChanged(WeightGoalDirection.gain),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.button - 4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s4),
              Text(
                label,
                style: AppTypography.body.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String suffix;

  const _NumberField({
    required this.label,
    required this.controller,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: AppColors.cardBackground,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  style: AppTypography.cardTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                suffix,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final AppLocalizations? l10n;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.l10n,
  });

  String _format(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          color: AppColors.cardBackground,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? (l10n?.profileChooseDate ?? 'Choose a date')
                        : _format(value!),
                    style: AppTypography.cardTitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Top-level helper for callers.
Future<bool?> showSetWeightGoalSheet(
  BuildContext context, {
  double? currentWeightKg,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SetWeightGoalSheet(currentWeightKg: currentWeightKg),
  );
}
