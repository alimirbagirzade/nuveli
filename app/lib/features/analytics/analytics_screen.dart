import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_spacing.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/features/analytics/models/analytics_data.dart';
import 'package:nuveli/features/analytics/providers/analytics_provider.dart';
import 'package:nuveli/features/analytics/widgets/achievements_section.dart';
import 'package:nuveli/features/analytics/widgets/analytics_header.dart';
import 'package:nuveli/features/analytics/widgets/analytics_tab_bar.dart';
import 'package:nuveli/features/analytics/widgets/macro_breakdown_card.dart';
import 'package:nuveli/features/analytics/widgets/weekly_calorie_average_card.dart';
import 'package:nuveli/features/analytics/widgets/weight_trend_card.dart';
import 'package:nuveli/shared/widgets/nuveli_background.dart';
import 'package:nuveli/shared/widgets/nuveli_bottom_nav.dart';

/// Görsel 4 — See Your Progress (Analytics ekranı).
///
/// 4 sekme: Overview (dolu) / Nutrition / Meals / Trends (Coming Soon)
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return NuveliBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AnalyticsHeader(
                onCalendarTap: () => _showComingSoon(context, 'Calendar'),
              ),
              AnalyticsTabBar(controller: _tabController),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Overview (Görsel 4 — ANA İÇERİK)
                    analyticsAsync.when(
                      data: (data) => _OverviewTab(data: data),
                      loading: () => const _LoadingState(),
                      error: (err, _) => _ErrorState(message: err.toString()),
                    ),

                    // Tab 2-4: Coming Soon
                    const _ComingSoonTab(name: 'Nutrition'),
                    const _ComingSoonTab(name: 'Meals'),
                    const _ComingSoonTab(name: 'Trends'),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NuveliBottomNav(
          currentIndex: 2, // Analytics tab seçili
          onTap: (i) {
            // Routing Chat 12'de bağlanacak
          },
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature picker — Coming Soon'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.cardBackground,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// ✅ Overview tab — Görsel 4'ün ana içeriği.
class _OverviewTab extends StatelessWidget {
  final AnalyticsData data;

  const _OverviewTab({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl + AppSpacing.md, // alt nav için boşluk
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Weight Trend
          WeightTrendCard(
            data: data.weightTrend,
            periodLabel: 'Last 8 Weeks',
            activeDotIndex: 0,
          ),

          SizedBox(height: AppSpacing.md),

          // 2. Macro Breakdown
          MacroBreakdownCard(macros: data.macroBreakdown),

          SizedBox(height: AppSpacing.md),

          // 3. Weekly Calorie Average
          WeeklyCalorieAverageCard(data: data.weeklyCalories),

          SizedBox(height: AppSpacing.lg), // 24px

          // 4. Achievements
          AchievementsSection(achievements: data.achievements),
        ],
      ),
    );
  }
}

/// Diğer 3 tab için Coming Soon placeholder.
class _ComingSoonTab extends StatelessWidget {
  final String name;

  const _ComingSoonTab({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            '$name',
            style: AppTypography.sectionTitle.copyWith(
              fontSize: 20,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: AppTypography.body.copyWith(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton — basit centered indicator.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryCyan,
        strokeWidth: 2.5,
      ),
    );
  }
}

/// Error state.
class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.danger,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load analytics',
              style: AppTypography.cardTitle.copyWith(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
