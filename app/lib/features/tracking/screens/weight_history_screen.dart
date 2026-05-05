import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/app_error.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../data/tracking_repository.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Kilo geçmişi: hero kart (güncel + değişim + trend), çizgi grafiği
/// ve detay listesi.
class WeightHistoryScreen extends ConsumerWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(weightHistoryProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.weightHistoryTitle, style: AppTextStyles.headingMedium),
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: asyncEntries.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _ErrorView(
          message: e is AppError ? e.userMessage : AppLocalizations.of(context)!.weeklyChartLoadFailed,
          onRetry: () => ref.invalidate(weightHistoryProvider),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(weightHistoryProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeroCard(entries: entries),
                const SizedBox(height: 16),
                if (entries.length >= 2) ...[
                  _LineChartCard(entries: entries),
                  const SizedBox(height: 16),
                ],
                _EntryListCard(entries: entries),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Hero ────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.entries});
  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    // Backend newest-first döner.
    final current = entries.first;
    final earliest = entries.last;
    final delta = current.weightKg - earliest.weightKg;
    final hasMultipleEntries = entries.length >= 2;

    final trendColor = delta == 0 || !hasMultipleEntries
        ? Colors.white.withValues(alpha: 0.7)
        : (delta < 0 ? AppColors.accentLight : const Color(0xFFFFB570));
    final trendIcon = !hasMultipleEntries
        ? Icons.remove_rounded
        : (delta < 0
            ? Icons.trending_down_rounded
            : (delta > 0
                ? Icons.trending_up_rounded
                : Icons.remove_rounded));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF243B53), Color(0xFF3D5A80)],
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
                  Icons.monitor_weight_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.weightCurrent,
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
                _fmt(current.weightKg),
                style: AppTextStyles.displayLarge.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'kg',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
              const Spacer(),
              if (hasMultipleEntries)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, size: 14, color: trendColor),
                      const SizedBox(width: 4),
                      Text(
                        '${delta >= 0 ? '+' : ''}${_fmt(delta)} kg',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MiniStat(
                label: AppLocalizations.of(context)!.weightFirstRecord,
                value:
                    '${_fmt(earliest.weightKg)} kg · ${_shortDateLocalized(context, earliest.day)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    final abs = v.abs();
    return v < 0 ? '-${abs.toStringAsFixed(1)}' : abs.toStringAsFixed(1);
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
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Line chart ──────────────────────────────────────────────────────

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({required this.entries});
  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    // Eski-en-eski → en-yeni sırasına çevir, max 30 nokta (UI sığar).
    final source = entries.length > 30 ? entries.take(30).toList() : entries;
    final ordered = source.reversed.toList();

    final weights = ordered.map((e) => e.weightKg).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    // Padding so flat lines aren't a single pixel
    final span = maxW - minW;
    final pad = span < 1 ? 0.5 : span * 0.15;
    final chartMin = minW - pad;
    final chartMax = maxW + pad;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend (${ordered.length} kayıt)',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                // Y ekseni etiketleri
                SizedBox(
                  width: 36,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chartMax.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        ((chartMin + chartMax) / 2).toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        chartMin.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomPaint(
                    painter: _LineChartPainter(
                      values: weights,
                      minValue: chartMin,
                      maxValue: chartMax,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X ekseni: ilk ve son tarih
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              children: [
                Text(
                  _shortDateLocalized(context, ordered.first.day),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                Text(
                  _shortDateLocalized(context, ordered.last.day),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
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

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
  });
  final List<double> values;
  final double minValue;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final range = maxValue - minValue;
    if (range <= 0) return;

    // Yatay grid çizgileri (3 adet: alt, orta, üst)
    final gridPaint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    for (var i = 0; i <= 2; i++) {
      final y = (size.height / 2) * i;
      canvas.drawLine(
        Offset(0, y.clamp(0, size.height - 0.5)),
        Offset(size.width, y.clamp(0, size.height - 0.5)),
        gridPaint,
      );
    }

    // Noktaları hesapla
    final points = <Offset>[];
    final dx = size.width / (values.length - 1);
    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final ratio = (values[i] - minValue) / range;
      final y = size.height * (1 - ratio);
      points.add(Offset(x, y));
    }

    // Dolgulu alan
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.35),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Çizgi
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    final linePaint = Paint()
      ..color = AppColors.primaryLight
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // Noktalar
    final dotPaint = Paint()..color = AppColors.primaryLight;
    final dotInnerPaint = Paint()..color = AppColors.background;
    for (var i = 0; i < points.length; i++) {
      // İlk ve son noktayı vurgu olarak koyu yap
      final isEdge = i == 0 || i == points.length - 1;
      canvas.drawCircle(points[i], isEdge ? 4 : 2.5, dotPaint);
      if (isEdge) {
        canvas.drawCircle(points[i], 2, dotInnerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) {
    return old.values != values ||
        old.minValue != minValue ||
        old.maxValue != maxValue;
  }
}

// ─── Entry list ──────────────────────────────────────────────────────

class _EntryListCard extends StatelessWidget {
  const _EntryListCard({required this.entries});
  final List<WeightEntry> entries;

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
                Text(AppLocalizations.of(context)!.weightRecordsList, style: AppTextStyles.labelMedium),
                const Spacer(),
                Text(
                  AppLocalizations.of(context)!.weightEntriesCount(entries.length),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(entries.length, (i) {
            final entry = entries[i];
            // Bir önceki kayıt = listede bir sonraki (newest-first)
            final prev = i + 1 < entries.length ? entries[i + 1] : null;
            return _EntryRow(
              entry: entry,
              previous: prev,
              showDivider: i != entries.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.previous,
    required this.showDivider,
  });
  final WeightEntry entry;
  final WeightEntry? previous;
  final bool showDivider;

  static const _months = [
    '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(entry.day);
    final delta = previous == null
        ? null
        : entry.weightKg - previous!.weightKg;

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
                            'BUGÜN',
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
                  if (delta != null && delta != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                        style: AppTextStyles.caption.copyWith(
                          color: delta < 0
                              ? AppColors.accent
                              : AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.weightKg.toStringAsFixed(1)} kg',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
              decoration: const BoxDecoration(
                color: AppColors.surfaceHighlight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                size: 48,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Henüz kilo kaydı yok', style: AppTextStyles.headingMedium),
            const SizedBox(height: 8),
            Text(
              'Ana sayfada Kilo butonuna basıp\nilk kaydını oluştur.',
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

/// Locale-aware short date format helper (top-level so all classes can use it).
String _shortDateLocalized(BuildContext context, DateTime d) {
  final l10n = AppLocalizations.of(context)!;
  final months = [
    l10n.monthShortJan, l10n.monthShortFeb, l10n.monthShortMar,
    l10n.monthShortApr, l10n.monthShortMay, l10n.monthShortJun,
    l10n.monthShortJul, l10n.monthShortAug, l10n.monthShortSep,
    l10n.monthShortOct, l10n.monthShortNov, l10n.monthShortDec,
  ];
  return '${d.day} ${months[d.month - 1]}';
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
