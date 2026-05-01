import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/app_error.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../data/progress_repository.dart';

/// Weekly summary — 7-day report opened from the home chart header.
///
/// Sections:
///   1. Hero: total calories, avg/day, days logged out of 7
///   2. Macro distribution: protein/carb/fat as a stacked bar with legend
///   3. Per-day breakdown: tap any row to drill into day detail
///
/// All data comes from /summary/weekly/current via weeklySummaryProvider.
class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklySummaryProvider);

    return AppScaffold(
      appBar: AppBar(title: const Text('Haftalık Özet')),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(weeklySummaryProvider);
          await Future<void>.delayed(const Duration(milliseconds: 300));
        },
        child: weeklyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _Error(
            message: e is AppError ? e.userMessage : 'Yüklenemedi',
            onRetry: () => ref.invalidate(weeklySummaryProvider),
          ),
          data: (weekly) => _Body(weekly: weekly),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.weekly});
  final WeeklySummary weekly;

  @override
  Widget build(BuildContext context) {
    final loggedDays = weekly.sevenDays.where((d) => d.hasData).toList();
    final totalProtein = loggedDays.fold<double>(0, (s, d) => s + d.proteinG);
    final totalCarb = loggedDays.fold<double>(0, (s, d) => s + d.carbG);
    final totalFat = loggedDays.fold<double>(0, (s, d) => s + d.fatG);
    final hasMacros = totalProtein + totalCarb + totalFat > 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (weekly.headline.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              weekly.headline,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        _HeroCard(weekly: weekly),
        const SizedBox(height: 16),
        if (hasMacros) ...[
          Text('Makro Dağılımı', style: AppTextStyles.headingSmall),
          const SizedBox(height: 12),
          _MacroDistributionCard(
            protein: totalProtein,
            carb: totalCarb,
            fat: totalFat,
          ),
          const SizedBox(height: 24),
        ],
        Text('Günlük Detay', style: AppTextStyles.headingSmall),
        const SizedBox(height: 12),
        ...weekly.sevenDays.map((d) => _DayRow(day: d)),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.weekly});
  final WeeklySummary weekly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.18),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                weekly.avgCalories.toString(),
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.primary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                ' kcal/gün ortalama',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                  label: 'Toplam',
                  value: weekly.totalCalories.toString(),
                  unit: 'kcal'),
              const SizedBox(width: 12),
              _MiniStat(
                  label: 'Öğün',
                  value: weekly.totalMeals.toString(),
                  unit: ''),
              const SizedBox(width: 12),
              _MiniStat(
                  label: 'Kayıt',
                  value: '${weekly.daysLogged}/7',
                  unit: 'gün'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700)),
                  if (unit.isNotEmpty)
                    Text(' $unit',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
        ),
      );
}

class _MacroDistributionCard extends StatelessWidget {
  const _MacroDistributionCard({
    required this.protein,
    required this.carb,
    required this.fat,
  });
  final double protein;
  final double carb;
  final double fat;

  @override
  Widget build(BuildContext context) {
    final total = protein + carb + fat;
    if (total <= 0) return const SizedBox.shrink();

    final pPct = (protein / total * 100).round();
    final cPct = (carb / total * 100).round();
    final fPct = (fat / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                      flex: pPct == 0 ? 1 : pPct,
                      child: Container(color: AppColors.success)),
                  Expanded(
                      flex: cPct == 0 ? 1 : cPct,
                      child: Container(color: AppColors.primary)),
                  Expanded(
                      flex: fPct == 0 ? 1 : fPct,
                      child: Container(color: AppColors.warning)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MacroLegend(
                  label: 'Protein',
                  grams: protein.round(),
                  pct: pPct,
                  color: AppColors.success),
              const SizedBox(width: 12),
              _MacroLegend(
                  label: 'Karb',
                  grams: carb.round(),
                  pct: cPct,
                  color: AppColors.primary),
              const SizedBox(width: 12),
              _MacroLegend(
                  label: 'Yağ',
                  grams: fat.round(),
                  pct: fPct,
                  color: AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroLegend extends StatelessWidget {
  const _MacroLegend({
    required this.label,
    required this.grams,
    required this.pct,
    required this.color,
  });
  final String label;
  final int grams;
  final int pct;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(label,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 2),
            Text('${grams}g',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700)),
            Text('%$pct',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary)),
          ],
        ),
      );
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});
  final DaySummary day;
  static const _dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final hasData = day.hasData;
    final pct = day.targetCalories == 0
        ? 0.0
        : (day.totalCalories / day.targetCalories).clamp(0.0, 1.5);
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final isToday = day.localDay == todayKey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.divider,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              context.push('${AppRoute.dayDetail}/${day.localDay}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dayLabels[day.weekdayIndex],
                        style: AppTextStyles.caption.copyWith(
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        day.localDay.split('-').last,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor:
                          AppColors.textTertiary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(
                        pct > 1.0
                            ? AppColors.warning
                            : (hasData
                                ? AppColors.primary
                                : AppColors.textTertiary
                                    .withOpacity(0.3)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: Text(
                    hasData ? '${day.totalCalories}' : '—',
                    textAlign: TextAlign.end,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: hasData
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 20, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 56, color: AppColors.error),
              const SizedBox(height: 12),
              Text(message, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
}
