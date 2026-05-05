import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../data/profile_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Goals screen — user adjusts daily calorie target and goal type.
///
/// We don't expose macro split sliders yet because the AI coach handles
/// that automatically based on goal + activity. The form keeps two
/// controls:
///   1. Goal: lose_weight | maintain | gain_muscle (radio cards)
///   2. Daily calorie target: slider 1200..3500 in steps of 50
///
/// Save sends both via PATCH /profile.
class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  String? _goal;
  double _calorieTarget = 2000;
  bool _saving = false;
  bool _initialized = false;

  void _hydrate(UserProfile p) {
    if (_initialized) return;
    _initialized = true;
    _goal = p.goal ?? 'maintain';
    _calorieTarget = (p.targetCalories ?? 2000).toDouble().clamp(1200, 3500);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileRepositoryProvider).updateProfile(
            goal: _goal,
            dailyCalorieTarget: _calorieTarget.round(),
          );
      ref.invalidate(userProfileProvider);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.goalsUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AppError ? e.userMessage : AppLocalizations.of(context)!.goalsSaveFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return AppScaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.goalsTitle)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e is AppError ? e.userMessage : AppLocalizations.of(context)!.goalsLoadFailed),
        ),
        data: (p) {
          _hydrate(p);
          // Approximate macros for the calorie target — pure UI hint, not saved.
          // 25% protein, 50% carb, 25% fat is a reasonable balanced split.
          final cal = _calorieTarget.round();
          final protein = ((cal * 0.25) / 4).round();
          final carb = ((cal * 0.50) / 4).round();
          final fat = ((cal * 0.25) / 9).round();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Section(AppLocalizations.of(context)!.goalsSecPurpose),
              _GoalCard(
                title: AppLocalizations.of(context)!.goalsLoseWeight,
                subtitle: AppLocalizations.of(context)!.goalsLoseWeightDesc,
                icon: Icons.trending_down,
                value: 'lose_weight',
                groupValue: _goal,
                onChanged: (v) => setState(() => _goal = v),
              ),
              _GoalCard(
                title: AppLocalizations.of(context)!.goalsMaintain,
                subtitle: AppLocalizations.of(context)!.goalsMaintainDesc,
                icon: Icons.balance,
                value: 'maintain',
                groupValue: _goal,
                onChanged: (v) => setState(() => _goal = v),
              ),
              _GoalCard(
                title: AppLocalizations.of(context)!.goalsGainMuscle,
                subtitle: AppLocalizations.of(context)!.goalsGainMuscleDesc,
                icon: Icons.trending_up,
                value: 'gain_muscle',
                groupValue: _goal,
                onChanged: (v) => setState(() => _goal = v),
              ),

              const SizedBox(height: 24),
              _Section(AppLocalizations.of(context)!.goalsSecDailyCalorie),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$cal',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          ' kcal',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      min: 1200,
                      max: 3500,
                      divisions: (3500 - 1200) ~/ 50,
                      value: _calorieTarget,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _calorieTarget = v),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1200',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary)),
                        Text('3500',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _Section(AppLocalizations.of(context)!.goalsSecMacroDist),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    _MacroChip(label: AppLocalizations.of(context)!.macroProtein, value: '${protein}g', color: AppColors.success),
                    const SizedBox(width: 8),
                    _MacroChip(label: AppLocalizations.of(context)!.macroCarb, value: '${carb}g', color: AppColors.primary),
                    const SizedBox(width: 8),
                    _MacroChip(label: AppLocalizations.of(context)!.macroFat, value: '${fat}g', color: AppColors.warning),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  AppLocalizations.of(context)!.goalsMacroNote,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Kaydet'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
              Text(value,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
}
