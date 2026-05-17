import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nuveli/core/theme/app_colors.dart';
import 'package:nuveli/core/theme/app_typography.dart';
import 'package:nuveli/shared/widgets/nuveli_background.dart';
import 'package:nuveli/shared/widgets/nuveli_bottom_nav.dart';

import 'providers/dashboard_provider.dart';
import 'widgets/add_food_button.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/macros_row.dart';
import 'widgets/meals_section.dart';
import 'widgets/todays_summary_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.cardBackground,
      ),
      child: NuveliBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardProvider);
                await ref.read(dashboardProvider.future);
              },
              color: AppColors.primaryCyan,
              backgroundColor: AppColors.cardBackground,
              child: dashboardAsync.when(
                loading: () => const _DashboardSkeleton(),
                error: (err, _) => _DashboardError(
                  onRetry: () => ref.invalidate(dashboardProvider),
                ),
                data: (data) => _DashboardContent(data: data),
              ),
            ),
          ),
          bottomNavigationBar: NuveliBottomNav(
            currentIndex: 0,
            onTap: (i) => debugPrint(
              'Bottom nav tapped: index=$i - Chat 12 will wire go_router',
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardData data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        const SliverToBoxAdapter(
          child: DashboardHeader(userName: 'Alex'),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              TodaysSummarySection(
                consumed: data.consumedCalories,
                target: data.targetCalories,
              ),
              const SizedBox(height: 24),
              MacrosRow(macros: data.macros),
              const SizedBox(height: 32),
              MealsSection(
                meals: data.todaysMeals,
                onViewAll: () => debugPrint('View all tapped'),
                onMealTap: (meal) => debugPrint(
                    'Tapped meal: ${meal.name} (${meal.calories} kcal)'),
              ),
              const SizedBox(height: 16),
              const AddFoodButton(),
              const SizedBox(height: 100), // bottom nav clearance
            ]),
          ),
        ),
      ],
    );
  }
}

/// Lightweight skeleton (no shimmer dependency needed).
/// Swap for a `shimmer` version later if the package gets added.
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        _bar(width: 180, height: 16),
        const SizedBox(height: 32),
        Center(child: _circle(size: 200)),
        const SizedBox(height: 24),
        _bar(height: 100),
        const SizedBox(height: 32),
        _bar(height: 220),
        const SizedBox(height: 24),
        _bar(height: 56),
      ],
    );
  }

  Widget _bar({double? width, required double height}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
      );

  Widget _circle({required double size}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
      );
}

class _DashboardError extends StatelessWidget {
  final VoidCallback onRetry;
  const _DashboardError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 100),
      children: [
        Icon(
          Icons.cloud_off_rounded,
          size: 56,
          color: AppColors.secondaryText.withOpacity(0.6),
        ),
        const SizedBox(height: 16),
        Text(
          "Couldn't load dashboard",
          textAlign: TextAlign.center,
          style: AppTypography.cardTitle.copyWith(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pull down to retry or tap below.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: AppColors.secondaryText,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: AppTypography.body.copyWith(
                color: AppColors.primaryCyan,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
