import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import 'providers/dashboard_provider.dart';
import '../meal_scan/meal_scan_screen.dart';
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
                        error: (e, _) => _ErrorBlock(
                          message: e is ApiException
                              ? e.userMessage
                              : 'Could not load summary.',
                          onRetry: () =>
                              ref.invalidate(dashboardSummaryProvider),
                        ),
                        data: (summary) => Column(
                          children: [
                            TodaysSummarySection(summary: summary),
                            MacrosRow(summary: summary),
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MealScanScreen()),
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
    return Column(
      children: [
        // Hero card skeleton
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          height: 320,
          decoration: _skeletonDecoration(),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF4DDBFF)),
              ),
            ),
          ),
        ),
        // Macros skeleton
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  height: 90,
                  margin: EdgeInsets.only(left: i == 0 ? 0 : 10),
                  decoration: _skeletonDecoration(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Water skeleton
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 64,
          decoration: _skeletonDecoration(),
        ),
      ],
    );
  }

  BoxDecoration _skeletonDecoration() => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF142346).withOpacity(0.4),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      );
}

// ============================================================================
// Error block
// ============================================================================

class _ErrorBlock extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBlock({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF142346).withOpacity(0.5),
        border: Border.all(
          color: const Color(0xFFFF9F45).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: Color(0xFFFF9F45),
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4DDBFF),
              side: BorderSide(color: const Color(0xFF4DDBFF).withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
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
