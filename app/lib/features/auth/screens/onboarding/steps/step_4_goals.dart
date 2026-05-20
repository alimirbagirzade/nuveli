// ============================================================================
// step_4_goals.dart
// Activity level + Goal type + Target weight (lose/gain seçildiyse).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
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

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingDataProvider);
    _targetWeight = data.targetWeightKg ?? data.currentWeightKg;
  }

  void _continue() {
    final data = ref.read(onboardingDataProvider);
    if (data.activityLevel == null) {
      _showSnack('Please select your activity level');
      return;
    }
    if (data.goalType == null) {
      _showSnack('Please select a goal');
      return;
    }
    final needsTarget = data.goalType == GoalType.loseWeight ||
        data.goalType == GoalType.gainWeight;
    if (needsTarget && _targetWeight != null) {
      ref
          .read(onboardingDataProvider.notifier)
          .update(targetWeightKg: _targetWeight);
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
    final showTarget = data.goalType == GoalType.loseWeight ||
        data.goalType == GoalType.gainWeight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your goals',
            style: AppTypography.heading28.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "We'll tailor your daily targets accordingly.",
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                Text(
                  'Activity level',
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
                  'Your goal',
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
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(label: 'Continue', onPressed: _continue),
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
// TARGET WEIGHT SLIDER
// ============================================================================

class _TargetWeightSlider extends StatelessWidget {
  final double current;
  final double value;
  final ValueChanged<double> onChanged;

  const _TargetWeightSlider({
    required this.current,
    required this.value,
    required this.onChanged,
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
            'Target weight',
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
                '${value < current ? 'to lose' : 'to gain'}',
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
