// ============================================================================
// step_5_targets.dart
// BMR/TDEE'den hesaplanan günlük kalori + makro + su hedefleri.
// "Complete Setup" → backend'e POST.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/calorie_calculator.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/auth_link_text.dart';
import '../../../widgets/auth_primary_button.dart';

class Step5Targets extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final bool submitting;
  final String? submitError;

  const Step5Targets({
    super.key,
    required this.onComplete,
    required this.submitting,
    this.submitError,
  });

  @override
  ConsumerState<Step5Targets> createState() => _Step5State();
}

class _Step5State extends ConsumerState<Step5Targets> {
  CalorieCalculation? _calc;

  @override
  void initState() {
    super.initState();
    // Hesapla ve provider'a yaz
    WidgetsBinding.instance.addPostFrameCallback((_) => _compute());
  }

  @override
  void didUpdateWidget(covariant Step5Targets oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_calc == null) _compute();
  }

  void _compute() {
    final data = ref.read(onboardingDataProvider);
    final calc = CalorieCalculator.fromOnboarding(data);
    if (calc == null) return;

    setState(() => _calc = calc);

    // State'e yaz ki backend'e gönderebilelim
    ref.read(onboardingDataProvider.notifier).update(
          dailyCalorieTarget: calc.dailyCalorieTarget,
          dailyWaterMl: calc.dailyWaterMl,
          proteinPercent: calc.proteinPercent,
          carbsPercent: calc.carbsPercent,
          fatPercent: calc.fatPercent,
        );
  }

  @override
  Widget build(BuildContext context) {
    final calc = _calc;

    if (calc == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n?.onboardingStep5Title ?? 'Your daily targets',
            style: AppTypography.heading28.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingStep5Subtitle ?? 'Personalized to your body, lifestyle, and goal.',
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _CalorieHero(
                  calories: calc.dailyCalorieTarget,
                  label: l10n?.onboardingDailyCalories ?? 'DAILY CALORIES',
                ),
                const SizedBox(height: 16),
                _MacroSummary(
                  calc: calc,
                  macrosLabel: l10n?.onboardingMacros ?? 'Macros',
                  proteinLabel: l10n?.onboardingProtein ?? 'Protein',
                  carbsLabel: l10n?.onboardingCarbs ?? 'Carbs',
                  fatLabel: l10n?.onboardingFat ?? 'Fat',
                ),
                const SizedBox(height: 16),
                _WaterTarget(
                  ml: calc.dailyWaterMl,
                  label: l10n?.onboardingDailyWater ?? 'Daily water',
                ),
                const SizedBox(height: 16),
                _MetaRow(
                  bmr: calc.bmr.round(),
                  tdee: calc.tdee.round(),
                ),
                const SizedBox(height: 16),
                if (widget.submitError != null)
                  AuthErrorBanner(message: widget.submitError!),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: l10n?.onboardingCompleteSetup ?? 'Complete Setup',
            isLoading: widget.submitting,
            onPressed: widget.onComplete,
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.onboardingAdjustAnytime ?? "You can adjust these anytime in Settings.",
            textAlign: TextAlign.center,
            style: AppTypography.caption12.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ============================================================================
// CALORIE HERO
// ============================================================================

class _CalorieHero extends StatelessWidget {
  final int calories;
  final String label;
  const _CalorieHero({required this.calories, this.label = 'DAILY CALORIES'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryCyan.withValues(alpha: 0.25),
            AppColors.primaryCyan.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryCyan.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.2),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption12.copyWith(
              color: AppColors.primaryCyan,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatNumber(calories),
                style: AppTypography.heading48Bold.copyWith(
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'kcal',
                style: AppTypography.body18.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ============================================================================
// MACRO SUMMARY
// ============================================================================

class _MacroSummary extends StatelessWidget {
  final CalorieCalculation calc;
  final String macrosLabel;
  final String proteinLabel;
  final String carbsLabel;
  final String fatLabel;
  const _MacroSummary({
    required this.calc,
    this.macrosLabel = 'Macros',
    this.proteinLabel = 'Protein',
    this.carbsLabel = 'Carbs',
    this.fatLabel = 'Fat',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            macrosLabel,
            style: AppTypography.body14.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MacroPill(
                  label: proteinLabel,
                  grams: calc.proteinGrams,
                  percent: calc.proteinPercent,
                  color: const Color(0xFF3DDC97),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroPill(
                  label: carbsLabel,
                  grams: calc.carbsGrams,
                  percent: calc.carbsPercent,
                  color: const Color(0xFF6BCB77),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroPill(
                  label: fatLabel,
                  grams: calc.fatGrams,
                  percent: calc.fatPercent,
                  color: const Color(0xFFFF9F45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final int grams;
  final int percent;
  final Color color;

  const _MacroPill({
    required this.label,
    required this.grams,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${grams}g',
            style: AppTypography.body18.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption12.copyWith(color: color),
          ),
          Text(
            '$percent%',
            style: AppTypography.caption12.copyWith(
              color: AppColors.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WATER TARGET
// ============================================================================

class _WaterTarget extends StatelessWidget {
  final int ml;
  final String label;
  const _WaterTarget({required this.ml, this.label = 'Daily water'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: AppColors.primaryCyan,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body14.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(ml / 1000).toStringAsFixed(1)} L  ·  $ml ml',
                  style: AppTypography.body18.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// META ROW — BMR & TDEE info
// ============================================================================

class _MetaRow extends StatelessWidget {
  final int bmr;
  final int tdee;
  const _MetaRow({required this.bmr, required this.tdee});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetaPill(label: 'BMR', value: '$bmr kcal')),
        const SizedBox(width: 12),
        Expanded(child: _MetaPill(label: 'TDEE', value: '$tdee kcal')),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final String value;
  const _MetaPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption12.copyWith(
              color: AppColors.tertiaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTypography.caption12.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
