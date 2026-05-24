// ============================================================================
// step_3_body_metrics.dart
// Height + Weight slider'ları. Büyük rakam + cyan slider.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/auth_primary_button.dart';

class Step3BodyMetrics extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const Step3BodyMetrics({super.key, required this.onNext});

  @override
  ConsumerState<Step3BodyMetrics> createState() => _Step3State();
}

class _Step3State extends ConsumerState<Step3BodyMetrics> {
  late double _height;
  late double _weight;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingDataProvider);
    _height = data.heightCm ?? 170;
    _weight = data.currentWeightKg ?? 70;
  }

  void _continue() {
    ref.read(onboardingDataProvider.notifier).update(
          heightCm: _height,
          currentWeightKg: _weight,
        );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n?.onboardingStep3Title ?? 'Your body metrics',
            style: AppTypography.heading28.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingStep3Subtitle ?? "Don't worry, you can update these anytime.",
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _MetricSlider(
                  label: l10n?.onboardingHeight ?? 'Height',
                  value: _height,
                  unit: 'cm',
                  min: 140,
                  max: 220,
                  divisions: 80,
                  icon: Icons.height,
                  onChanged: (v) => setState(() => _height = v),
                ),
                const SizedBox(height: 32),
                _MetricSlider(
                  label: l10n?.onboardingCurrentWeight ?? 'Current weight',
                  value: _weight,
                  unit: 'kg',
                  min: 40,
                  max: 200,
                  divisions: 160,
                  icon: Icons.monitor_weight_outlined,
                  onChanged: (v) => setState(() => _weight = v),
                ),
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
}

// ============================================================================
// SLIDER WIDGET
// ============================================================================

class _MetricSlider extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min;
  final double max;
  final int divisions;
  final IconData icon;
  final ValueChanged<double> onChanged;

  const _MetricSlider({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.divisions,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.body14.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(0),
                style: AppTypography.heading48Bold.copyWith(
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: AppTypography.body18.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryCyan,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
              thumbColor: Colors.white,
              overlayColor: AppColors.primaryCyan.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()} $unit',
                style: AppTypography.caption12.copyWith(
                  color: AppColors.tertiaryText,
                ),
              ),
              Text(
                '${max.toInt()} $unit',
                style: AppTypography.caption12.copyWith(
                  color: AppColors.tertiaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
