// ============================================================================
// step_4_goals.dart
// Activity level + Goal type + Target weight (lose/gain seçildiyse).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/weight_pace.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../models/onboarding_data.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/auth_primary_button.dart';

class Step4Goals extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const Step4Goals({super.key, required this.onNext});

  @override
  ConsumerState<Step4Goals> createState() => _Step4State();
}

class _Step4State extends ConsumerState<Step4Goals> {
  double? _targetWeight;
  DateTime? _targetDate;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingDataProvider);
    _targetWeight = data.targetWeightKg ?? data.currentWeightKg;
    _targetDate = data.targetDate;
  }

  void _continue() {
    final data = ref.read(onboardingDataProvider);
    final l10n = AppLocalizations.of(context);
    if (data.activityLevel == null) {
      _showSnack(l10n?.onboardingSelectActivityError ?? 'Please select your activity level');
      return;
    }
    if (data.goalType == null) {
      _showSnack(l10n?.onboardingSelectGoalError ?? 'Please select a goal');
      return;
    }
    final needsTarget = data.goalType == GoalType.loseWeight ||
        data.goalType == GoalType.gainWeight;
    if (needsTarget && _targetWeight != null) {
      ref.read(onboardingDataProvider.notifier).update(
            targetWeightKg: _targetWeight,
            targetDate: _targetDate,
          );
    }
    widget.onNext();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.danger,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(onboardingDataProvider);
    final l10n = AppLocalizations.of(context);
    final showTarget = data.goalType == GoalType.loseWeight ||
        data.goalType == GoalType.gainWeight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n?.onboardingStep4Title ?? 'Your goals',
            style: AppTypography.heading28.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingStep4Subtitle ?? "We'll tailor your daily targets accordingly.",
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                Text(
                  l10n?.onboardingActivityLevelLabel ?? 'Activity level',
                  style: AppTypography.body14.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...ActivityLevel.values.map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ChoiceCard(
                      title: level.label,
                      subtitle: level.description,
                      selected: data.activityLevel == level,
                      onTap: () => ref
                          .read(onboardingDataProvider.notifier)
                          .update(activityLevel: level),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n?.onboardingYourGoalLabel ?? 'Your goal',
                  style: AppTypography.body14.copyWith(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GoalType.values.map((goal) {
                    final selected = data.goalType == goal;
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
                      child: _GoalCard(
                        label: goal.label,
                        icon: _iconFor(goal),
                        selected: selected,
                        onTap: () => ref
                            .read(onboardingDataProvider.notifier)
                            .update(goalType: goal),
                      ),
                    );
                  }).toList(),
                ),
                if (showTarget) ...[
                  const SizedBox(height: 24),
                  _TargetWeightSlider(
                    current: data.currentWeightKg ?? 70,
                    value: _targetWeight ?? data.currentWeightKg ?? 70,
                    onChanged: (v) => setState(() => _targetWeight = v),
                    targetWeightLabel: l10n?.onboardingTargetWeight ?? 'Target weight',
                    toLoseLabel: l10n?.onboardingToLose ?? 'to lose',
                    toGainLabel: l10n?.onboardingToGain ?? 'to gain',
                  ),
                  const SizedBox(height: 12),
                  _GoalTimeline(
                    startKg: data.currentWeightKg ?? 70,
                    targetKg: _targetWeight ?? data.currentWeightKg ?? 70,
                    direction:
                        data.goalType == GoalType.loseWeight ? 'lose' : 'gain',
                    date: _targetDate,
                    onDate: (d) => setState(() => _targetDate = d),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(label: l10n?.onboardingContinue ?? 'Continue', onPressed: _continue),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _iconFor(GoalType g) => switch (g) {
        GoalType.loseWeight => Icons.trending_down,
        GoalType.maintain => Icons.balance,
        GoalType.gainWeight => Icons.trending_up,
        GoalType.buildMuscle => Icons.fitness_center,
      };
}

// ============================================================================
// CHOICE CARD — list-style row
// ============================================================================

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryCyan.withValues(alpha: 0.25),
                    AppColors.primaryCyan.withValues(alpha: 0.08),
                  ],
                )
              : null,
          color: selected ? null : const Color(0xFF142346).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryCyan.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body16.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption12.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: AppColors.primaryCyan, size: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GOAL CARD — 2 column grid card
// ============================================================================

class _GoalCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.primaryCyan.withValues(alpha: 0.3),
                    AppColors.primaryCyan.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: selected ? null : const Color(0xFF142346).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primaryCyan.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? AppColors.primaryCyan : Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.body14.copyWith(
                color: Colors.white,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// GOAL TIMELINE — target date picker + gentle safe-pace guidance
// ============================================================================

class _GoalTimeline extends StatelessWidget {
  const _GoalTimeline({
    required this.startKg,
    required this.targetKg,
    required this.direction,
    required this.date,
    required this.onDate,
  });

  final double startKg;
  final double targetKg;
  final String direction; // 'lose' | 'gain'
  final DateTime? date;
  final ValueChanged<DateTime> onDate;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? now.add(const Duration(days: 56)),
      firstDate: now.add(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked != null) onDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final pace = WeightPace.evaluate(
      startKg: startKg,
      targetKg: targetKg,
      direction: direction,
      targetDate: date,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.onboardingTargetDateLabel ?? 'Target date',
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1A3D).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.primaryCyan),
                  const SizedBox(width: 10),
                  Text(
                    date != null
                        ? DateFormat.yMMMMd(locale).format(date!)
                        : (l10n?.onboardingTargetDatePick ?? 'Pick a date'),
                    style: AppTypography.body16.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (pace != null && pace.verdict != PaceVerdict.none) ...[
            const SizedBox(height: 12),
            _PaceNote(
              pace: pace,
              onUseSuggested: () => onDate(pace.suggestedDate()),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaceNote extends StatelessWidget {
  const _PaceNote({required this.pace, required this.onUseSuggested});
  final WeightPace pace;
  final VoidCallback onUseSuggested;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final aggressive = pace.verdict == PaceVerdict.aggressive;
    final color = aggressive ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                aggressive
                    ? Icons.info_outline
                    : Icons.check_circle_outline,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  aggressive
                      ? (l10n?.onboardingPaceAggressive(pace.suggestedWeeks) ??
                          "That's a fast pace. We'd suggest about "
                              "${pace.suggestedWeeks} weeks.")
                      : (l10n?.onboardingPaceHealthy ??
                          'A healthy, sustainable pace'),
                  style: AppTypography.caption12
                      .copyWith(color: Colors.white, height: 1.4),
                ),
              ),
            ],
          ),
          if (aggressive) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onUseSuggested,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n?.onboardingPaceUseSuggested ?? 'Use suggested date',
                  style: AppTypography.caption12.copyWith(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// TARGET WEIGHT SLIDER
// ============================================================================

class _TargetWeightSlider extends StatelessWidget {
  final double current;
  final double value;
  final ValueChanged<double> onChanged;
  final String targetWeightLabel;
  final String toLoseLabel;
  final String toGainLabel;

  const _TargetWeightSlider({
    required this.current,
    required this.value,
    required this.onChanged,
    this.targetWeightLabel = 'Target weight',
    this.toLoseLabel = 'to lose',
    this.toGainLabel = 'to gain',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            targetWeightLabel,
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(0),
                style: AppTypography.heading32Bold.copyWith(
                  color: AppColors.primaryCyan,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'kg',
                style: AppTypography.body14.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const Spacer(),
              Text(
                '${(value - current).abs().toStringAsFixed(1)} kg '
                '${value < current ? toLoseLabel : toGainLabel}',
                style: AppTypography.caption12.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryCyan,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
              thumbColor: Colors.white,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              min: 40,
              max: 200,
              divisions: 160,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
