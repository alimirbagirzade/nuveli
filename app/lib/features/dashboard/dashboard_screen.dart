import 'package:flutter/material.dart';
import 'package:nuveli/features/profile/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/app_error.dart';
import '../../shared/widgets/app_error_view.dart';
import '../../shared/widgets/skeleton.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/add_food_button.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/macros_row.dart';
import 'widgets/meals_section.dart';
import 'widgets/todays_summary_section.dart';
import 'widgets/water_quick_card.dart';

/// Main Dashboard screen — the home of the app once authenticated.
///
/// Layout (top to bottom):
///   1. Header (date + greeting + avatar)
///   2. Today's Summary (big calorie ring)
///   3. Macros row (Protein / Carbs / Fat)
///   4. Water quick card (+250ml)
///   5. Today's meals list
///   6. Add Food CTA (sticky above bottom nav)
///   + Bottom nav placeholder (real navigation lands in Chat 17)
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final mealsAsync = ref.watch(todayMealsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: _GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF00D4FF),
                  backgroundColor: const Color(0xFF142346),
                  onRefresh: () => refreshDashboard(ref),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      const DashboardHeader(),
                      summaryAsync.when(
                        loading: () => const _DashboardSkeleton(),
                        error: (e, _) => AppErrorView(
                          error: AppError.from(e),
                          onRetry: () =>
                              ref.invalidate(dashboardSummaryProvider),
                        ),
                        data: (summary) => Column(
                          children: [
                            TodaysSummarySection(summary: summary.todaySummary),
                            MacrosRow(summary: summary.todaySummary),
                            WaterQuickCard(
                              consumedMl: summary.consumedWaterMl,
                              targetMl: summary.dailyWaterTargetMl,
                              onAddWater: (amount) async {
                                await ref.read(logWaterProvider)(amount);
                              },
                            ),
                          ],
                        ),
                      ),
                      mealsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (meals) => MealsSection(
                          meals: meals,
                          onSeeAll: () => _showComingSoon(
                            context,
                            'Full meal history lands in Chat 17 (Navigation).',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Sticky CTA above bottom nav
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: AddFoodButton(
                  onPressed: () => _showComingSoon(
                    context,
                    'AI Meal Scan ships in Chat 5.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavPlaceholder(
        onTap: (label) => _showComingSoon(
          context,
          '$label is wired up in Chat 17 (Navigation).',
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF142346),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

// ============================================================================
// Background
// ============================================================================

class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF050A1F), Color(0xFF0B1A3D)],
        ),
      ),
      child: child,
    );
  }
}

// ============================================================================
// Loading skeleton
// ============================================================================

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Hero (calorie ring) — tall card.
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SkeletonBox(height: 320, borderRadius: 16),
        ),
        // Macros row — 3 equal placeholders.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: SkeletonBox(height: 90, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 90, borderRadius: 16)),
              SizedBox(width: 10),
              Expanded(child: SkeletonBox(height: 90, borderRadius: 16)),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Water quick card row.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SkeletonBox(height: 64, borderRadius: 16),
        ),
      ],
    );
  }
}

// ============================================================================
// Bottom nav placeholder (Chat 17 will replace this with the real one)
// ============================================================================

class _BottomNavPlaceholder extends StatelessWidget {
  final void Function(String label) onTap;
  const _BottomNavPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Dashboard', Icons.dashboard_rounded, true),
      ('Scan', Icons.camera_alt_outlined, false),
      ('Analytics', Icons.insights_outlined, false),
      ('Profile', Icons.person_outline, false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050A1F).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((it) {
              final (label, icon, active) = it;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(label),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          color: active
                              ? const Color(0xFF4DDBFF)
                              : const Color(0xFF6E7B91),
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w500,
                            color: active
                                ? const Color(0xFF4DDBFF)
                                : const Color(0xFF6E7B91),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
