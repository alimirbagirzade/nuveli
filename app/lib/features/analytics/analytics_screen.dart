import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import 'providers/analytics_providers.dart';
import 'widgets/macro_breakdown_card.dart';
import 'widgets/weekly_calorie_chart.dart';
import 'widgets/weight_trend_card.dart';

/// Analytics tab — replaces the v1.1 placeholder that was there before
/// (see `docs/product/launch-gaps-2026-05-23.md` F3). Shows:
///   1. Weekly calorie bars + target line + days-on-target headline
///   2. Macro breakdown (7-day avg, stacked horizontal bar + legend)
///   3. Weight trend (current + delta + moving-avg polyline)
///
/// Each section degrades to a friendly empty state when the user
/// hasn't logged enough data yet — App Review won't see dead chrome.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weeklyAsync = ref.watch(weeklyAnalyticsProvider);
    final trendAsync = ref.watch(weightTrend8wProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF050A1F), Color(0xFF0B1A3D)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(weeklyAnalyticsProvider);
              ref.invalidate(weightTrend8wProvider);
              await Future.wait([
                ref.read(weeklyAnalyticsProvider.future),
                ref.read(weightTrend8wProvider.future),
              ]);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                Text(
                  l10n?.analyticsTitle ?? 'Analytics',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.analyticsSubtitle ?? 'Your week at a glance',
                  style: const TextStyle(
                    color: Color(0xFFB8C5D6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                weeklyAsync.when(
                  loading: () => const _Skeleton(height: 220),
                  error: (_, __) => _ErrorTile(
                      label: l10n?.analyticsErrorWeeklyBars ??
                          'Could not load weekly bars'),
                  data: (w) => WeeklyCalorieChart(analytics: w),
                ),
                const SizedBox(height: 14),
                weeklyAsync.when(
                  loading: () => const _Skeleton(height: 130),
                  error: (_, __) => _ErrorTile(
                      label: l10n?.analyticsErrorMacroBreakdown ??
                          'Could not load macro breakdown'),
                  data: (w) => MacroBreakdownCard(avg: w.avgMacroBreakdown),
                ),
                const SizedBox(height: 14),
                trendAsync.when(
                  loading: () => const _Skeleton(height: 180),
                  error: (_, __) => _ErrorTile(
                      label: l10n?.analyticsErrorWeightTrend ??
                          'Could not load weight trend'),
                  data: (t) => WeightTrendCard(trend: t),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double height;
  const _Skeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF142346).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final String label;
  const _ErrorTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C5C).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF5C5C).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFFF8A8A), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFB3B3),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
