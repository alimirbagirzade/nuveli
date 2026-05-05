import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../data/tracking_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Su geçmişi: hero kart (30 günlük ortalama + bugün), son 7 günün
/// bar grafiği ve 30 günlük detay listesi.
class WaterHistoryScreen extends ConsumerWidget {
  const WaterHistoryScreen({super.key});

  /// Günlük hedef — UI normalizasyonu için. Profil hedefiyle eşitleme
  /// işi backend'in 1.x sürümüne kalsın; şimdilik sabit varsayım.
  static const _dailyGoalMl = 2500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHistory = ref.watch(waterHistoryProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.waterHistoryTitle, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: asyncHistory.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _ErrorView(
          message: e is AppError ? e.userMessage : AppLocalizations.of(context)!.weeklyChartLoadFailed,
          onRetry: () => ref.invalidate(waterHistoryProvider),
        ),
        data: (history) {
          if (history.entries.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(waterHistoryProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeroCard(history: history),
                const SizedBox(height: 16),
                _BarChartCard(history: history, goalMl: _dailyGoalMl),
                const SizedBox(height: 16),
                _DailyListCard(history: history),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Hero (top stats) ────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.history});
  final WaterHistory history;

  @override
  Widget build(BuildContext context) {
    // Bugün backend tarafında listenin ilk elemanı olarak gelir
    // (newest-first), ama emin olmak için tarihle de eşleştirelim.
    final today = DateTime.now();
    final todayEntry = history.entries.firstWhere(
      (e) =>
          e.day.year == today.year &&
          e.day.month == today.month &&
          e.day.day == today.day,
      orElse: () => WaterDay(day: today, totalMl: 0),
    );

    final totalLitres = history.entries
            .fold<int>(0, (sum, e) => sum + e.totalMl) /
        1000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F4D8C), Color(0xFF2D6FB8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Son ${history.days} gün',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatLitres(totalLitres),
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  AppLocalizations.of(context)!.waterLitresTotal,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(
                label: AppLocalizations.of(context)!.waterToday,
                value: '${todayEntry.totalMl} ml',
              ),
              const SizedBox(width: 24),
              _MiniStat(
                label: AppLocalizations.of(context)!.waterAverage,
                value: '${history.averageMl} ml',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatLitres(double l) {
    // 1 ondalık ama eğer .0 ise göstermeye gerek yok
    if (l == l.truncateToDouble()) return l.toInt().toString();
    return l.toStringAsFixed(1);
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

// ─── Bar chart (last 7 days) ─────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.history, required this.goalMl});
  final WaterHistory history;
  final int goalMl;

  static const _dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    // Son 7 günü oldest-first sıraya koy.
    final last7 = history.entries.take(7).toList().reversed.toList();
    if (last7.isEmpty) return const SizedBox.shrink();

    // Bar yüksekliği: hedefin yüzdesi, ama haftadaki en yüksek değer
    // hedefi aşıyorsa ona göre normalize et — bar çizelgenin tepesini
    // kırmaz.
    final maxInWeek = last7.fold<int>(
      0,
      (m, e) => e.totalMl > m ? e.totalMl : m,
    );
    final ceiling = (maxInWeek > goalMl ? maxInWeek : goalMl).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.waterLast7, style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Hedef: ${goalMl} ml/gün',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(last7.length, (i) {
                final entry = last7[i];
                final ratio = (entry.totalMl / ceiling).clamp(0.0, 1.0);
                final hitGoal = entry.totalMl >= goalMl;
                final isToday = _isToday(entry.day);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // ml etiketi (sadece sıfır olmayanlarda)
                        if (entry.totalMl > 0)
                          Text(
                            '${entry.totalMl}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              color: AppColors.textTertiary,
                            ),
                          )
                        else
                          const SizedBox(height: 12),
                        const SizedBox(height: 4),
                        // Bar
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: ratio == 0 ? 0.02 : ratio,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: hitGoal
                                        ? [
                                            AppColors.accentLight,
                                            AppColors.accent,
                                          ]
                                        : [
                                            AppColors.info,
                                            AppColors.info.withValues(alpha: 0.6),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _dayLabels[(entry.day.weekday - 1) % 7],
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

// ─── 30-day list ─────────────────────────────────────────────────────

class _DailyListCard extends StatelessWidget {
  const _DailyListCard({required this.history});
  final WaterHistory history;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Text(AppLocalizations.of(context)!.waterAllDaysList, style: AppTextStyles.labelMedium),
                const Spacer(),
                Text(
                  AppLocalizations.of(context)!.historyDaysSuffix(history.entries.length),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(history.entries.length, (i) {
            final entry = history.entries[i];
            final isLast = i == history.entries.length - 1;
            return _DailyRow(entry: entry, showDivider: !isLast);
          }),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({required this.entry, required this.showDivider});
  final WaterDay entry;
  final bool showDivider;

  static const _months = [
    '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];
  static const _days = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(entry.day);
    final isEmpty = entry.totalMl == 0;

    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.divider, width: 0.5),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Tarih kutusu (gün numarası + ay kısa)
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : AppColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '${entry.day.day}',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _months[entry.day.month],
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Gün adı + bugün rozeti
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _weekdayLocalized(context, entry.day.weekday),
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.waterTodayBadge,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isEmpty)
                    Text(
                      AppLocalizations.of(context)!.waterNoEntry,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            // Miktar
            Text(
              isEmpty ? '—' : '${entry.totalMl} ml',
              style: AppTextStyles.bodyLarge.copyWith(
                color:
                    isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
                fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
}

// ─── States ──────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.water_drop_outlined,
                size: 48,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: 20),
            Text('Henüz su kaydı yok', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              'Ana sayfada Su butonuna basıp\nilk kaydını oluştur.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Locale-aware weekday name (top-level helper).
String _weekdayLocalized(BuildContext context, int weekday) {
  final l10n = AppLocalizations.of(context)!;
  switch (weekday) {
    case 1: return l10n.weekdayMon;
    case 2: return l10n.weekdayTue;
    case 3: return l10n.weekdayWed;
    case 4: return l10n.weekdayThu;
    case 5: return l10n.weekdayFri;
    case 6: return l10n.weekdaySat;
    case 7: return l10n.weekdaySun;
    default: return '';
  }
}
