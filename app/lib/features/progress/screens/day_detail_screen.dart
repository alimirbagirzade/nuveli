import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../meal/data/meal_models.dart';
import '../../meal/data/meal_repository.dart';
import '../data/progress_repository.dart';

/// Day detail — opened when the user taps a bar in the weekly chart.
/// Shows that day's meals, macro breakdown, and a header summary.
///
/// The data comes from two endpoints we already have:
///   GET /summary/weekly/current → finds the DaySummary by localDay
///   GET /meals?local_day=YYYY-MM-DD → list of meals for that day
class DayDetailScreen extends ConsumerWidget {
  const DayDetailScreen({super.key, required this.localDay});

  /// 'YYYY-MM-DD' string from the URL path param.
  final String localDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklySummaryProvider);
    final mealsAsync = ref.watch(_mealsForDayProvider(localDay));

    return AppScaffold(
      appBar: AppBar(title: Text(_formatDateTr(localDay))),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(weeklySummaryProvider);
          ref.invalidate(_mealsForDayProvider(localDay));
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Day summary card pulled from the weekly response we already cache
            weeklyAsync.when(
              loading: () => const _SkeletonCard(),
              error: (_, __) => const SizedBox.shrink(),
              data: (weekly) {
                final day = weekly.sevenDays.firstWhere(
                  (d) => d.localDay == localDay,
                  orElse: () => DaySummary(
                    localDay: localDay,
                    totalCalories: 0,
                    targetCalories: 2000,
                    mealCount: 0,
                    proteinG: 0,
                    carbG: 0,
                    fatG: 0,
                    waterMl: 0,
                  ),
                );
                return _DaySummaryCard(day: day);
              },
            ),
            const SizedBox(height: 20),

            Text('Öğünler', style: AppTextStyles.headingSmall),
            const SizedBox(height: 12),

            mealsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _MealsError(
                message: e is AppError ? e.userMessage : 'Öğünler yüklenemedi',
                onRetry: () => ref.invalidate(_mealsForDayProvider(localDay)),
              ),
              data: (meals) {
                if (meals.isEmpty) {
                  return _EmptyMeals(localDay: localDay);
                }
                return Column(
                  children: [
                    for (final m in meals) _MealRow(meal: m),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// "2026-04-28" → "28 Nisan 2026, Salı"
  String _formatDateTr(String iso) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    const weekdays = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe',
      'Cuma', 'Cumartesi', 'Pazar',
    ];
    try {
      final parts = iso.split('-');
      final y = int.parse(parts[0]);
      final mo = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      final dt = DateTime(y, mo, d);
      return '$d ${months[mo - 1]}, ${weekdays[dt.weekday - 1]}';
    } catch (_) {
      return iso;
    }
  }
}

// ─── Day summary card ────────────────────────────────────────────────

class _DaySummaryCard extends StatelessWidget {
  const _DaySummaryCard({required this.day});
  final DaySummary day;

  @override
  Widget build(BuildContext context) {
    final hasData = day.hasData;
    final pct = day.targetCalories == 0
        ? 0.0
        : (day.totalCalories / day.targetCalories).clamp(0.0, 1.5);
    final pctLabel = (pct * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${day.totalCalories}',
                style: AppTextStyles.headingLarge.copyWith(
                  color: hasData ? AppColors.primary : AppColors.textTertiary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                ' / ${day.targetCalories} kcal',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (hasData)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pct > 1.0
                        ? AppColors.warning.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '%$pctLabel',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: pct > 1.0 ? AppColors.warning : AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Macro breakdown — three colored bars
          Row(
            children: [
              _MacroChip(
                label: 'Protein',
                value: '${day.proteinG.toInt()}g',
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'Karb',
                value: '${day.carbG.toInt()}g',
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'Yağ',
                value: '${day.fatG.toInt()}g',
                color: AppColors.warning,
              ),
            ],
          ),

          if (day.waterMl > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.water_drop_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${day.waterMl} ml su',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
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
  Widget build(BuildContext context) {
    return Expanded(
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
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Meal row ────────────────────────────────────────────────────────

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal});
  final MealLog meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
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
            child: Icon(
              Icons.restaurant_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  meal.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _mealTypeLabel(meal.mealType),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${meal.calories} kcal',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (meal.proteinG != null && meal.proteinG! > 0)
                Text(
                  'P${meal.proteinG!.toInt()} K${meal.carbG?.toInt() ?? 0} Y${meal.fatG?.toInt() ?? 0}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _mealTypeLabel(String? type) {
    switch (type) {
      case 'breakfast':
        return 'Kahvaltı';
      case 'lunch':
        return 'Öğle';
      case 'dinner':
        return 'Akşam';
      case 'snack':
        return 'Atıştırmalık';
      default:
        return 'Öğün';
    }
  }
}

// ─── Empty + skeleton + error ────────────────────────────────────────

class _EmptyMeals extends StatelessWidget {
  const _EmptyMeals({required this.localDay});
  final String localDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 40,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'Bu gün için öğün kaydı yok',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _MealsError extends StatelessWidget {
  const _MealsError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}

// ─── Provider — meals for a given day ────────────────────────────────

/// Family-style provider: pass a localDay string, get cached meals for it.
/// Uses the existing MealRepository.listMeals which calls GET /meals?local_day=...
final _mealsForDayProvider =
    FutureProvider.family<List<MealLog>, String>((ref, localDay) async {
  final repo = ref.watch(mealRepositoryProvider);
  return repo.listMeals(localDay);
});
